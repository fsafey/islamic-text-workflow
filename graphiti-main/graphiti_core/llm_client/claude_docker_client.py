"""
Claude Docker Client for Graphiti
This integrates Claude Docker as a first-class LLM provider within Graphiti
"""

import asyncio
import json
import subprocess
import sys
from typing import List, Dict, Any, Optional
from datetime import datetime

from .client import LLMClient
from .config import LLMConfig
from ..prompts.models import Message


class ClaudeDockerClient(LLMClient):
    """
    Native Claude Docker integration for Graphiti.
    Runs Claude locally via Docker containers instead of calling external APIs.
    """
    
    def __init__(self, config: LLMConfig):
        super().__init__(config)
        self.claude_docker_path = "/workspace/claude_docker_runner.sh"
        self.worker_id = f"graphiti-worker-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
    async def _execute_claude_docker(self, messages: List[Dict[str, Any]], tools: Optional[List[Dict]] = None) -> Dict[str, Any]:
        """Execute Claude Docker with proper message formatting"""
        
        # Build the prompt in Claude's expected format
        prompt_lines = []
        
        # Add system message if present
        system_msg = next((m for m in messages if m['role'] == 'system'), None)
        if system_msg:
            prompt_lines.append(f"System: {system_msg['content']}")
            prompt_lines.append("")
        
        # Add conversation history
        for msg in messages:
            if msg['role'] == 'user':
                prompt_lines.append(f"Human: {msg['content']}")
            elif msg['role'] == 'assistant':
                prompt_lines.append(f"Assistant: {msg['content']}")
        
        # Add final assistant prompt
        prompt_lines.append("\nAssistant:")
        
        full_prompt = "\n".join(prompt_lines)
        
        # Execute via subprocess with proper volumes
        cmd = [
            "docker", "run", "--rm", "-i",
            "-v", "/Users/farieds/.claude-docker/claude-home:/home/claude-user/.claude:rw",
            "-v", "/Users/farieds/.claude-docker/credentials:/home/claude-user/.config/claude:rw",
            "-e", f"WORKER_ID={self.worker_id}",
            "claude-docker:latest",
            "claude", "--print",
            "--model", "sonnet"  # Use model alias for Claude Docker
        ]
        
        if tools:
            # Add tool definitions to the command
            cmd.extend(["--tools", json.dumps(tools)])
        
        try:
            # Run Claude Docker
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdin=asyncio.subprocess.PIPE,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            stdout, stderr = await process.communicate(input=full_prompt.encode())
            
            if process.returncode != 0:
                print(f"Command failed: {' '.join(cmd)}")
                print(f"Return code: {process.returncode}")
                print(f"Stdout: {stdout.decode()}")
                print(f"Stderr: {stderr.decode()}")
                raise RuntimeError(f"Claude Docker failed with return code {process.returncode}")
            
            # Parse response
            response_text = stdout.decode().strip()
            
            # Handle different response formats
            try:
                # Try to parse as JSON first (structured output)
                response_data = json.loads(response_text)
                return response_data
            except json.JSONDecodeError:
                # Fall back to plain text
                return {"content": response_text}
                
        except Exception as e:
            raise RuntimeError(f"Claude Docker execution failed: {str(e)}")
    
    async def _generate_response(self, messages: List[Message], **kwargs) -> str:
        """Generate a response using Claude Docker"""
        
        # Convert Message objects to dicts
        message_dicts = [{"role": msg.role, "content": msg.content} for msg in messages]
        
        # Get tools if provided
        tools = kwargs.get('tools', None)
        
        # Execute Claude Docker
        response = await self._execute_claude_docker(message_dicts, tools)
        
        # Extract content from response
        if isinstance(response, dict):
            return response.get('content', str(response))
        return str(response)
    
    async def _generate_response_with_tools(
        self, messages: List[Message], tools: List[Dict[str, Any]], **kwargs
    ) -> Dict[str, Any]:
        """Generate a response with tool use for structured output"""
        
        # Convert messages
        message_dicts = [{"role": msg.role, "content": msg.content} for msg in messages]
        
        # Execute with tools
        response = await self._execute_claude_docker(message_dicts, tools)
        
        # Format response for Graphiti's expected structure
        if 'tool_calls' in response:
            # Claude returned structured data via tools
            return {
                'tool_calls': response['tool_calls'],
                'content': response.get('content', '')
            }
        else:
            # Try to parse content as JSON for backward compatibility
            content = response.get('content', '')
            try:
                parsed = json.loads(content)
                return {
                    'tool_calls': [{
                        'function': {
                            'name': 'extract_entities',
                            'arguments': json.dumps(parsed)
                        }
                    }],
                    'content': content
                }
            except:
                # Return as plain content
                return {'content': content}
    
    def get_embedder(self):
        """Claude doesn't provide embeddings, use configured embedder"""
        # This will use whatever embedder is configured separately (e.g., Gemini)
        return None