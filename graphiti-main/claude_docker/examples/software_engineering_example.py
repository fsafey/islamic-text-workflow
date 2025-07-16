#!/usr/bin/env python3
"""
Software Engineering Example - Using Graphiti to analyze code structure

This example demonstrates how to use Graphiti Worker to:
1. Analyze Python code structure
2. Extract functions, classes, and dependencies
3. Build a knowledge graph of code relationships
4. Query the codebase effectively
"""

import json
import sys
import asyncio
from pathlib import Path


def send_request(operation: str, params: dict) -> dict:
    """Send a request to Graphiti worker via stdin/stdout"""
    request = {
        "id": f"{operation}-{id(params)}",
        "operation": operation,
        "params": params
    }
    
    # In production, this would write to stdin and read from stdout
    # For this example, we'll just show the request format
    print("REQUEST:", json.dumps(request, indent=2))
    return request


async def analyze_python_file(file_path: str):
    """Analyze a Python file and add to knowledge graph"""
    
    with open(file_path, 'r') as f:
        code_content = f.read()
    
    # Define software engineering entity types
    entity_types = {
        "Function": {
            "description": "A function or method in code",
            "fields": ["name", "module", "parameters", "return_type", "docstring"]
        },
        "Class": {
            "description": "A class definition",
            "fields": ["name", "module", "base_classes", "methods", "attributes"]
        },
        "Module": {
            "description": "A code module or file",
            "fields": ["name", "path", "imports", "exports"]
        }
    }
    
    # Define code relationships
    edge_types = {
        "CALLS": {
            "description": "Function A calls Function B",
            "source_types": ["Function", "Class"],
            "target_types": ["Function", "Class"]
        },
        "IMPORTS": {
            "description": "Module A imports from Module B",
            "source_types": ["Module", "Class", "Function"],
            "target_types": ["Module", "Package"]
        },
        "INHERITS": {
            "description": "Class A inherits from Class B",
            "source_types": ["Class"],
            "target_types": ["Class"]
        }
    }
    
    # Add the code file to the knowledge graph
    request = send_request("add_episode", {
        "name": f"Code Analysis: {file_path}",
        "episode_body": code_content,
        "source_description": f"Python source file: {file_path}",
        "episode_type": "text",
        "entity_types": entity_types,
        "edge_types": edge_types,
        "group_id": "codebase-analysis"
    })
    
    return request


async def analyze_codebase(directory: str):
    """Analyze an entire codebase"""
    
    python_files = list(Path(directory).rglob("*.py"))
    
    # Bulk process all Python files
    episodes = []
    for file_path in python_files:
        with open(file_path, 'r') as f:
            content = f.read()
            
        episodes.append({
            "name": f"Code: {file_path.name}",
            "episode_body": content,
            "source_description": str(file_path),
            "group_id": "codebase-analysis"
        })
    
    # Send bulk request
    request = send_request("add_episode_bulk", {
        "episodes": episodes,
        "batch_size": 10
    })
    
    return request


async def search_codebase(query: str):
    """Search the code knowledge graph"""
    
    # Different search examples
    searches = [
        # Find all functions that handle errors
        {
            "query": "error handling exception try catch",
            "search_type": "NODE_HYBRID_SEARCH_RRF",
            "num_results": 20
        },
        
        # Find database-related code
        {
            "query": "database connection query SQL",
            "search_type": "NODE_HYBRID_SEARCH_RRF",
            "num_results": 15
        },
        
        # Find all imports of a specific module
        {
            "query": "imports requests",
            "search_type": "EDGE_HYBRID_SEARCH_RRF",
            "num_results": 10
        }
    ]
    
    for search_params in searches:
        request = send_request("search", search_params)
        print(f"\nSearching for: {search_params['query']}")


async def find_code_patterns():
    """Find common patterns and architectural decisions"""
    
    # Build communities to find related code clusters
    send_request("build_communities", {})
    
    # Search for design patterns
    patterns = [
        "singleton pattern",
        "factory pattern",
        "observer pattern",
        "dependency injection"
    ]
    
    for pattern in patterns:
        send_request("search", {
            "query": pattern,
            "num_results": 5
        })


