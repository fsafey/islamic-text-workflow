#!/usr/bin/env python3
"""
Graphiti MCP Server with Claude Docker Support
This version uses Claude Docker for LLM operations instead of OpenAI
"""

import argparse
import asyncio
import logging
import os
import sys
from datetime import datetime, timezone
from typing import Any

from dotenv import load_dotenv
from mcp.server.fastmcp import FastMCP
from pydantic import BaseModel, Field

# Add parent directories to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from graphiti_core import Graphiti
from graphiti_core.edges import EntityEdge
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.nodes import EpisodeType, EpisodicNode
from graphiti_core.search.search_config_recipes import (
    NODE_HYBRID_SEARCH_NODE_DISTANCE,
    NODE_HYBRID_SEARCH_RRF,
)
from graphiti_core.search.search_filters import SearchFilters
from graphiti_core.utils.maintenance.graph_data_operations import clear_data

load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Default models for Claude Docker
DEFAULT_CLAUDE_MODEL = 'claude-3-sonnet-20240229'
DEFAULT_EMBEDDER_MODEL = 'models/text-embedding-004'

# Semaphore limit for concurrent operations
SEMAPHORE_LIMIT = int(os.getenv('SEMAPHORE_LIMIT', 5))


class Requirement(BaseModel):
    """A Requirement represents a specific need, feature, or functionality."""
    project_name: str = Field(..., description='The name of the project')
    description: str = Field(..., description='Description of the requirement')


class Preference(BaseModel):
    """A Preference represents a user's expressed preference."""
    category: str = Field(..., description="Category (e.g., 'Brands', 'Food', 'Music')")
    description: str = Field(..., description='Brief description of the preference')


class Procedure(BaseModel):
    """A Procedure represents a method or process for accomplishing a task."""
    category: str = Field(..., description="Category (e.g., 'Development', 'Research')")
    description: str = Field(..., description='Brief description of the procedure')
    steps: list[str] = Field(..., description='List of steps in the procedure')


# Additional project tracking entity types
class ProjectSession(BaseModel):
    """A development work session."""
    session_name: str = Field(..., description='Name/ID of the work session')
    summary: str = Field(..., description='Summary of work accomplished')
    branch: str = Field(default='main', description='Git branch worked on')

class ProjectDecision(BaseModel):
    """A technical or architectural decision made during development."""
    decision: str = Field(..., description='Description of the decision made')
    rationale: str = Field(..., description='Reasoning behind the decision')
    impact: str = Field(default='medium', description='Expected impact: low|medium|high')

class ProjectFeature(BaseModel):
    """A feature being developed."""
    feature_name: str = Field(..., description='Name of the feature')
    description: str = Field(..., description='Description of the feature')
    status: str = Field(default='planned', description='Status: planned|in-progress|completed|blocked')

class ProjectProblem(BaseModel):
    """A problem encountered during development."""
    problem: str = Field(..., description='Description of the problem')
    solution: str = Field(default='pending', description='Solution or workaround found')
    severity: str = Field(default='medium', description='Severity: low|medium|high|critical')

class CodeChange(BaseModel):
    """A code change or modification."""
    file_path: str = Field(..., description='Path to the modified file')
    change_type: str = Field(..., description='Type: added|modified|deleted|refactored')
    description: str = Field(..., description='Description of the change')

# Entity types configuration
ENTITY_TYPES = {
    'Requirement': Requirement,
    'Preference': Preference,
    'Procedure': Procedure,
    'ProjectSession': ProjectSession,
    'ProjectDecision': ProjectDecision,
    'ProjectFeature': ProjectFeature,
    'ProjectProblem': ProjectProblem,
    'CodeChange': CodeChange,
}


