#!/usr/bin/env python3
"""
Graphiti Monitoring Service
Provides monitoring and management dashboard for the Graphiti stack
"""

import asyncio
import logging
import os
from datetime import datetime, timezone
from typing import Dict, List, Optional, Any

import uvicorn
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel
import httpx
from neo4j import GraphDatabase

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/monitor.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Graphiti Monitoring Service",
    description="Monitoring and management dashboard for the Graphiti stack",
    version="1.0.0"
)

# Initialize templates
templates = Jinja2Templates(directory="templates")

# Configuration
NEO4J_URI = os.getenv('NEO4J_URI', 'bolt://neo4j:7687')
NEO4J_USER = os.getenv('NEO4J_USER', 'neo4j')
NEO4J_PASSWORD = os.getenv('NEO4J_PASSWORD', 'password')
CLAUDE_DOCKER_API_URL = os.getenv('CLAUDE_DOCKER_API_URL', 'http://claude-docker-api:8000')
GRAPHITI_SERVICE_URL = os.getenv('GRAPHITI_SERVICE_URL', 'http://graphiti-service:8080')

# Models
class ServiceStatus(BaseModel):
    name: str
    status: str
    url: str
    response_time: Optional[float] = None
    last_check: datetime

class SystemMetrics(BaseModel):
    neo4j_nodes: int
    neo4j_relationships: int
    neo4j_databases: List[str]
    claude_workers: int
    recent_episodes: int
    system_health: str

class HealthStatus(BaseModel):
    status: str
    timestamp: datetime
    services: List[ServiceStatus]
    metrics: SystemMetrics

# Neo4j driver
driver = None

async def init_neo4j():
    """Initialize Neo4j connection"""
    global driver
    try:
        driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
        logger.info("Neo4j connection initialized")
    except Exception as e:
        logger.error(f"Failed to initialize Neo4j: {e}")

async def close_neo4j():
    """Close Neo4j connection"""
    global driver
    if driver:
        driver.close()
        logger.info("Neo4j connection closed")

@app.on_event("startup")
async def startup_event():
    await init_neo4j()

@app.on_event("shutdown")
async def shutdown_event():
    await close_neo4j()

async def check_service_health(name: str, url: str) -> ServiceStatus:
    """Check health of a service"""
    start_time = datetime.now()
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{url}/health", timeout=5)
            response_time = (datetime.now() - start_time).total_seconds()
            
            return ServiceStatus(
                name=name,
                status="healthy" if response.status_code == 200 else "unhealthy",
                url=url,
                response_time=response_time,
                last_check=datetime.now(timezone.utc)
            )
    except Exception as e:
        return ServiceStatus(
            name=name,
            status=f"unhealthy: {str(e)}",
            url=url,
            response_time=None,
            last_check=datetime.now(timezone.utc)
        )

async def get_neo4j_metrics() -> Dict[str, Any]:
    """Get Neo4j metrics"""
    global driver
    metrics = {
        "nodes": 0,
        "relationships": 0,
        "databases": []
    }
    
    if not driver:
        return metrics
    
    try:
        with driver.session() as session:
            # Get node count
            result = session.run("MATCH (n) RETURN count(n) as count")
            metrics["nodes"] = result.single()["count"]
            
            # Get relationship count
            result = session.run("MATCH ()-[r]->() RETURN count(r) as count")
            metrics["relationships"] = result.single()["count"]
            
            # Get database list
            result = session.run("SHOW DATABASES")
            metrics["databases"] = [record["name"] for record in result]
            
    except Exception as e:
        logger.error(f"Failed to get Neo4j metrics: {e}")
    
    return metrics

@app.get("/health", response_model=HealthStatus)
async def health_check():
    """Comprehensive health check"""
    # Check all services
    services = [
        await check_service_health("Neo4j", "http://neo4j:7474"),
        await check_service_health("Claude Docker API", CLAUDE_DOCKER_API_URL),
        await check_service_health("Graphiti Service", GRAPHITI_SERVICE_URL)
    ]
    
    # Get metrics
    neo4j_metrics = await get_neo4j_metrics()
    
    # Get recent episodes count
    recent_episodes = 0
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{GRAPHITI_SERVICE_URL}/episodes?limit=10")
            if response.status_code == 200:
                recent_episodes = len(response.json())
    except Exception as e:
        logger.error(f"Failed to get recent episodes: {e}")
    
    metrics = SystemMetrics(
        neo4j_nodes=neo4j_metrics["nodes"],
        neo4j_relationships=neo4j_metrics["relationships"],
        neo4j_databases=neo4j_metrics["databases"],
        claude_workers=3,  # Fixed for now
        recent_episodes=recent_episodes,
        system_health="healthy" if all(s.status == "healthy" for s in services) else "unhealthy"
    )
    
    return HealthStatus(
        status=metrics.system_health,
        timestamp=datetime.now(timezone.utc),
        services=services,
        metrics=metrics
    )

@app.get("/", response_class=HTMLResponse)
async def dashboard(request: Request):
    """Main monitoring dashboard"""
    health_status = await health_check()
    
    return templates.TemplateResponse("dashboard.html", {
        "request": request,
        "health_status": health_status,
        "title": "Graphiti Monitoring Dashboard"
    })

@app.get("/metrics")
async def get_metrics():
    """Get system metrics"""
    health_status = await health_check()
    return health_status.metrics

@app.get("/services")
async def get_services():
    """Get service status"""
    health_status = await health_check()
    return health_status.services

@app.get("/logs/{service}")
async def get_logs(service: str, lines: int = 100):
    """Get logs for a specific service"""
    log_paths = {
        "neo4j": "/neo4j-logs/neo4j.log",
        "claude": "/claude-logs/claude_docker_api.log",
        "graphiti": "/app/logs/graphiti_service.log"
    }
    
    if service not in log_paths:
        raise HTTPException(status_code=404, detail="Service not found")
    
    log_path = log_paths[service]
    
    try:
        with open(log_path, 'r') as f:
            all_lines = f.readlines()
            return {"logs": all_lines[-lines:] if len(all_lines) > lines else all_lines}
    except FileNotFoundError:
        return {"logs": [f"Log file not found: {log_path}"]}
    except Exception as e:
        return {"logs": [f"Error reading logs: {str(e)}"]}

if __name__ == "__main__":
    port = int(os.getenv('PORT', 8082))
    uvicorn.run(
        "monitor_service:app",
        host="0.0.0.0",
        port=port,
        log_level="info",
        reload=False
    )