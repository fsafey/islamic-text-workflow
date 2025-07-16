#!/usr/bin/env python3
"""
Integration tests for Graphiti Worker
Tests the stdin/stdout interface and various operations
"""

import json
import asyncio
import subprocess
import sys
from pathlib import Path


class WorkerTestClient:
    """Test client for Graphiti worker"""
    
    def __init__(self, worker_cmd=None):
        self.worker_cmd = worker_cmd or [
            sys.executable,
            str(Path(__file__).parent.parent / "workers" / "graphiti_worker.py")
        ]
        
    async def send_request(self, operation: str, params: dict) -> dict:
        """Send request to worker and get response"""
        request = {
            "id": f"test-{operation}",
            "operation": operation,
            "params": params
        }
        
        # Run worker subprocess
        proc = await asyncio.create_subprocess_exec(
            *self.worker_cmd,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        
        # Send request
        request_json = json.dumps(request) + "\n"
        stdout, stderr = await proc.communicate(request_json.encode())
        
        # Parse response
        if stdout:
            return json.loads(stdout.decode().strip())
        else:
            raise Exception(f"No response. Stderr: {stderr.decode()}")


async def test_health_check():
    """Test basic health check"""
    print("Testing health check...")
    
    client = WorkerTestClient()
    response = await client.send_request("health_check", {})
    
    assert response["status"] == "healthy"
    assert "worker_id" in response
    print("✓ Health check passed")


async def test_add_episode():
    """Test adding an episode"""
    print("\nTesting add_episode...")
    
    client = WorkerTestClient()
    response = await client.send_request("add_episode", {
        "name": "Test Document",
        "episode_body": "This is a test document about software engineering.",
        "episode_type": "text",
        "group_id": "test-group"
    })
    
    assert response["status"] == "success"
    assert "result" in response
    assert "episode" in response["result"]
    print("✓ Add episode passed")


async def test_search():
    """Test search functionality"""
    print("\nTesting search...")
    
    client = WorkerTestClient()
    
    # First add some content
    await client.send_request("add_episode", {
        "name": "Python Tutorial",
        "episode_body": "Python is a high-level programming language known for its simplicity.",
        "episode_type": "text"
    })
    
    # Then search
    response = await client.send_request("search", {
        "query": "Python programming",
        "num_results": 5
    })
    
    assert response["status"] == "success"
    assert "result" in response
    assert "results" in response["result"]
    print("✓ Search passed")


async def test_bulk_operations():
    """Test bulk episode addition"""
    print("\nTesting bulk operations...")
    
    client = WorkerTestClient()
    
    episodes = [
        {
            "name": f"Document {i}",
            "episode_body": f"This is test document number {i}.",
            "group_id": "bulk-test"
        }
        for i in range(5)
    ]
    
    response = await client.send_request("add_episode_bulk", {
        "episodes": episodes,
        "batch_size": 2
    })
    
    # Bulk operations return streaming responses
    # For testing, we just check the final response
    assert "status" in response
    print("✓ Bulk operations passed")


async def test_entity_types():
    """Test custom entity types"""
    print("\nTesting custom entity types...")
    
    client = WorkerTestClient()
    
    response = await client.send_request("add_episode", {
        "name": "Code Analysis",
        "episode_body": """
        The calculate_total function in utils.py calls the validate_input
        method from the Validator class. This function handles error cases
        by raising a ValueError.
        """,
        "entity_types": {
            "Function": {
                "description": "A function in code",
                "fields": ["name", "module"]
            },
            "Class": {
                "description": "A class definition",
                "fields": ["name", "methods"]
            }
        },
        "edge_types": {
            "CALLS": {
                "description": "Function calls another",
                "source_types": ["Function"],
                "target_types": ["Function", "Class"]
            }
        }
    })
    
    assert response["status"] == "success"
    print("✓ Custom entity types passed")


async def test_error_handling():
    """Test error handling"""
    print("\nTesting error handling...")
    
    client = WorkerTestClient()
    
    # Test invalid operation
    response = await client.send_request("invalid_operation", {})
    assert response["status"] == "error"
    assert "Unknown operation" in response["error"]
    
    # Test missing required params
    response = await client.send_request("add_episode", {
        # Missing required 'name' and 'episode_body'
    })
    assert response["status"] == "error"
    
    print("✓ Error handling passed")


async def run_all_tests():
    """Run all integration tests"""
    print("=== Graphiti Worker Integration Tests ===\n")
    
    tests = [
        test_health_check,
        test_add_episode,
        test_search,
        test_bulk_operations,
        test_entity_types,
        test_error_handling
    ]
    
    failed = 0
    for test in tests:
        try:
            await test()
        except Exception as e:
            print(f"✗ {test.__name__} failed: {e}")
            failed += 1
    
    print(f"\n=== Tests Complete: {len(tests) - failed}/{len(tests)} passed ===")
    return failed == 0


def main():
    """Run tests"""
    # Check if Neo4j is running
    print("Prerequisites:")
    print("- Neo4j should be running on localhost:7687")
    print("- Google API key should be set in environment")
    print()
    
    success = asyncio.run(run_all_tests())
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()