class GraphitiMCPServerClaudeDocker:
    """MCP Server for Graphiti using Claude Docker"""
    
    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.graphiti: Graphiti | None = None
        self.mcp_server = FastMCP('graphiti-claude-docker', version='0.1.0')
        self.setup_tools()
        
    async def initialize_graphiti(self):
        """Initialize Graphiti with Claude Docker"""
        try:
            # Configure Claude Docker client
            llm_config = LLMConfig(
                api_key="not-needed",
                model=self.args.model or DEFAULT_CLAUDE_MODEL,
                temperature=self.args.temperature,
                max_tokens=2000
            )
            
            # Configure Gemini embedder
            embedder_config = GeminiEmbedderConfig(
                api_key=os.getenv('GOOGLE_API_KEY'),
                model=DEFAULT_EMBEDDER_MODEL
            )
            
            # Initialize Graphiti
            self.graphiti = Graphiti(
                uri=os.getenv('NEO4J_URI', 'bolt://localhost:7687'),
                user=os.getenv('NEO4J_USER', 'neo4j'),
                password=os.getenv('NEO4J_PASSWORD', 'password'),
                llm_client=ClaudeDockerClient(llm_config),
                embedder=GeminiEmbedder(embedder_config)
            )
            
            # Build indices
            await self.graphiti.build_indices_and_constraints()
            
            logger.info("Graphiti initialized with Claude Docker successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize Graphiti: {e}")
            raise
    
    def setup_tools(self):
        """Set up MCP tools"""
        
        @self.mcp_server.tool()
        async def add_episode(
            name: str,
            episode_body: str,
            source: str = 'message',
            source_description: str | None = None,
            reference_time: str | None = None
        ) -> dict[str, Any]:
            """Add an episode to the knowledge graph"""
            
            if not self.graphiti:
                await self.initialize_graphiti()
            
            try:
                # Parse episode type
                episode_type = EpisodeType[source.upper()]
                
                # Parse reference time if provided
                parsed_time = None
                if reference_time:
                    parsed_time = datetime.fromisoformat(reference_time.replace('Z', '+00:00'))
                
                # Determine entity types
                entity_types = ENTITY_TYPES if self.args.use_custom_entities else None
                
                # Add episode
                result = await self.graphiti.add_episode(
                    name=name,
                    episode_body=episode_body,
                    source_description=source_description,
                    episode_type=episode_type,
                    group_id=self.args.group_id,
                    reference_time=parsed_time,
                    entity_types=entity_types
                )
                
                return {
                    'success': True,
                    'episode_id': result.uuid,
                    'name': result.name,
                    'created_at': result.created_at.isoformat() if result.created_at else None
                }
                
            except Exception as e:
                logger.error(f"Error adding episode: {e}")
                return {'success': False, 'error': str(e)}
        
        @self.mcp_server.tool()
        async def search_nodes(
            query: str,
            num_results: int = 10,
            entity_types: list[str] | None = None
        ) -> dict[str, Any]:
            """Search the knowledge graph for relevant node summaries"""
            
            if not self.graphiti:
                await self.initialize_graphiti()
            
            try:
                # Create search filters
                filters = SearchFilters(
                    entity_types=entity_types,
                    group_ids=[self.args.group_id] if self.args.group_id else None
                )
                
                # Search nodes
                results = await self.graphiti.search(
                    query=query,
                    num_results=num_results,
                    search_config=NODE_HYBRID_SEARCH_RRF,
                    search_filters=filters
                )
                
                # Format results
                nodes = []
                for node in results:
                    nodes.append({
                        'uuid': node.uuid,
                        'name': node.name,
                        'type': node.type,
                        'summary': getattr(node, 'summary', None),
                        'created_at': node.created_at.isoformat() if node.created_at else None
                    })
                
                return {
                    'success': True,
                    'query': query,
                    'count': len(nodes),
                    'nodes': nodes
                }
                
            except Exception as e:
                logger.error(f"Error searching nodes: {e}")
                return {'success': False, 'error': str(e)}
        
        @self.mcp_server.tool()
        async def search_facts(
            query: str,
            num_results: int = 10
        ) -> dict[str, Any]:
            """Search the knowledge graph for relevant facts (edges)"""
            
            if not self.graphiti:
                await self.initialize_graphiti()
            
            try:
                # Search edges
                results = await self.graphiti._search_edges(
                    query=query,
                    num_results=num_results,
                    group_ids=[self.args.group_id] if self.args.group_id else None
                )
                
                # Format results
                facts = []
                for edge in results:
                    facts.append({
                        'uuid': edge.uuid,
                        'source': edge.source_node_name,
                        'target': edge.target_node_name,
                        'fact': edge.fact,
                        'created_at': edge.created_at.isoformat() if edge.created_at else None,
                        'valid_at': edge.valid_at.isoformat() if edge.valid_at else None,
                        'invalid_at': edge.invalid_at.isoformat() if edge.invalid_at else None
                    })
                
                return {
                    'success': True,
                    'query': query,
                    'count': len(facts),
                    'facts': facts
                }
                
            except Exception as e:
                logger.error(f"Error searching facts: {e}")
                return {'success': False, 'error': str(e)}
        
        @self.mcp_server.tool()
        async def get_episodes(
            last_n: int = 10,
            group_id: str | None = None
        ) -> dict[str, Any]:
            """Get the most recent episodes"""
            
            if not self.graphiti:
                await self.initialize_graphiti()
            
            try:
                # Use provided group_id or default
                search_group_id = group_id or self.args.group_id
                
                # Retrieve episodes
                episodes = await self.graphiti.retrieve_episodes(
                    group_ids=[search_group_id] if search_group_id else None,
                    last_n=last_n
                )
                
                # Format results
                episode_list = []
                for episode in episodes:
                    episode_list.append({
                        'uuid': episode.uuid,
                        'name': episode.name,
                        'content': episode.content,
                        'created_at': episode.created_at.isoformat() if episode.created_at else None,
                        'valid_at': episode.valid_at.isoformat() if episode.valid_at else None
                    })
                
                return {
                    'success': True,
                    'count': len(episode_list),
                    'episodes': episode_list
                }
                
            except Exception as e:
                logger.error(f"Error getting episodes: {e}")
                return {'success': False, 'error': str(e)}
        
        @self.mcp_server.tool()
        async def clear_graph() -> dict[str, Any]:
            """Clear all data from the knowledge graph"""
            
            if not self.graphiti:
                await self.initialize_graphiti()
            
            try:
                # Clear the graph
                await clear_data(self.graphiti.driver)
                
                # Rebuild indices
                await self.graphiti.build_indices_and_constraints()
                
                return {
                    'success': True,
                    'message': 'Graph cleared and indices rebuilt'
                }
                
            except Exception as e:
                logger.error(f"Error clearing graph: {e}")
                return {'success': False, 'error': str(e)}
        
        @self.mcp_server.tool()
        async def get_status() -> dict[str, Any]:
            """Get the status of the Graphiti MCP server"""
            
            try:
                neo4j_status = 'not_initialized'
                if self.graphiti:
                    # Try a simple query to check connection
                    try:
                        await self.graphiti.driver.execute_query('RETURN 1')
                        neo4j_status = 'connected'
                    except:
                        neo4j_status = 'disconnected'
                
                return {
                    'success': True,
                    'server': 'graphiti-claude-docker',
                    'version': '0.1.0',
                    'neo4j_status': neo4j_status,
                    'llm_provider': 'claude_docker',
                    'embedder': 'gemini',
                    'group_id': self.args.group_id,
                    'custom_entities': self.args.use_custom_entities
                }
                
            except Exception as e:
                logger.error(f"Error getting status: {e}")
                return {'success': False, 'error': str(e)}
    
    async def run(self):
        """Run the MCP server"""
        # Initialize Graphiti if destroy_graph is set
        if self.args.destroy_graph:
            await self.initialize_graphiti()
            await clear_data(self.graphiti.driver)
            logger.info("Graph data cleared")
        
        # Run MCP server
        await self.mcp_server.run(transport=self.args.transport)


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description='Graphiti MCP Server with Claude Docker')
    
    parser.add_argument(
        '--model',
        type=str,
        help='Claude model to use'
    )
    
    parser.add_argument(
        '--temperature',
        type=float,
        default=0.0,
        help='LLM temperature (0.0-2.0)'
    )
    
    parser.add_argument(
        '--transport',
        choices=['sse', 'stdio'],
        default='stdio',
        help='MCP transport method'
    )
    
    parser.add_argument(
        '--group-id',
        type=str,
        default='default',
        help='Group ID for namespacing'
    )
    
    parser.add_argument(
        '--destroy-graph',
        action='store_true',
        help='Destroy all graph data on startup'
    )
    
    parser.add_argument(
        '--use-custom-entities',
        action='store_true',
        help='Enable custom entity types'
    )
    
    args = parser.parse_args()
    
    # Create and run server
    server = GraphitiMCPServerClaudeDocker(args)
    asyncio.run(server.run())


if __name__ == '__main__':
    main()