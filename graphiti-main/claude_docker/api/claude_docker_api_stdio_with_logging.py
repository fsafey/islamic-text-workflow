#!/usr/bin/env python3
"""
Enhanced Claude Docker API Server with detailed worker logging
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
import logging
from pathlib import Path

# Set up logging directory
LOG_DIR = Path("/app/logs")
LOG_DIR.mkdir(exist_ok=True)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_DIR / "api_server.log"),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

# Worker-specific loggers
worker_loggers = {}


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
    """Enhanced worker pool with detailed logging"""
    
    def __init__(self, num_workers: int = 3):
        self.num_workers = num_workers
        self.workers = []
        self.available_workers = asyncio.Queue()
        
    async def start(self):
        """Start all workers with logging"""
        for i in range(self.num_workers):
            worker_id = f"worker-{i+1}"
            
            # Create worker-specific logger
            worker_logger = logging.getLogger(f"worker.{worker_id}")
            worker_handler = logging.FileHandler(LOG_DIR / f"{worker_id}.log")
            worker_handler.setFormatter(logging.Formatter('%(asctime)s - %(message)s'))
            worker_logger.addHandler(worker_handler)
            worker_loggers[worker_id] = worker_logger
            
            # Start worker process
            process = await asyncio.create_subprocess_exec(
                sys.executable,
                "/app/claude_docker_worker_stdio.py",
                env={**os.environ, "WORKER_ID": worker_id},
                stdin=asyncio.subprocess.PIPE,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            
            worker = {
                "id": worker_id,
                "process": process,
                "busy": False,
                "logger": worker_logger
            }
            
            self.workers.append(worker)
            await self.available_workers.put(worker)
            
            logger.info(f"✅ Started {worker_id}")
            worker_logger.info(f"Worker {worker_id} started with PID {process.pid}")
    
    async def stop(self):
        """Stop all workers"""
        for worker in self.workers:
            if worker["process"].returncode is None:
                worker["process"].terminate()
                await worker["process"].wait()
                worker["logger"].info(f"Worker {worker['id']} stopped")
        logger.info("✅ All workers stopped")
    
    async def process_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
        """Process request with detailed logging"""
        # Get available worker
        worker = await self.available_workers.get()
        worker["busy"] = True
        
        try:
            # Log request
            request_id = str(uuid.uuid4())[:8]
            worker["logger"].info(f"[{request_id}] Processing request: {json.dumps(request, indent=2)}")
            logger.info(f"[{request_id}] Assigned to {worker['id']}")
            
            # Send request
            request_json = json.dumps(request) + '\n'
            worker["process"].stdin.write(request_json.encode())
            await worker["process"].stdin.drain()
            
            # Read response with timeout
            try:
                response_line = await asyncio.wait_for(
                    worker["process"].stdout.readline(),
                    timeout=130
                )
            except asyncio.TimeoutError:
                worker["logger"].error(f"[{request_id}] Timeout waiting for response")
                raise RuntimeError(f"Worker {worker['id']} timeout")
            
            if not response_line:
                worker["logger"].error(f"[{request_id}] Worker died unexpectedly")
                raise RuntimeError(f"Worker {worker['id']} died")
            
            # Parse response
            response_text = response_line.decode()
            worker["logger"].info(f"[{request_id}] Raw response: {response_text}")
            
            try:
                response = json.loads(response_text)
            except json.JSONDecodeError as e:
                worker["logger"].error(f"[{request_id}] Failed to parse response: {e}")
                worker["logger"].error(f"[{request_id}] Raw text: {response_text}")
                raise RuntimeError(f"Invalid response from worker: {e}")
            
            # Check for errors
            if "error" in response:
                worker["logger"].error(f"[{request_id}] Worker returned error: {response['error']}")
                raise RuntimeError(response["error"])
            
            worker["logger"].info(f"[{request_id}] Successfully processed request")
            return response
            
        finally:
            # Mark as available again
            worker["busy"] = False
            await self.available_workers.put(worker)


# Initialize FastAPI
app = FastAPI(title="Claude Docker API with Logging", version="2.1")

# Initialize worker pool
worker_pool = WorkerPool(num_workers=3)


@app.on_event("startup")
async def startup_event():
    """Start worker pool on startup"""
    await worker_pool.start()
    logger.info("🚀 Claude Docker API Server started with enhanced logging")
    logger.info(f"📁 Logs directory: {LOG_DIR}")
    logger.info("📊 Individual worker logs: worker-1.log, worker-2.log, worker-3.log")


@app.on_event("shutdown")
async def shutdown_event():
    """Stop worker pool on shutdown"""
    await worker_pool.stop()


@app.get("/")
async def root():
    return {
        "service": "claude-docker-api-with-logging",
        "version": "2.1",
        "logs_directory": str(LOG_DIR),
        "log_files": [
            "api_server.log",
            "worker-1.log",
            "worker-2.log", 
            "worker-3.log"
        ]
    }


@app.get("/health")
async def health():
    worker_status = []
    for worker in worker_pool.workers:
        worker_status.append({
            "id": worker["id"],
            "alive": worker["process"].returncode is None,
            "busy": worker["busy"]
        })
    
    return {
        "status": "ok",
        "workers": worker_status,
        "logs_available": True
    }


@app.post("/v1/messages")
async def create_message(request: ChatRequest):
    """Anthropic-compatible messages endpoint with logging"""
    try:
        # Convert to worker format
        messages = [{"role": msg.role, "content": msg.content} 
                   for msg in request.messages]
        
        if request.system:
            messages.insert(0, {"role": "system", "content": request.system})
        
        worker_request = {
            "messages": messages,
            "model": request.model,
            "max_tokens": request.max_tokens,
            "temperature": request.temperature,
        }
        
        if request.tools:
            worker_request["tools"] = request.tools
        
        # Process via worker
        result = await worker_pool.process_request(worker_request)
        
        # Format response
        response = ChatResponse(
            id=f"msg_{uuid.uuid4().hex[:24]}",
            content=[{"type": "text", "text": result["content"]}],
            model=request.model,
            usage={
                "input_tokens": result.get("input_tokens", 100),
                "output_tokens": result.get("output_tokens", 200)
            }
        )
        
        return response
        
    except Exception as e:
        logger.error(f"❌ API Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/logs/{worker_id}")
async def get_worker_logs(worker_id: str, lines: int = 100):
    """Retrieve specific worker logs"""
    log_file = LOG_DIR / f"{worker_id}.log"
    if not log_file.exists():
        raise HTTPException(status_code=404, detail=f"Log file for {worker_id} not found")
    
    # Read last N lines
    with open(log_file, 'r') as f:
        all_lines = f.readlines()
        recent_lines = all_lines[-lines:]
    
    return {
        "worker_id": worker_id,
        "log_file": str(log_file),
        "total_lines": len(all_lines),
        "returned_lines": len(recent_lines),
        "logs": recent_lines
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")