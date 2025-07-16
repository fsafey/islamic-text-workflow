#!/usr/bin/env python3
"""
Graphiti Service API - Core knowledge graph processing service
Provides REST API endpoints for Graphiti operations in containerized environment
"""

import asyncio
import logging
import os
import sys
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from typing import Dict, List, Optional, Any

import uvicorn
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel, Field

# Add project paths
sys.path.append('/app')
sys.path.append('/app/graphiti_core')

from graphiti_core import Graphiti
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig
from graphiti_core.search.search_config_recipes import NODE_HYBRID_SEARCH_RRF

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/graphiti_service.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Global Graphiti instance
graphiti_instance: Optional[Graphiti] = None

# Request/Response Models
class EpisodeRequest(BaseModel):
    name: str
    episode_body: str
    source_description: Optional[str] = None
    episode_type: str = "text"

class SearchRequest(BaseModel):
    query: str
    num_results: int = 10
    
class SearchResult(BaseModel):
    name: str
    score: float
    type: str
    summary: Optional[str] = None
    content: Optional[str] = None

class HealthStatus(BaseModel):
    status: str
    timestamp: datetime
    services: Dict[str, str]
    
class EpisodeResponse(BaseModel):
    id: str
    name: str
    status: str
    message: str

class GraphStats(BaseModel):
    total_nodes: int
    total_edges: int
    recent_episodes: List[str]
    
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize Graphiti on startup"""
    global graphiti_instance
    
    try:
        logger.info("Initializing Graphiti Service...")
        
        # Configure Claude Docker client
        llm_config = LLMConfig(
            api_key="not-needed",
            model="claude-sonnet-4-0",
            temperature=0.3,
            max_tokens=2000
        )
        
        # Configure embeddings
        google_api_key = os.getenv('GOOGLE_API_KEY')
        if not google_api_key:
            raise ValueError("GOOGLE_API_KEY environment variable is required")
            
        gemini_config = GeminiEmbedderConfig(
            api_key=google_api_key,
            embedding_model="models/text-embedding-004"
        )
        
        # Initialize Graphiti with containerized settings
        neo4j_uri = os.getenv('NEO4J_URI', 'bolt://neo4j:7687')
        neo4j_user = os.getenv('NEO4J_USER', 'neo4j')
        neo4j_password = os.getenv('NEO4J_PASSWORD', 'password')
        
        # Configure Claude Docker API URL
        claude_api_url = os.getenv('CLAUDE_DOCKER_API_URL', 'http://claude-docker-api:8000')
        
        graphiti_instance = Graphiti(
            uri=neo4j_uri,
            user=neo4j_user,
            password=neo4j_password,
            llm_client=ClaudeDockerClient(llm_config, base_url=claude_api_url),
            embedder=GeminiEmbedder(gemini_config)
        )
        
        # Build indices and constraints
        await graphiti_instance.build_indices_and_constraints()
        
        logger.info("Graphiti Service initialized successfully")
        
    except Exception as e:
        logger.error(f"Failed to initialize Graphiti: {e}")
        raise
    
    yield
    
    # Cleanup
    if graphiti_instance:
        logger.info("Shutting down Graphiti Service...")

# Create FastAPI app
app = FastAPI(
    title="Graphiti Service API",
    description="Core knowledge graph processing service for Graphiti",
    version="1.0.0",
    lifespan=lifespan
)

@app.get("/health", response_model=HealthStatus)
async def health_check():
    """Health check endpoint"""
    global graphiti_instance
    
    services = {
        "graphiti": "healthy" if graphiti_instance else "unhealthy",
        "neo4j": "unknown",
        "claude_docker": "unknown"
    }
    
    # Test Neo4j connection
    try:
        if graphiti_instance:
            # Simple test query
            await graphiti_instance.search("test", num_results=1)
            services["neo4j"] = "healthy"
    except Exception as e:
        services["neo4j"] = f"unhealthy: {str(e)}"
    
    # Test Claude Docker API
    try:
        claude_api_url = os.getenv('CLAUDE_DOCKER_API_URL', 'http://claude-docker-api:8000')
        import httpx
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{claude_api_url}/health", timeout=5)
            if response.status_code == 200:
                services["claude_docker"] = "healthy"
            else:
                services["claude_docker"] = f"unhealthy: status {response.status_code}"
    except Exception as e:
        services["claude_docker"] = f"unhealthy: {str(e)}"
    
    overall_status = "healthy" if all(s == "healthy" for s in services.values()) else "unhealthy"
    
    return HealthStatus(
        status=overall_status,
        timestamp=datetime.now(timezone.utc),
        services=services
    )

@app.post("/episodes", response_model=EpisodeResponse)
async def add_episode(episode: EpisodeRequest, background_tasks: BackgroundTasks):
    """Add a new episode to the knowledge graph"""
    global graphiti_instance
    
    if not graphiti_instance:
        raise HTTPException(status_code=503, detail="Graphiti service not initialized")
    
    try:
        logger.info(f"Adding episode: {episode.name}")
        
        # Add episode to knowledge graph
        result = await graphiti_instance.add_episode(
            name=episode.name,
            episode_body=episode.episode_body,
            source_description=episode.source_description or "API Request",
            episode_type=episode.episode_type,
            timestamp=datetime.now(timezone.utc)
        )
        
        logger.info(f"Episode added successfully: {result.name}")
        
        return EpisodeResponse(
            id=str(result.uuid),
            name=result.name,
            status="success",
            message=f"Episode '{episode.name}' added successfully"
        )
        
    except Exception as e:
        logger.error(f"Error adding episode: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to add episode: {str(e)}")

@app.post("/search", response_model=List[SearchResult])
async def search_knowledge_graph(search: SearchRequest):
    """Search the knowledge graph"""
    global graphiti_instance
    
    if not graphiti_instance:
        raise HTTPException(status_code=503, detail="Graphiti service not initialized")
    
    try:
        logger.info(f"Searching for: {search.query}")
        
        # Perform search
        results = await graphiti_instance.search(
            query=search.query,
            num_results=search.num_results
        )
        
        # Convert to response format
        search_results = []
        for result in results:
            search_results.append(SearchResult(
                name=result.name,
                score=result.score,
                type=result.type,
                summary=getattr(result, 'summary', None),
                content=getattr(result, 'content', None)
            ))
        
        logger.info(f"Search completed: {len(search_results)} results")
        return search_results
        
    except Exception as e:
        logger.error(f"Error searching: {e}")
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@app.get("/stats", response_model=GraphStats)
async def get_graph_stats():
    """Get knowledge graph statistics"""
    global graphiti_instance
    
    if not graphiti_instance:
        raise HTTPException(status_code=503, detail="Graphiti service not initialized")
    
    try:
        # Get recent episodes
        episodes = await graphiti_instance.get_episodes(limit=10)
        recent_episodes = [ep.name for ep in episodes]
        
        # Get basic stats (this would need actual implementation)
        stats = GraphStats(
            total_nodes=len(recent_episodes),  # Placeholder
            total_edges=0,  # Placeholder
            recent_episodes=recent_episodes
        )
        
        return stats
        
    except Exception as e:
        logger.error(f"Error getting stats: {e}")
        raise HTTPException(status_code=500, detail=f"Stats failed: {str(e)}")

@app.get("/episodes")
async def get_episodes(limit: int = 10):
    """Get recent episodes"""
    global graphiti_instance
    
    if not graphiti_instance:
        raise HTTPException(status_code=503, detail="Graphiti service not initialized")
    
    try:
        episodes = await graphiti_instance.get_episodes(limit=limit)
        return [{"id": str(ep.uuid), "name": ep.name, "type": ep.episode_type} for ep in episodes]
        
    except Exception as e:
        logger.error(f"Error getting episodes: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get episodes: {str(e)}")

if __name__ == "__main__":
    port = int(os.getenv('PORT', 8080))
    uvicorn.run(
        "graphiti_service_api:app",
        host="0.0.0.0",
        port=port,
        log_level="info",
        reload=False
    )