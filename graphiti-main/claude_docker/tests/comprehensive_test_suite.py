#!/usr/bin/env python3
"""
Comprehensive Test Suite for Graphiti Claude Docker Integration

This test suite validates the complete integration between Graphiti and Claude Docker,
ensuring all components work together correctly.
"""

import asyncio
import os
import sys
from datetime import datetime, timezone
import json
import time
from typing import Dict, Any

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from graphiti_core import Graphiti
from graphiti_core.nodes import EpisodeType
from graphiti_core.search.search_config_recipes import NODE_HYBRID_SEARCH_RRF
from graphiti_core.llm_client.anthropic_client import AnthropicClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig


class TestResult:
    """Container for test results"""
    def __init__(self, name: str):
        self.name = name
        self.passed = False
        self.error = None
        self.duration = 0
        self.details = {}


async def test_claude_docker_connection() -> TestResult:
    """Test 1: Verify Claude Docker API is accessible"""
    result = TestResult("Claude Docker Connection")
    start_time = time.time()
    
    try:
        import httpx
        async with httpx.AsyncClient() as client:
            response = await client.get("http://localhost:8000/health")
            if response.status_code == 200:
                result.passed = True
                result.details = response.json()
            else:
                result.error = f"Health check failed with status {response.status_code}"
    except Exception as e:
        result.error = f"Cannot connect to Claude Docker API: {str(e)}"
    
    result.duration = time.time() - start_time
    return result


async def test_llm_client_initialization() -> TestResult:
    """Test 2: Initialize LLM client with Claude Docker"""
    result = TestResult("LLM Client Initialization")
    start_time = time.time()
    
    try:
        llm_config = LLMConfig(
            api_key="local",
            base_url="http://localhost:8000",
            model="claude-sonnet-4-0",
            temperature=0.5
        )
        llm_client = AnthropicClient(llm_config)
        
        # Test with a simple prompt
        response = await llm_client.generate_response(
            messages=[{"role": "user", "content": "Say hello"}]
        )
        
        if response and len(response) > 0:
            result.passed = True
            result.details = {"response_length": len(response)}
        else:
            result.error = "Empty response from LLM"
    except Exception as e:
        result.error = f"LLM initialization failed: {str(e)}"
    
    result.duration = time.time() - start_time
    return result


async def test_embedder_initialization() -> TestResult:
    """Test 3: Initialize embedder with Google Gemini"""
    result = TestResult("Embedder Initialization")
    start_time = time.time()
    
    try:
        google_api_key = os.environ.get('GOOGLE_API_KEY')
        if not google_api_key:
            result.error = "GOOGLE_API_KEY not set"
            return result
        
        gemini_config = GeminiEmbedderConfig(
            api_key=google_api_key,
            embedding_model="models/text-embedding-004"
        )
        embedder = GeminiEmbedder(gemini_config)
        
        # Test embedding generation
        test_text = "This is a test sentence for embedding."
        embedding = await embedder.embed(test_text)
        
        if embedding and len(embedding) > 0:
            result.passed = True
            result.details = {"embedding_dimensions": len(embedding)}
        else:
            result.error = "Empty embedding generated"
    except Exception as e:
        result.error = f"Embedder initialization failed: {str(e)}"
    
    result.duration = time.time() - start_time
    return result


