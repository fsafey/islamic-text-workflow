#!/usr/bin/env python3
"""
Streamlined Claude Docker API Server using stdio workers

This server communicates with workers via stdin/stdout pipes,
eliminating the need for file-based coordination.
"""

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import asyncio
import json
import uuid
from datetime import datetime
import subprocess
import sys
import os


class Message(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    model: str
    messages: List[Message]
    max_tokens: Optional[int] = 1024
    temperature: Optional[float] = 0.5
    system: Optional[str] = None
    tools: Optional[List[Dict[str, Any]]] = None


class ChatResponse(BaseModel):
    id: str
    type: str = "message"
    role: str = "assistant"
    content: List[Dict[str, Any]]
    model: str
    stop_reason: Optional[str] = "end_turn"
    stop_sequence: Optional[str] = None
    usage: Dict[str, int]


class WorkerPool:
    """Manages a pool of stdio workers"""
    
    def __init__(self, num_workers: int = 3):
        self.workers = []
        self.available_workers = asyncio.Queue()
        self.num_workers = num_workers
        
    async def start(self):
        """Start all workers"""
        for i in range(self.num_workers):
            worker_id = f"worker-{i+1}"
            
            # Start worker subprocess
            process = await asyncio.create_subprocess_exec(
                "python", "/app/claude_docker_worker_stdio.py",
                stdin=asyncio.subprocess.PIPE,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                env={**os.environ, "WORKER_ID": worker_id}
            )
            
            worker = {
                "id": worker_id,
                "process": process,
                "busy": False
            }
            
            self.workers.append(worker)
            await self.available_workers.put(worker)
            
            print(f"✅ Started {worker_id}")
    
    async def stop(self):
        """Stop all workers"""
        for worker in self.workers:
            if worker["process"].returncode is None:
                worker["process"].terminate()
                await worker["process"].wait()
        print("✅ All workers stopped")
    
    async def execute(self, request: Dict[str, Any]) -> Dict[str, Any]:
        """Execute request on an available worker"""
        
        # Get an available worker
        worker = await self.available_workers.get()
        
        try:
            # Mark as busy
            worker["busy"] = True
            
            # Send request to worker
            request_json = json.dumps(request) + "\n"
            worker["process"].stdin.write(request_json.encode())
            await worker["process"].stdin.drain()
            
            # Read response
            response_line = await asyncio.wait_for(
                worker["process"].stdout.readline(),
                timeout=130  # Slightly more than worker timeout
            )
            
            if not response_line:
                raise RuntimeError(f"Worker {worker['id']} died")
            
            # Parse response
            response = json.loads(response_line.decode())
            
            # Check for errors
            if "error" in response:
                raise RuntimeError(response["error"])
            
            return response
            
        finally:
            # Mark as available again
            worker["busy"] = False
            await self.available_workers.put(worker)


# Initialize FastAPI
app = FastAPI(title="Claude Docker API (stdio)", version="2.0")

# Initialize worker pool
worker_pool = WorkerPool(num_workers=3)


@app.on_event("startup")
async def startup_event():
    """Start worker pool on startup"""
    await worker_pool.start()
    print("🚀 Claude Docker API Server (stdio) started")
    print("📡 Workers communicate via stdin/stdout pipes")


@app.on_event("shutdown")
async def shutdown_event():
    """Stop worker pool on shutdown"""
    await worker_pool.stop()


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "claude-docker-api-stdio",
        "version": "2.0",
        "status": "ready",
        "workers": worker_pool.num_workers,
        "architecture": "stdin/stdout pipes"
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "ok", "service": "claude-docker-api-stdio"}


@app.post("/v1/messages")
async def create_message(request: ChatRequest):
    """Main Anthropic-compatible messages endpoint"""
    
    try:
        # Build request for worker
        worker_request = {
            "messages": [msg.dict() for msg in request.messages],
            "model": request.model,
            "max_tokens": request.max_tokens,
            "temperature": request.temperature,
            "system": request.system,
            "tools": request.tools
        }
        
        # Execute on worker
        result = await worker_pool.execute(worker_request)
        
        # Format response in Anthropic format
        if "content" in result:
            # Text response
            content = [{
                "type": "text",
                "text": result["content"]
            }]
        elif "tool_result" in result:
            # Tool response
            content = [{
                "type": "tool_use",
                "id": str(uuid.uuid4()),
                "name": request.tools[0]["name"] if request.tools else "tool",
                "input": result["tool_result"]
            }]
        else:
            raise ValueError("Invalid worker response")
        
        # Build response
        response = ChatResponse(
            id=f"msg_{uuid.uuid4().hex}",
            content=content,
            model=request.model,
            usage={
                "input_tokens": sum(len(msg.content) for msg in request.messages),
                "output_tokens": len(str(content))
            }
        )
        
        return response
        
    except asyncio.TimeoutError:
        raise HTTPException(status_code=504, detail="Claude Docker timeout")
    except Exception as e:
        print(f"❌ API Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    
    # Run with uvicorn
    uvicorn.run(
        "claude_docker_api_stdio:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
        log_level="info"
    )