#!/usr/bin/env python3
"""
Test script for Claude Docker API stdio implementation
Tests basic functionality and integration
"""

import asyncio
import aiohttp
import json
import sys
from typing import Dict, Any


async def test_api_endpoint(base_url: str = "http://localhost:8000"):
    """Test the Claude Docker API endpoints"""
    
    print("🧪 Testing Claude Docker API (stdio)")
    print(f"📡 Base URL: {base_url}")
    print("-" * 50)
    
    async with aiohttp.ClientSession() as session:
        # Test 1: Root endpoint
        print("\n1️⃣ Testing root endpoint...")
        try:
            async with session.get(f"{base_url}/") as response:
                if response.status == 200:
                    data = await response.json()
                    print(f"✅ Root endpoint: {data}")
                else:
                    print(f"❌ Root endpoint failed: {response.status}")
        except Exception as e:
            print(f"❌ Error accessing root: {e}")
            return
        
        # Test 2: Health endpoint
        print("\n2️⃣ Testing health endpoint...")
        try:
            async with session.get(f"{base_url}/health") as response:
                if response.status == 200:
                    data = await response.json()
                    print(f"✅ Health check: {data}")
                else:
                    print(f"❌ Health check failed: {response.status}")
        except Exception as e:
            print(f"❌ Error accessing health: {e}")
        
        # Test 3: Simple message
        print("\n3️⃣ Testing simple message...")
        simple_request = {
            "model": "claude-sonnet-4-0",
            "messages": [
                {"role": "user", "content": "What is 2+2? Reply with just the number."}
            ],
            "max_tokens": 10,
            "temperature": 0
        }
        
        try:
            async with session.post(
                f"{base_url}/v1/messages",
                json=simple_request,
                headers={"Content-Type": "application/json"}
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data.get("content", [{}])[0].get("text", "No response")
                    print(f"✅ Simple message response: {content}")
                else:
                    error = await response.text()
                    print(f"❌ Simple message failed: {response.status} - {error}")
        except Exception as e:
            print(f"❌ Error sending message: {e}")
        
        # Test 4: Message with system prompt
        print("\n4️⃣ Testing message with system prompt...")
        system_request = {
            "model": "claude-sonnet-4-0",
            "system": "You are a helpful math tutor. Always explain your reasoning.",
            "messages": [
                {"role": "user", "content": "What is the square root of 16?"}
            ],
            "max_tokens": 100,
            "temperature": 0
        }
        
        try:
            async with session.post(
                f"{base_url}/v1/messages",
                json=system_request,
                headers={"Content-Type": "application/json"}
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data.get("content", [{}])[0].get("text", "No response")
                    print(f"✅ System prompt response: {content[:100]}...")
                else:
                    error = await response.text()
                    print(f"❌ System prompt failed: {response.status} - {error}")
        except Exception as e:
            print(f"❌ Error with system prompt: {e}")
        
        # Test 5: Tool use (JSON response)
        print("\n5️⃣ Testing tool use (JSON response)...")
        tool_request = {
            "model": "claude-sonnet-4-0",
            "messages": [
                {"role": "user", "content": "Extract the entities from: John works at Microsoft in Seattle."}
            ],
            "tools": [{
                "name": "extract_entities",
                "description": "Extract named entities from text",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "entities": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "text": {"type": "string"},
                                    "type": {"type": "string", "enum": ["PERSON", "ORG", "LOC"]}
                                }
                            }
                        }
                    }
                }
            }],
            "max_tokens": 200,
            "temperature": 0
        }
        
        try:
            async with session.post(
                f"{base_url}/v1/messages",
                json=tool_request,
                headers={"Content-Type": "application/json"}
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data.get("content", [{}])[0]
                    if content.get("type") == "tool_use":
                        tool_input = content.get("input", {})
                        print(f"✅ Tool use response: {json.dumps(tool_input, indent=2)}")
                    else:
                        print(f"✅ Tool response (text): {content.get('text', 'No response')}")
                else:
                    error = await response.text()
                    print(f"❌ Tool use failed: {response.status} - {error}")
        except Exception as e:
            print(f"❌ Error with tool use: {e}")
        
        # Test 6: Concurrent requests
        print("\n6️⃣ Testing concurrent requests...")
        concurrent_requests = [
            {
                "model": "claude-sonnet-4-0",
                "messages": [{"role": "user", "content": f"What is {i} + {i}?"}],
                "max_tokens": 10
            }
            for i in range(3)
        ]
        
        async def send_request(req: Dict[str, Any], idx: int) -> str:
            try:
                async with session.post(
                    f"{base_url}/v1/messages",
                    json=req,
                    headers={"Content-Type": "application/json"}
                ) as response:
                    if response.status == 200:
                        data = await response.json()
                        content = data.get("content", [{}])[0].get("text", "No response")
                        return f"Request {idx}: {content}"
                    else:
                        return f"Request {idx}: Failed with {response.status}"
            except Exception as e:
                return f"Request {idx}: Error - {e}"
        
        # Send all requests concurrently
        results = await asyncio.gather(*[
            send_request(req, i) for i, req in enumerate(concurrent_requests)
        ])
        
        for result in results:
            print(f"✅ {result}")
        
        print("\n" + "-" * 50)
        print("✅ All tests completed!")


async def main():
    """Main test function"""
    
    # Check if API is specified via command line
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"
    
    try:
        await test_api_endpoint(base_url)
    except KeyboardInterrupt:
        print("\n⚠️ Tests interrupted")
    except Exception as e:
        print(f"\n❌ Test suite error: {e}")


if __name__ == "__main__":
    # Run the async main function
    asyncio.run(main())