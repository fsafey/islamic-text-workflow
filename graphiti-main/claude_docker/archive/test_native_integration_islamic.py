#!/usr/bin/env python3
"""Quick test of native integration"""

import asyncio
import sys
sys.path.append('/Users/farieds/Project/islamic-text-workflow/graphiti-main')

from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.prompts.models import Message


async def test_claude_docker():
    print("🧪 Testing Native Claude Docker Integration")
    print("=" * 50)
    
    # Configure client
    config = LLMConfig(
        api_key="not-needed",
        model="claude-sonnet-4-0"
    )
    
    client = ClaudeDockerClient(config)
    
    # Test simple message
    messages = [
        Message(role="system", content="You are an AI that extracts entities from text."),
        Message(role="user", content="Extract entities from: The Prophet Muhammad taught in Medina.")
    ]
    
    print("\n📤 Sending test message...")
    try:
        response = await client._generate_response(messages)
        print(f"\n📥 Response: {response}")
        print("\n✅ Native integration is working!")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    asyncio.run(test_claude_docker())
