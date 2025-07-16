#!/usr/bin/env python3
"""
Streamlined Claude Docker Worker using stdin/stdout

This worker reads JSON requests from stdin and writes responses to stdout,
following the Unix philosophy of simple, composable tools.
"""

import sys
import json
import asyncio
import subprocess
from typing import Dict, Any, List, Optional


class StdioClaudeDockerWorker:
    """Worker that processes requests via stdin/stdout"""
    
    def __init__(self, worker_id: str = "stdio-worker"):
        self.worker_id = worker_id
        self.claude_runner = "/workspace/claude_docker_runner.sh"
        
    async def run(self):
        """Main loop: read from stdin, process, write to stdout"""
        
        sys.stderr.write(f"🚀 Claude Docker Worker {self.worker_id} started\n")
        sys.stderr.write(f"📥 Reading from stdin, writing to stdout\n")
        sys.stderr.flush()
        
        # Process lines from stdin
        for line in sys.stdin:
            try:
                # Parse request
                request = json.loads(line.strip())
                
                # Process with Claude Docker
                response = await self.process_request(request)
                
                # Write response to stdout
                print(json.dumps(response))
                sys.stdout.flush()
                
            except json.JSONDecodeError as e:
                error_response = {
                    "error": f"Invalid JSON: {e}",
                    "worker_id": self.worker_id
                }
                print(json.dumps(error_response))
                sys.stdout.flush()
                
            except Exception as e:
                error_response = {
                    "error": f"Worker error: {e}",
                    "worker_id": self.worker_id
                }
                print(json.dumps(error_response))
                sys.stdout.flush()
    
    async def process_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
        """Process a single request with Claude Docker"""
        
        # Extract request components
        messages = request.get('messages', [])
        tools = request.get('tools', [])
        system = request.get('system', '')
        max_tokens = request.get('max_tokens', 4096)
        temperature = request.get('temperature', 0.5)
        model = request.get('model', 'claude-sonnet-4-0')
        
        # Format prompt
        prompt = self._format_prompt(system, messages, tools)
        
        # Build command
        claude_cmd = [
            self.claude_runner,
            "--api",
            "--print"
        ]
        
        if model and model != "claude-sonnet-4-0":
            claude_cmd.extend(["--model", model])
        
        if tools:
            # Claude Docker doesn't support --output-format, 
            # but we'll request JSON in the prompt
            pass
        
        try:
            # Execute Claude Docker
            process = await asyncio.create_subprocess_exec(
                *claude_cmd,
                stdin=asyncio.subprocess.PIPE,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd="/app"
            )
            
            # Send prompt and get response
            stdout, stderr = await asyncio.wait_for(
                process.communicate(input=prompt.encode('utf-8')),
                timeout=120  # 2 minute timeout
            )
            
            if process.returncode != 0:
                error_msg = stderr.decode() if stderr else "Unknown error"
                return {"error": f"Claude Docker failed: {error_msg}"}
            
            # Get response
            response_text = stdout.decode().strip()
            
            if not response_text:
                return {"error": "Claude Docker produced empty response"}
            
            # Format response based on whether tools were used
            if tools:
                # Try to parse as JSON if tools were requested
                try:
                    tool_result = json.loads(response_text)
                    return {"tool_result": tool_result}
                except json.JSONDecodeError:
                    # Fallback to text if not valid JSON
                    return {"content": response_text}
            else:
                return {"content": response_text}
                
        except asyncio.TimeoutError:
            return {"error": "Claude Docker timeout"}
        except Exception as e:
            return {"error": f"Execution error: {e}"}
    
    def _format_prompt(self, system: str, messages: List[Dict[str, str]], tools: List[Dict[str, Any]]) -> str:
        """Format messages into a prompt for Claude"""
        
        parts = []
        
        if system:
            parts.append(f"System: {system}")
        
        for msg in messages:
            role = msg.get('role', 'user')
            content = msg.get('content', '')
            
            if role == 'user':
                parts.append(f"Human: {content}")
            elif role == 'assistant':
                parts.append(f"Assistant: {content}")
        
        # Add tool instructions if provided
        if tools:
            tool = tools[0]  # Graphiti typically uses one tool
            schema = json.dumps(tool.get('input_schema', {}), indent=2)
            
            parts.append(f"\nYou must provide your response as valid JSON that matches this schema:")
            parts.append(f"Tool: {tool.get('name', 'response')}")
            parts.append(f"Description: {tool.get('description', '')}")
            parts.append(f"Schema:\n{schema}")
            parts.append("\nProvide ONLY the JSON response, no additional text.")
        
        parts.append("\nAssistant:")
        
        return "\n\n".join(parts)


def main():
    """Entry point for the worker"""
    
    import os
    
    # Get worker ID from environment or use default
    worker_id = os.environ.get('WORKER_ID', 'stdio-worker')
    
    # Create and run worker
    worker = StdioClaudeDockerWorker(worker_id)
    
    try:
        # Run the async worker
        asyncio.run(worker.run())
    except KeyboardInterrupt:
        sys.stderr.write(f"\n✅ Worker {worker_id} stopped\n")
        sys.stderr.flush()
    except Exception as e:
        sys.stderr.write(f"\n❌ Worker {worker_id} crashed: {e}\n")
        sys.stderr.flush()
        sys.exit(1)


if __name__ == "__main__":
    main()