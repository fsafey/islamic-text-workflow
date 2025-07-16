#!/usr/bin/env python3
"""
Graphiti Worker - stdin/stdout interface for Graphiti knowledge graph operations

This worker reads JSON requests from stdin and writes responses to stdout,
enabling Graphiti to be used as a composable component in larger pipelines.
"""

import sys
import json
import asyncio
import logging
import os
from typing import Dict, Any, List, Optional, AsyncIterator
from pathlib import Path
import yaml

from graphiti_core import Graphiti
from graphiti_core.nodes import EpisodeType
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.llm_client.anthropic_client import AnthropicClient
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.embedder.config import EmbedderConfig
from graphiti_core.embedder.voyage import VoyageEmbedder
from graphiti_core.embedder.openai import OpenAIEmbedder
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig
from graphiti_core.search import SearchConfig, SearchType


class GraphitiWorker:
    """Worker that processes Graphiti operations via stdin/stdout"""
    
    def __init__(self, config_path: Optional[str] = None, worker_id: str = "graphiti-worker"):
        self.worker_id = worker_id
        self.config = self._load_config(config_path)
        self.graphiti = None
        self._setup_logging()
        
    def _setup_logging(self):
        """Configure logging to stderr to avoid polluting stdout"""
        logging.basicConfig(
            level=logging.INFO,
            format=f'[{self.worker_id}] %(asctime)s - %(levelname)s - %(message)s',
            stream=sys.stderr
        )
        self.logger = logging.getLogger(__name__)
        
    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        """Load configuration from file or environment"""
        if config_path and Path(config_path).exists():
            with open(config_path, 'r') as f:
                return yaml.safe_load(f)
        
        # Default configuration
        return {
            'mode': os.getenv('GRAPHITI_MODE', 'generic'),
            'neo4j': {
                'uri': os.getenv('NEO4J_URI', 'bolt://localhost:7687'),
                'user': os.getenv('NEO4J_USER', 'neo4j'),
                'password': os.getenv('NEO4J_PASSWORD', 'password')
            },
            'llm': {
                'provider': os.getenv('LLM_PROVIDER', 'claude_docker'),
                'model': os.getenv('LLM_MODEL', 'claude-3-sonnet-20240229'),
                'api_key': os.getenv('LLM_API_KEY', 'local'),
                'base_url': os.getenv('LLM_BASE_URL')
            },
            'embedder': {
                'provider': os.getenv('EMBEDDER_PROVIDER', 'gemini'),
                'model': os.getenv('EMBEDDER_MODEL', 'models/text-embedding-004'),
                'api_key': os.getenv('EMBEDDER_API_KEY', os.getenv('GOOGLE_API_KEY'))
            }
        }
    
    async def initialize(self):
        """Initialize Graphiti instance"""
        try:
            # Create LLM client
            llm_config = LLMConfig(
                api_key=self.config['llm']['api_key'],
                model=self.config['llm']['model'],
                base_url=self.config['llm'].get('base_url')
            )
            
            if self.config['llm']['provider'] == 'claude_docker':
                llm_client = ClaudeDockerClient(llm_config)
            elif self.config['llm']['provider'] == 'anthropic':
                llm_client = AnthropicClient(llm_config)
            else:
                raise ValueError(f"Unsupported LLM provider: {self.config['llm']['provider']}")
            
            # Create embedder
            if self.config['embedder']['provider'] == 'gemini':
                embedder_config = GeminiEmbedderConfig(
                    api_key=self.config['embedder']['api_key'],
                    model=self.config['embedder']['model']
                )
                embedder = GeminiEmbedder(embedder_config)
            elif self.config['embedder']['provider'] == 'openai':
                embedder_config = EmbedderConfig(
                    api_key=self.config['embedder']['api_key'],
                    model=self.config['embedder']['model']
                )
                embedder = OpenAIEmbedder(embedder_config)
            else:
                raise ValueError(f"Unsupported embedder provider: {self.config['embedder']['provider']}")
            
            # Initialize Graphiti
            self.graphiti = Graphiti(
                uri=self.config['neo4j']['uri'],
                user=self.config['neo4j']['user'],
                password=self.config['neo4j']['password'],
                llm_client=llm_client,
                embedder=embedder
            )
            
            # Build indices
            await self.graphiti.build_indices_and_constraints()
            
            self.logger.info(f"Initialized Graphiti worker with mode: {self.config['mode']}")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize Graphiti: {e}")
            raise
    
    async def run(self):
        """Main loop: read from stdin, process, write to stdout"""
        
        self.logger.info(f"🚀 Graphiti Worker {self.worker_id} started")
        self.logger.info(f"📥 Reading from stdin, writing to stdout")
        
        # Initialize Graphiti
        await self.initialize()
        
        # Process lines from stdin
        loop = asyncio.get_event_loop()
        reader = asyncio.StreamReader()
        protocol = asyncio.StreamReaderProtocol(reader)
        await loop.connect_read_pipe(lambda: protocol, sys.stdin)
        
        while True:
            try:
                line_bytes = await reader.readline()
                if not line_bytes:
                    break
                    
                line = line_bytes.decode().strip()
                if not line:
                    continue
                
                # Parse request
                request = json.loads(line)
                
                # Process with Graphiti
                response = await self.process_request(request)
                
                # Handle streaming responses
                if asyncio.iscoroutine(response) or hasattr(response, '__aiter__'):
                    async for chunk in response:
                        print(json.dumps(chunk))
                        sys.stdout.flush()
                else:
                    # Write single response
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
                    "error": f"Worker error: {str(e)}",
                    "worker_id": self.worker_id
                }
                print(json.dumps(error_response))
                sys.stdout.flush()
    
    async def process_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
        """Process a single request with Graphiti"""
        
        request_id = request.get('id', 'unknown')
        operation = request.get('operation')
        params = request.get('params', {})
        
        self.logger.info(f"Processing request {request_id}: {operation}")
        
        try:
            # Route to appropriate handler
            if operation == 'add_episode':
                return await self._handle_add_episode(request_id, params)
            
            elif operation == 'add_episode_bulk':
                # This returns an async generator for streaming
                return self._handle_add_episode_bulk(request_id, params)
            
            elif operation == 'search':
                return await self._handle_search(request_id, params)
            
            elif operation == 'add_triplet':
                return await self._handle_add_triplet(request_id, params)
            
            elif operation == 'build_communities':
                return await self._handle_build_communities(request_id, params)
            
            elif operation == 'get_entity':
                return await self._handle_get_entity(request_id, params)
            
            elif operation == 'get_edges_by_entity':
                return await self._handle_get_edges_by_entity(request_id, params)
            
            elif operation == 'remove_episode':
                return await self._handle_remove_episode(request_id, params)
            
            elif operation == 'retrieve_episodes':
                return await self._handle_retrieve_episodes(request_id, params)
            
            elif operation == 'health_check':
                return {"id": request_id, "status": "healthy", "worker_id": self.worker_id}
            
            else:
                return {
                    "id": request_id,
                    "status": "error",
                    "error": f"Unknown operation: {operation}"
                }
                
        except Exception as e:
            self.logger.error(f"Error processing request {request_id}: {e}")
            return {
                "id": request_id,
                "status": "error",
                "error": str(e)
            }
    
    async def _handle_add_episode(self, request_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle add_episode operation"""
        episode_type = EpisodeType[params.get('episode_type', 'text').upper()]
        
        result = await self.graphiti.add_episode(
            name=params['name'],
            episode_body=params['episode_body'],
            source_description=params.get('source_description'),
            episode_type=episode_type,
            group_id=params.get('group_id'),
            entity_types=params.get('entity_types'),
            edge_types=params.get('edge_types'),
            edge_type_map=params.get('edge_type_map')
        )
        
        return {
            "id": request_id,
            "status": "success",
            "result": {
                "episode": {
                    "uuid": result.uuid,
                    "name": result.name,
                    "created_at": result.created_at.isoformat() if result.created_at else None
                },
                "nodes_created": len(result.nodes) if hasattr(result, 'nodes') else 0,
                "edges_created": len(result.edges) if hasattr(result, 'edges') else 0
            }
        }
    
    async def _handle_add_episode_bulk(self, request_id: str, params: Dict[str, Any]) -> AsyncIterator[Dict[str, Any]]:
        """Handle bulk episode addition with streaming results"""
        episodes = params['episodes']
        batch_size = params.get('batch_size', 10)
        
        total = len(episodes)
        processed = 0
        
        async for episode_result in self.graphiti.add_episode_bulk(
            episodes=episodes,
            batch_size=batch_size
        ):
            processed += 1
            yield {
                "id": request_id,
                "status": "progress",
                "progress": {
                    "processed": processed,
                    "total": total,
                    "percentage": (processed / total) * 100
                },
                "result": {
                    "episode": {
                        "uuid": episode_result.uuid,
                        "name": episode_result.name
                    }
                }
            }
        
        yield {
            "id": request_id,
            "status": "completed",
            "result": {
                "total_processed": processed
            }
        }
    
    async def _handle_search(self, request_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle search operation"""
        search_type = SearchType[params.get('search_type', 'NODE_HYBRID_SEARCH_RRF')]
        
        config = SearchConfig(
            search_type=search_type,
            center_node_uuid=params.get('center_node_uuid'),
            num_neighbors=params.get('num_neighbors', 10),
            radius=params.get('radius', 2),
            num_episodes=params.get('num_episodes', 5)
        )
        
        results = await self.graphiti.search(
            query=params['query'],
            num_results=params.get('num_results', 10),
            search_config=config
        )
        
        # Serialize results
        serialized_results = []
        for result in results:
            if hasattr(result, '__dict__'):
                serialized_results.append(result.__dict__)
            else:
                serialized_results.append(str(result))
        
        return {
            "id": request_id,
            "status": "success",
            "result": {
                "query": params['query'],
                "count": len(results),
                "results": serialized_results
            }
        }
    
    async def _handle_add_triplet(self, request_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle manual triplet addition"""
        # This would need proper entity/edge construction from params
        # Simplified for now
        return {
            "id": request_id,
            "status": "success",
            "result": {
                "message": "Triplet addition not yet implemented"
            }
        }
    
    async def _handle_build_communities(self, request_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle community building"""
        await self.graphiti.build_communities()
        
        return {
            "id": request_id,
            "status": "success",
            "result": {
                "message": "Communities built successfully"
            }
        }
    
    async def _handle_get_entity(self, request_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle entity retrieval"""
        entity = await self.graphiti.get_entity(params['entity_name'])
        
        if entity:
            return {
                "id": request_id,
                "status": "success",
                "result": {
                    "entity": entity.__dict__ if hasattr(entity, '__dict__') else str(entity)
                }
            }
        else:
            return {
                "id": request_id,
                "status": "not_found",
                "result": None
            }
    
    async def _handle_get_edges_by_entity(self, request_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle edge retrieval by entity"""
        edges = await self.graphiti.get_edges_by_entity_id(params['entity_id'])
        
        return {
            "id": request_id,
            "status": "success",
            "result": {
                "count": len(edges),
                "edges": [edge.__dict__ if hasattr(edge, '__dict__') else str(edge) for edge in edges]
            }
        }
    
    async def _handle_remove_episode(self, request_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle episode removal"""
        await self.graphiti.remove_episode(params['episode_id'])
        
        return {
            "id": request_id,
            "status": "success",
            "result": {
                "message": f"Episode {params['episode_id']} removed"
            }
        }
    
    async def _handle_retrieve_episodes(self, request_id: str, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle episode retrieval"""
        episodes = await self.graphiti.retrieve_episodes(
            group_ids=params.get('group_ids'),
            reference_time=params.get('reference_time'),
            last_n=params.get('last_n')
        )
        
        return {
            "id": request_id,
            "status": "success",
            "result": {
                "count": len(episodes),
                "episodes": [
                    {
                        "uuid": ep.uuid,
                        "name": ep.name,
                        "created_at": ep.created_at.isoformat() if ep.created_at else None
                    } for ep in episodes
                ]
            }
        }


def main():
    """Entry point for the worker"""
    
    # Get configuration from environment or arguments
    config_path = os.environ.get('GRAPHITI_CONFIG_PATH')
    worker_id = os.environ.get('WORKER_ID', 'graphiti-worker-1')
    
    # Create and run worker
    worker = GraphitiWorker(config_path=config_path, worker_id=worker_id)
    
    try:
        # Run the async worker
        asyncio.run(worker.run())
    except KeyboardInterrupt:
        worker.logger.info(f"✅ Worker {worker_id} stopped")
    except Exception as e:
        worker.logger.error(f"❌ Worker {worker_id} crashed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()