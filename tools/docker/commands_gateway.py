#!/usr/bin/env python3
"""
Enhanced Commands API Gateway
Routes enhanced Graphiti commands to appropriate services
"""

import asyncio
import logging
import os
from datetime import datetime, timezone
from typing import Dict, List, Optional, Any

import uvicorn
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
import httpx

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/commands_gateway.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Enhanced Commands API Gateway",
    description="Routes enhanced Graphiti commands to appropriate services",
    version="1.0.0"
)

# Service URLs
GRAPHITI_SERVICE_URL = os.getenv('GRAPHITI_SERVICE_URL', 'http://graphiti-service:8080')
CLAUDE_DOCKER_API_URL = os.getenv('CLAUDE_DOCKER_API_URL', 'http://claude-docker-api:8000')
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_SERVICE_KEY = os.getenv('SUPABASE_SERVICE_KEY')

# Request/Response Models
class CommandRequest(BaseModel):
    command: str
    args: List[str] = []
    kwargs: Dict[str, Any] = {}

class CommandResponse(BaseModel):
    command: str
    status: str
    result: Any
    timestamp: datetime

class HealthStatus(BaseModel):
    status: str
    timestamp: datetime
    services: Dict[str, str]

@app.get("/health", response_model=HealthStatus)
async def health_check():
    """Health check endpoint"""
    services = {
        "graphiti_service": "unknown",
        "claude_docker_api": "unknown",
        "supabase": "unknown"
    }
    
    # Check Graphiti Service
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{GRAPHITI_SERVICE_URL}/health", timeout=5)
            services["graphiti_service"] = "healthy" if response.status_code == 200 else "unhealthy"
    except Exception as e:
        services["graphiti_service"] = f"unhealthy: {str(e)}"
    
    # Check Claude Docker API
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{CLAUDE_DOCKER_API_URL}/health", timeout=5)
            services["claude_docker_api"] = "healthy" if response.status_code == 200 else "unhealthy"
    except Exception as e:
        services["claude_docker_api"] = f"unhealthy: {str(e)}"
    
    # Check Supabase (if configured)
    if SUPABASE_URL and SUPABASE_SERVICE_KEY:
        try:
            async with httpx.AsyncClient() as client:
                headers = {"Authorization": f"Bearer {SUPABASE_SERVICE_KEY}"}
                response = await client.get(f"{SUPABASE_URL}/rest/v1/", headers=headers, timeout=5)
                services["supabase"] = "healthy" if response.status_code == 200 else "unhealthy"
        except Exception as e:
            services["supabase"] = f"unhealthy: {str(e)}"
    else:
        services["supabase"] = "not_configured"
    
    overall_status = "healthy" if all(s in ["healthy", "not_configured"] for s in services.values()) else "unhealthy"
    
    return HealthStatus(
        status=overall_status,
        timestamp=datetime.now(timezone.utc),
        services=services
    )

@app.post("/commands", response_model=CommandResponse)
async def execute_command(command_request: CommandRequest):
    """Execute enhanced Graphiti command"""
    try:
        command = command_request.command
        args = command_request.args
        kwargs = command_request.kwargs
        
        logger.info(f"Executing command: {command} with args: {args}")
        
        # Route commands to appropriate services
        if command == "gr":  # Remember
            result = await execute_remember(args[0] if args else "")
        elif command == "gs":  # Search
            result = await execute_search(args[0] if args else "")
        elif command == "gt":  # Text analysis
            result = await execute_text_analysis(args[0] if args else "")
        elif command == "gst":  # Status
            result = await execute_status()
        elif command.startswith("p"):  # Project commands
            result = await execute_project_command(command, args, kwargs)
        else:
            raise HTTPException(status_code=400, detail=f"Unknown command: {command}")
        
        return CommandResponse(
            command=command,
            status="success",
            result=result,
            timestamp=datetime.now(timezone.utc)
        )
        
    except Exception as e:
        logger.error(f"Command execution failed: {e}")
        return CommandResponse(
            command=command_request.command,
            status="error",
            result={"error": str(e)},
            timestamp=datetime.now(timezone.utc)
        )

async def execute_remember(info: str) -> Dict[str, Any]:
    """Execute gr command - remember information"""
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{GRAPHITI_SERVICE_URL}/episodes",
            json={
                "name": f"Manual Entry: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
                "episode_body": info,
                "source_description": "Manual entry via gr command",
                "episode_type": "manual_entry"
            }
        )
        response.raise_for_status()
        return response.json()

async def execute_search(query: str) -> Dict[str, Any]:
    """Execute gs command - search knowledge graph"""
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{GRAPHITI_SERVICE_URL}/search",
            json={
                "query": query,
                "num_results": 10
            }
        )
        response.raise_for_status()
        return response.json()

async def execute_text_analysis(text_or_file: str) -> Dict[str, Any]:
    """Execute gt command - analyze text"""
    # Check if it's a file path
    if text_or_file.startswith("/") or text_or_file.endswith(".txt"):
        # File analysis
        try:
            with open(text_or_file, 'r', encoding='utf-8') as f:
                content = f.read()
            file_name = os.path.basename(text_or_file)
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{GRAPHITI_SERVICE_URL}/episodes",
                    json={
                        "name": f"File Analysis: {file_name}",
                        "episode_body": content,
                        "source_description": f"File analysis via gt command: {file_name}",
                        "episode_type": "file_analysis"
                    }
                )
                response.raise_for_status()
                return response.json()
        except Exception as e:
            return {"error": f"Failed to read file: {str(e)}"}
    else:
        # Direct text analysis
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{GRAPHITI_SERVICE_URL}/episodes",
                json={
                    "name": f"Text Analysis: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
                    "episode_body": text_or_file,
                    "source_description": "Direct text analysis via gt command",
                    "episode_type": "text_analysis"
                }
            )
            response.raise_for_status()
            return response.json()

async def execute_status() -> Dict[str, Any]:
    """Execute gst command - get system status"""
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{GRAPHITI_SERVICE_URL}/health")
        response.raise_for_status()
        return response.json()

async def execute_project_command(command: str, args: List[str], kwargs: Dict[str, Any]) -> Dict[str, Any]:
    """Execute project-related commands"""
    if command == "pstart":
        session_name = args[0] if args else "unnamed_session"
        return await execute_remember(f"PROJECT SESSION START: {session_name} - Started at {datetime.now()}")
    elif command == "pdecision":
        decision = args[0] if args else "no_decision"
        return await execute_remember(f"PROJECT DECISION: {decision} - Timestamp: {datetime.now()}")
    elif command == "pfeature":
        feature = args[0] if args else "no_feature"
        status = args[1] if len(args) > 1 else "unknown"
        return await execute_remember(f"PROJECT FEATURE: {feature} - Status: {status} - Timestamp: {datetime.now()}")
    elif command == "psearch":
        query = args[0] if args else ""
        return await execute_search(f"PROJECT: {query}")
    elif command == "poverview":
        # Get recent project entries
        recent_sessions = await execute_search("PROJECT SESSION")
        recent_decisions = await execute_search("PROJECT DECISION")
        recent_features = await execute_search("PROJECT FEATURE")
        
        return {
            "sessions": recent_sessions,
            "decisions": recent_decisions,
            "features": recent_features
        }
    else:
        raise HTTPException(status_code=400, detail=f"Unknown project command: {command}")

if __name__ == "__main__":
    port = int(os.getenv('PORT', 8090))
    uvicorn.run(
        "commands_gateway:app",
        host="0.0.0.0",
        port=port,
        log_level="info",
        reload=False
    )