async def track_code_changes():
    """Track how code evolves over time"""
    
    # Simulate code changes
    original_code = '''
def calculate_total(items):
    total = 0
    for item in items:
        total += item.price
    return total
'''
    
    updated_code = '''
def calculate_total(items, include_tax=True):
    """Calculate total price with optional tax"""
    total = sum(item.price for item in items)
    if include_tax:
        total *= 1.08  # 8% tax
    return total
'''
    
    # Add original version
    send_request("add_episode", {
        "name": "calculate_total - v1",
        "episode_body": original_code,
        "source_description": "Initial implementation",
        "group_id": "function-evolution"
    })
    
    # Add updated version (linked to previous)
    send_request("add_episode", {
        "name": "calculate_total - v2",
        "episode_body": updated_code,
        "source_description": "Added tax calculation",
        "group_id": "function-evolution",
        "previous_episode_uuids": ["<uuid-of-v1>"]  # Would be actual UUID
    })


async def analyze_dependencies():
    """Analyze project dependencies"""
    
    # Example: Analyze requirements.txt or package.json
    requirements = """
graphiti-core>=0.2.0
neo4j>=5.0.0
fastapi>=0.100.0
pydantic>=2.0.0
"""
    
    send_request("add_episode", {
        "name": "Project Dependencies",
        "episode_body": requirements,
        "source_description": "requirements.txt",
        "episode_type": "text",
        "entity_types": {
            "Package": {
                "description": "A software package or library",
                "fields": ["name", "version", "dependencies"]
            }
        }
    })


async def example_queries():
    """Example queries for software engineering use cases"""
    
    queries = [
        # Architecture queries
        ("What are the main architectural components?", 10),
        ("Which classes have the most dependencies?", 20),
        ("What error handling patterns are used?", 15),
        
        # Code quality queries
        ("Find functions without docstrings", 20),
        ("Which modules have circular imports?", 10),
        ("Find deprecated functions", 10),
        
        # Dependency queries
        ("What depends on the database module?", 25),
        ("Which functions call external APIs?", 15),
        ("Find all uses of async/await", 30),
        
        # Refactoring queries
        ("Find duplicate code patterns", 20),
        ("Which functions are too complex?", 15),
        ("Find unused imports", 20)
    ]
    
    for query, num_results in queries:
        print(f"\nQuery: {query}")
        send_request("search", {
            "query": query,
            "num_results": num_results
        })


def main():
    """Run the software engineering examples"""
    
    print("=== Graphiti Software Engineering Examples ===\n")
    
    # Example 1: Analyze a single file
    print("1. Analyzing a single Python file:")
    asyncio.run(analyze_python_file("example_module.py"))
    
    # Example 2: Analyze entire codebase
    print("\n2. Analyzing entire codebase:")
    asyncio.run(analyze_codebase("./src"))
    
    # Example 3: Search code patterns
    print("\n3. Searching for code patterns:")
    asyncio.run(search_codebase("error handling"))
    
    # Example 4: Find architectural patterns
    print("\n4. Finding architectural patterns:")
    asyncio.run(find_code_patterns())
    
    # Example 5: Track code evolution
    print("\n5. Tracking code changes over time:")
    asyncio.run(track_code_changes())
    
    # Example 6: Analyze dependencies
    print("\n6. Analyzing project dependencies:")
    asyncio.run(analyze_dependencies())
    
    # Example 7: Common queries
    print("\n7. Common software engineering queries:")
    asyncio.run(example_queries())
    
    print("\n=== Examples Complete ===")
    print("\nTo run these examples with actual Graphiti worker:")
    print("1. Start the software engineering stack:")
    print("   docker-compose -f docker/docker-compose-software-engineering.yml up")
    print("2. Pipe these requests to the worker:")
    print("   python software_engineering_example.py | docker exec -i graphiti-software-engineering python /app/workers/graphiti_worker.py")


if __name__ == "__main__":
    main()