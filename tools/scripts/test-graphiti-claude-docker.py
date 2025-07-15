#!/usr/bin/env python3
"""
Test Graphiti with Claude Docker Integration
"""

import sys
import os

# Add project to path
sys.path.append('/Users/farieds/Project/islamic-text-workflow/graphiti-main')

try:
    # Test Claude Docker API connection
    import requests
    
    print("🧪 Testing Claude Docker Integration...")
    
    # Test API endpoint
    response = requests.get('http://localhost:8000/')
    if response.status_code == 200:
        print("✅ Claude Docker API is accessible")
    else:
        print("❌ Claude Docker API not responding")
        sys.exit(1)
    
    # Test Graphiti import
    from graphiti_core import Graphiti
    from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
    from graphiti_core.embedder.gemini import GeminiEmbedder
    
    print("✅ Graphiti imports successful")
    
    # Test Neo4j connection
    from neo4j import GraphDatabase
    
    driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"))
    with driver.session() as session:
        result = session.run("RETURN 1 as test")
        test_value = result.single()["test"]
        if test_value == 1:
            print("✅ Neo4j connection successful")
        
    driver.close()
    
    print("🎉 All integrations working! Graphiti with Claude Docker is ready.")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("💡 Suggestion: Install missing dependencies")
    sys.exit(1)
    
except Exception as e:
    print(f"❌ Connection error: {e}")
    print("💡 Suggestion: Check if services are running")
    sys.exit(1)