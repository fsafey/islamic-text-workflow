#!/usr/bin/env python3
"""
Health check script for Graphiti services
"""

import asyncio
import sys
import httpx
import os

async def check_health():
    """Check if the service is healthy"""
    try:
        port = int(os.getenv('PORT', 8080))
        async with httpx.AsyncClient() as client:
            response = await client.get(f"http://localhost:{port}/health", timeout=5)
            if response.status_code == 200:
                print("Service is healthy")
                return True
            else:
                print(f"Service returned status {response.status_code}")
                return False
    except Exception as e:
        print(f"Health check failed: {e}")
        return False

if __name__ == "__main__":
    result = asyncio.run(check_health())
    sys.exit(0 if result else 1)