async def test_graphiti_initialization() -> TestResult:
    """Test 4: Initialize Graphiti with Claude Docker"""
    result = TestResult("Graphiti Initialization")
    start_time = time.time()
    
    try:
        # Get credentials
        neo4j_uri = os.environ.get('NEO4J_URI', 'bolt://localhost:7687')
        neo4j_user = os.environ.get('NEO4J_USER', 'neo4j')
        neo4j_password = os.environ.get('NEO4J_PASSWORD', 'password')
        google_api_key = os.environ.get('GOOGLE_API_KEY')
        
        if not google_api_key:
            result.error = "GOOGLE_API_KEY not set"
            return result
        
        # Initialize components
        llm_config = LLMConfig(
            api_key="local",
            base_url="http://localhost:8000",
            model="claude-sonnet-4-0"
        )
        
        gemini_config = GeminiEmbedderConfig(
            api_key=google_api_key,
            embedding_model="models/text-embedding-004"
        )
        
        # Create Graphiti instance
        graphiti = Graphiti(
            uri=neo4j_uri,
            user=neo4j_user,
            password=neo4j_password,
            llm_client=AnthropicClient(llm_config),
            embedder=GeminiEmbedder(gemini_config)
        )
        
        # Build indices
        await graphiti.build_indices_and_constraints()
        await graphiti.close()
        
        result.passed = True
        result.details = {"database": "neo4j", "status": "connected"}
    except Exception as e:
        result.error = f"Graphiti initialization failed: {str(e)}"
    
    result.duration = time.time() - start_time
    return result


async def test_episode_processing() -> TestResult:
    """Test 5: Process episodes with entity extraction"""
    result = TestResult("Episode Processing")
    start_time = time.time()
    
    graphiti = None
    try:
        # Initialize Graphiti
        neo4j_uri = os.environ.get('NEO4J_URI', 'bolt://localhost:7687')
        neo4j_user = os.environ.get('NEO4J_USER', 'neo4j')
        neo4j_password = os.environ.get('NEO4J_PASSWORD', 'password')
        google_api_key = os.environ.get('GOOGLE_API_KEY')
        
        llm_config = LLMConfig(
            api_key="local",
            base_url="http://localhost:8000",
            model="claude-sonnet-4-0"
        )
        
        gemini_config = GeminiEmbedderConfig(
            api_key=google_api_key,
            embedding_model="models/text-embedding-004"
        )
        
        graphiti = Graphiti(
            uri=neo4j_uri,
            user=neo4j_user,
            password=neo4j_password,
            llm_client=AnthropicClient(llm_config),
            embedder=GeminiEmbedder(gemini_config)
        )
        
        # Add test episodes
        test_episodes = [
            {
                'content': 'Claude is an AI assistant created by Anthropic. It can help with various tasks.',
                'name': 'Test Episode 1'
            },
            {
                'content': {'product': 'Claude', 'company': 'Anthropic', 'type': 'AI Assistant'},
                'name': 'Test Episode 2'
            }
        ]
        
        for episode in test_episodes:
            await graphiti.add_episode(
                name=episode['name'],
                episode_body=episode['content'] if isinstance(episode['content'], str) 
                             else json.dumps(episode['content']),
                source=EpisodeType.text if isinstance(episode['content'], str) else EpisodeType.json,
                source_description='test data',
                reference_time=datetime.now(timezone.utc)
            )
        
        result.passed = True
        result.details = {"episodes_added": len(test_episodes)}
    except Exception as e:
        result.error = f"Episode processing failed: {str(e)}"
    finally:
        if graphiti:
            await graphiti.close()
    
    result.duration = time.time() - start_time
    return result


async def test_search_functionality() -> TestResult:
    """Test 6: Test search capabilities"""
    result = TestResult("Search Functionality")
    start_time = time.time()
    
    graphiti = None
    try:
        # Initialize Graphiti
        neo4j_uri = os.environ.get('NEO4J_URI', 'bolt://localhost:7687')
        neo4j_user = os.environ.get('NEO4J_USER', 'neo4j')
        neo4j_password = os.environ.get('NEO4J_PASSWORD', 'password')
        google_api_key = os.environ.get('GOOGLE_API_KEY')
        
        llm_config = LLMConfig(
            api_key="local",
            base_url="http://localhost:8000",
            model="claude-sonnet-4-0"
        )
        
        gemini_config = GeminiEmbedderConfig(
            api_key=google_api_key,
            embedding_model="models/text-embedding-004"
        )
        
        graphiti = Graphiti(
            uri=neo4j_uri,
            user=neo4j_user,
            password=neo4j_password,
            llm_client=AnthropicClient(llm_config),
            embedder=GeminiEmbedder(gemini_config)
        )
        
        # Perform searches
        search_queries = [
            "What is Claude?",
            "Who created Claude?",
            "AI assistant"
        ]
        
        search_results = {}
        for query in search_queries:
            results = await graphiti.search(query)
            search_results[query] = len(results)
        
        result.passed = True
        result.details = search_results
    except Exception as e:
        result.error = f"Search failed: {str(e)}"
    finally:
        if graphiti:
            await graphiti.close()
    
    result.duration = time.time() - start_time
    return result


