#!/usr/bin/env python3
"""
Supabase Integration Service
Handles data synchronization between Graphiti knowledge graph and Supabase database
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
from supabase import create_client, Client

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/supabase_integration.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Supabase Integration Service",
    description="Handles data synchronization between Graphiti knowledge graph and Supabase database",
    version="1.0.0"
)

# Configuration
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_SERVICE_KEY = os.getenv('SUPABASE_SERVICE_KEY')
GRAPHITI_SERVICE_URL = os.getenv('GRAPHITI_SERVICE_URL', 'http://graphiti-service:8080')
NEO4J_URI = os.getenv('NEO4J_URI', 'bolt://neo4j:7687')

# Initialize Supabase client
supabase_client: Optional[Client] = None

@app.on_event("startup")
async def startup_event():
    """Initialize Supabase client"""
    global supabase_client
    
    if SUPABASE_URL and SUPABASE_SERVICE_KEY:
        try:
            supabase_client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
            logger.info("Supabase client initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Supabase client: {e}")
    else:
        logger.warning("Supabase credentials not provided")

# Models
class KnowledgeEntry(BaseModel):
    id: str
    name: str
    content: str
    source: str
    timestamp: datetime
    entry_type: str

class SyncRequest(BaseModel):
    table_name: str
    data: Dict[str, Any]

class SyncResponse(BaseModel):
    status: str
    message: str
    record_id: Optional[str] = None

class HealthStatus(BaseModel):
    status: str
    timestamp: datetime
    supabase_connected: bool
    graphiti_connected: bool

@app.get("/health", response_model=HealthStatus)
async def health_check():
    """Health check endpoint"""
    supabase_connected = supabase_client is not None
    
    # Check Graphiti connection
    graphiti_connected = False
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{GRAPHITI_SERVICE_URL}/health", timeout=5)
            graphiti_connected = response.status_code == 200
    except Exception:
        pass
    
    overall_status = "healthy" if supabase_connected and graphiti_connected else "unhealthy"
    
    return HealthStatus(
        status=overall_status,
        timestamp=datetime.now(timezone.utc),
        supabase_connected=supabase_connected,
        graphiti_connected=graphiti_connected
    )

@app.post("/sync/to-supabase", response_model=SyncResponse)
async def sync_to_supabase(sync_request: SyncRequest):
    """Sync data from Graphiti to Supabase"""
    if not supabase_client:
        raise HTTPException(status_code=503, detail="Supabase client not initialized")
    
    try:
        # Insert data into Supabase table
        result = supabase_client.table(sync_request.table_name).insert(sync_request.data).execute()
        
        record_id = result.data[0]['id'] if result.data else None
        
        return SyncResponse(
            status="success",
            message=f"Data synced to {sync_request.table_name}",
            record_id=str(record_id) if record_id else None
        )
        
    except Exception as e:
        logger.error(f"Error syncing to Supabase: {e}")
        return SyncResponse(
            status="error",
            message=f"Failed to sync data: {str(e)}"
        )

@app.post("/sync/knowledge-entries")
async def sync_knowledge_entries(background_tasks: BackgroundTasks):
    """Sync recent knowledge entries from Graphiti to Supabase"""
    if not supabase_client:
        raise HTTPException(status_code=503, detail="Supabase client not initialized")
    
    try:
        # Get recent episodes from Graphiti
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{GRAPHITI_SERVICE_URL}/episodes?limit=50")
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Failed to fetch episodes from Graphiti")
            
            episodes = response.json()
        
        # Sync each episode to Supabase
        synced_count = 0
        for episode in episodes:
            try:
                knowledge_entry = {
                    'graphiti_id': episode['id'],
                    'name': episode['name'],
                    'content': episode.get('content', ''),
                    'source': 'graphiti',
                    'timestamp': datetime.now(timezone.utc).isoformat(),
                    'entry_type': episode.get('type', 'episode')
                }
                
                # Check if already exists
                existing = supabase_client.table('knowledge_entries').select('*').eq('graphiti_id', episode['id']).execute()
                
                if not existing.data:
                    # Insert new entry
                    supabase_client.table('knowledge_entries').insert(knowledge_entry).execute()
                    synced_count += 1
                
            except Exception as e:
                logger.error(f"Error syncing episode {episode['id']}: {e}")
        
        return {
            "status": "success",
            "message": f"Synced {synced_count} knowledge entries",
            "total_processed": len(episodes)
        }
        
    except Exception as e:
        logger.error(f"Error syncing knowledge entries: {e}")
        raise HTTPException(status_code=500, detail=f"Sync failed: {str(e)}")

@app.post("/sync/islamic-entities")
async def sync_islamic_entities():
    """Sync Islamic text entities to Supabase"""
    if not supabase_client:
        raise HTTPException(status_code=503, detail="Supabase client not initialized")
    
    try:
        # Search for Islamic entities in Graphiti
        async with httpx.AsyncClient() as client:
            searches = [
                "Islamic scholars",
                "Islamic texts",
                "Islamic concepts",
                "hadith",
                "Quranic verses"
            ]
            
            all_entities = []
            for search_term in searches:
                response = await client.post(
                    f"{GRAPHITI_SERVICE_URL}/search",
                    json={"query": search_term, "num_results": 20}
                )
                
                if response.status_code == 200:
                    results = response.json()
                    all_entities.extend(results)
        
        # Sync Islamic entities to Supabase
        synced_count = 0
        for entity in all_entities:
            try:
                islamic_entity = {
                    'graphiti_id': entity.get('id', ''),
                    'name': entity['name'],
                    'entity_type': entity.get('type', 'unknown'),
                    'content': entity.get('content', ''),
                    'score': entity.get('score', 0.0),
                    'source': 'graphiti_islamic',
                    'timestamp': datetime.now(timezone.utc).isoformat()
                }
                
                # Check if already exists
                existing = supabase_client.table('islamic_entities').select('*').eq('name', entity['name']).execute()
                
                if not existing.data:
                    # Insert new entity
                    supabase_client.table('islamic_entities').insert(islamic_entity).execute()
                    synced_count += 1
                
            except Exception as e:
                logger.error(f"Error syncing Islamic entity {entity['name']}: {e}")
        
        return {
            "status": "success",
            "message": f"Synced {synced_count} Islamic entities",
            "total_processed": len(all_entities)
        }
        
    except Exception as e:
        logger.error(f"Error syncing Islamic entities: {e}")
        raise HTTPException(status_code=500, detail=f"Sync failed: {str(e)}")

@app.get("/tables")
async def list_tables():
    """List available Supabase tables"""
    if not supabase_client:
        raise HTTPException(status_code=503, detail="Supabase client not initialized")
    
    try:
        # Get table information from Supabase
        tables = [
            "knowledge_entries",
            "islamic_entities",
            "project_sessions",
            "research_outputs"
        ]
        
        return {"tables": tables}
        
    except Exception as e:
        logger.error(f"Error listing tables: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list tables: {str(e)}")

@app.get("/tables/{table_name}")
async def get_table_data(table_name: str, limit: int = 10):
    """Get data from a specific table"""
    if not supabase_client:
        raise HTTPException(status_code=503, detail="Supabase client not initialized")
    
    try:
        result = supabase_client.table(table_name).select('*').limit(limit).execute()
        
        return {
            "table": table_name,
            "data": result.data,
            "count": len(result.data)
        }
        
    except Exception as e:
        logger.error(f"Error getting table data: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get table data: {str(e)}")

if __name__ == "__main__":
    port = int(os.getenv('PORT', 8083))
    uvicorn.run(
        "supabase_integration:app",
        host="0.0.0.0",
        port=port,
        log_level="info",
        reload=False
    )