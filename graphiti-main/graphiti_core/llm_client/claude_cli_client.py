"""
Claude CLI Client for Graphiti

This client integrates the local Claude CLI with Graphiti, allowing you to use
your existing Claude setup without external API calls.

It executes Claude through the command line interface and parses the responses
to work with Graphiti's expected format.
"""

import json
import subprocess
import asyncio
from typing import Any, Optional
from pathlib import Path

from pydantic import BaseModel

from ..prompts.models import Message
from .client import LLMClient
from .config import LLMConfig, ModelSize
from .errors import EmptyResponseError, RefusalError


class ClaudeCLIClient(LLMClient):
    """
    LLM client that uses the local Claude CLI instead of API calls.
    
    This client executes Claude through subprocess calls, allowing you to use
    your existing Claude Code CLI installation.
    """
    
    def __init__(self, config: LLMConfig, claude_command: str = "claude"):
        """
        Initialize the Claude CLI client.
        
        Args:
            config: LLM configuration
            claude_command: Path to claude executable (default: "claude")
        """
        super().__init__(config)
        self.claude_command = claude_command
        
        # Test if Claude is available
        try:
            result = subprocess.run(
                [self.claude_command, "--version"],
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                raise RuntimeError(f"Claude CLI not found at: {self.claude_command}")
            print(f"✅ Claude CLI found: {result.stdout.strip()}")
        except Exception as e:
            raise RuntimeError(f"Failed to initialize Claude CLI: {e}")
    
    async def _generate_response(
        self,
        messages: list[Message],
        response_model: type[BaseModel] | None = None,
        max_tokens: int = 4096,
        model_size: ModelSize = ModelSize.medium,
    ) -> dict[str, Any]:
        """
        Generate a response using the Claude CLI.
        
        This method formats the messages into a prompt, executes Claude via CLI,
        and parses the response to match Graphiti's expected format.
        """
        
        # Format messages into a prompt
        prompt = self._format_messages_to_prompt(messages)
        
        # If we need structured output, add instructions
        if response_model:
            schema = response_model.model_json_schema()
            prompt += f"\n\nIMPORTANT: You must respond with valid JSON that matches this schema:\n{json.dumps(schema, indent=2)}\n\nRespond ONLY with the JSON object, no additional text."
        
        # Prepare Claude CLI command
        cmd = [
            self.claude_command,
            "--max-tokens", str(max_tokens),
            "--temperature", str(self.config.temperature),
        ]
        
        # Add model selection if specified
        if model_size == ModelSize.small and self.config.small_model:
            cmd.extend(["--model", self.config.small_model])
        elif self.config.model:
            cmd.extend(["--model", self.config.model])
        
        try:
            # Execute Claude CLI asynchronously
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdin=asyncio.subprocess.PIPE,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            # Send prompt and get response
            stdout, stderr = await process.communicate(prompt.encode())
            
            if process.returncode != 0:
                error_msg = stderr.decode().strip()
                raise RuntimeError(f"Claude CLI error: {error_msg}")
            
            response_text = stdout.decode().strip()
            
            if not response_text:
                raise EmptyResponseError("Claude returned empty response")
            
            # Parse response based on expected format
            if response_model:
                # Extract JSON from response
                try:
                    # Try to parse the entire response as JSON first
                    response_json = json.loads(response_text)
                except json.JSONDecodeError:
                    # Try to extract JSON from markdown code blocks
                    import re
                    json_match = re.search(r'```(?:json)?\s*([\s\S]*?)\s*```', response_text)
                    if json_match:
                        response_json = json.loads(json_match.group(1))
                    else:
                        # Try to find JSON object in the text
                        json_match = re.search(r'\{[\s\S]*\}', response_text)
                        if json_match:
                            response_json = json.loads(json_match.group(0))
                        else:
                            raise ValueError(f"Could not extract JSON from response: {response_text[:200]}")
                
                # Validate against model
                validated = response_model.model_validate(response_json)
                return validated.model_dump()
            else:
                # Return as text response
                return {"content": response_text}
                
        except asyncio.TimeoutError:
            raise TimeoutError("Claude CLI timed out")
        except Exception as e:
            print(f"Error calling Claude CLI: {e}")
            raise
    
    def _format_messages_to_prompt(self, messages: list[Message]) -> str:
        """Format messages into a prompt string for Claude CLI."""
        prompt_parts = []
        
        for msg in messages:
            if msg.role == "system":
                prompt_parts.append(f"System: {msg.content}")
            elif msg.role == "user":
                prompt_parts.append(f"Human: {msg.content}")
            elif msg.role == "assistant":
                prompt_parts.append(f"Assistant: {msg.content}")
        
        # Add final marker for Claude
        if messages and messages[-1].role != "assistant":
            prompt_parts.append("Assistant:")
        
        return "\n\n".join(prompt_parts)