async def test_node_search() -> TestResult:
    """Test 7: Test node search with recipes"""
    result = TestResult("Node Search")
    start_time = time.time()
    
    graphiti = None
    try:
        # Initialize Graphiti
        neo4j_uri = os.environ.get('NEO4J_URI', 'bolt://localhost:7687')
        neo4j_user = os.environ.get('NEO4J_USER', 'neo4j')
        neo4j_password = os.environ.get('NEO4J_PASSWORD', 'password')
        google_api_key = os.environ.get('GOOGLE_API_KEY')
        
        llm_config = LLMConfig(
            api_key="local",
            base_url="http://localhost:8000",
            model="claude-sonnet-4-0"
        )
        
        gemini_config = GeminiEmbedderConfig(
            api_key=google_api_key,
            embedding_model="models/text-embedding-004"
        )
        
        graphiti = Graphiti(
            uri=neo4j_uri,
            user=neo4j_user,
            password=neo4j_password,
            llm_client=AnthropicClient(llm_config),
            embedder=GeminiEmbedder(gemini_config)
        )
        
        # Configure and perform node search
        node_search_config = NODE_HYBRID_SEARCH_RRF.model_copy(deep=True)
        node_search_config.limit = 5
        
        node_results = await graphiti._search(
            query='AI assistant',
            config=node_search_config
        )
        
        result.passed = True
        result.details = {
            "nodes_found": len(node_results.nodes),
            "search_type": "hybrid_rrf"
        }
    except Exception as e:
        result.error = f"Node search failed: {str(e)}"
    finally:
        if graphiti:
            await graphiti.close()
    
    result.duration = time.time() - start_time
    return result


async def run_all_tests():
    """Run all tests and display results"""
    print("🧪 Graphiti Claude Docker Integration Test Suite")
    print("=" * 60)
    
    # Define all tests
    tests = [
        test_claude_docker_connection,
        test_llm_client_initialization,
        test_embedder_initialization,
        test_graphiti_initialization,
        test_episode_processing,
        test_search_functionality,
        test_node_search
    ]
    
    results = []
    total_duration = 0
    
    # Run each test
    for test_func in tests:
        print(f"\n🔄 Running: {test_func.__doc__.split(':')[1].strip()}...", end='', flush=True)
        
        result = await test_func()
        results.append(result)
        total_duration += result.duration
        
        if result.passed:
            print(f" ✅ PASSED ({result.duration:.2f}s)")
            if result.details:
                print(f"   Details: {result.details}")
        else:
            print(f" ❌ FAILED ({result.duration:.2f}s)")
            print(f"   Error: {result.error}")
    
    # Display summary
    print("\n" + "=" * 60)
    print("📊 Test Summary")
    print("=" * 60)
    
    passed = sum(1 for r in results if r.passed)
    failed = sum(1 for r in results if not r.passed)
    
    print(f"Total Tests: {len(results)}")
    print(f"Passed: {passed} ✅")
    print(f"Failed: {failed} ❌")
    print(f"Total Duration: {total_duration:.2f}s")
    
    if failed > 0:
        print("\n❌ Failed Tests:")
        for result in results:
            if not result.passed:
                print(f"  - {result.name}: {result.error}")
        return 1
    else:
        print("\n🎉 All tests passed!")
        return 0


if __name__ == "__main__":
    # Check environment
    if not os.environ.get('GOOGLE_API_KEY'):
        print("❌ Error: GOOGLE_API_KEY environment variable not set")
        print("Please set: export GOOGLE_API_KEY='your-api-key'")
        sys.exit(1)
    
    # Run tests
    exit_code = asyncio.run(run_all_tests())
    sys.exit(exit_code)