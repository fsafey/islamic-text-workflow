"""
Native Graphiti + Claude Docker Integration
This uses Claude Docker as a first-class LLM provider within Graphiti
"""

import asyncio
import os
from datetime import datetime, timezone
from dotenv import load_dotenv

# Add parent directory to path to import the new client
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from graphiti_core import Graphiti
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

load_dotenv()


async def main():
    print("🚀 Native Graphiti + Claude Docker Integration")
    print("=" * 50)
    
    # Configure Claude Docker as native LLM client
    llm_config = LLMConfig(
        api_key="not-needed",  # Claude Docker doesn't need API key
        model="claude-sonnet-4-0",
        temperature=0.3,
        max_tokens=2000
    )
    
    # Configure embeddings (still using Google)
    gemini_config = GeminiEmbedderConfig(
        api_key=os.getenv('GOOGLE_API_KEY'),
        embedding_model="models/text-embedding-004"
    )
    
    # Initialize Graphiti with native Claude Docker client
    print("📦 Initializing Graphiti with native Claude Docker client...")
    graphiti = Graphiti(
        uri="bolt://localhost:7687",
        user="neo4j",
        password="password",
        llm_client=ClaudeDockerClient(llm_config),  # Our native client!
        embedder=GeminiEmbedder(gemini_config)
    )
    
    # Build indices and constraints
    print("🏗️ Building graph indices and constraints...")
    await graphiti.build_indices_and_constraints()
    
    # Example 1: Technology article analysis
    print("\n📝 Example 1: Technology Article")
    tech_article = """
    Artificial Intelligence is transforming the software development landscape.
    Major tech companies like Google, Microsoft, and OpenAI are investing billions
    in AI research. The latest breakthroughs in large language models have enabled
    new applications in code generation, automated testing, and documentation.
    
    GitHub's Copilot, powered by OpenAI's Codex, has over 1 million users and
    helps developers write code 55% faster according to recent studies.
    """
    
    episode1 = await graphiti.add_episode(
        name="AI in Software Development",
        episode_body=tech_article,
        source_description="Tech industry analysis article",
        episode_type="text"
    )
    print(f"✅ Added technology episode: {episode1.name}")
    
    # Example 2: Business news
    print("\n📝 Example 2: Business News")
    business_news = """
    Apple reported record quarterly revenue of $117 billion, driven by strong
    iPhone 15 sales and growing services revenue. CEO Tim Cook announced plans
    to expand manufacturing in India and Vietnam. The company's stock rose 5%
    in after-hours trading.
    
    Meanwhile, competitor Samsung unveiled its new Galaxy S24 series with
    advanced AI features, directly challenging Apple's market dominance.
    """
    
    episode2 = await graphiti.add_episode(
        name="Tech Company Earnings Q4 2024",
        episode_body=business_news,
        source_description="Business news report",
        timestamp=datetime.now(timezone.utc)
    )
    print(f"✅ Added business episode: {episode2.name}")
    
    # Example 3: Scientific research
    print("\n📝 Example 3: Scientific Research")
    research_text = """
    Researchers at MIT have developed a new quantum algorithm that could
    revolutionize cryptography. Dr. Sarah Chen and her team demonstrated
    that their approach can factor large prime numbers exponentially faster
    than classical computers. This breakthrough has implications for both
    cybersecurity and blockchain technology.
    """
    
    episode3 = await graphiti.add_episode(
        name="Quantum Computing Breakthrough",
        episode_body=research_text,
        source_description="MIT research publication"
    )
    print(f"✅ Added research episode: {episode3.name}")
    
    # Search examples
    print("\n🔍 Searching the knowledge graph...")
    
    # Search for AI and software development
    print("\n1. Searching for 'AI code generation':")
    ai_results = await graphiti.search("AI code generation", num_results=5)
    for i, result in enumerate(ai_results[:3]):
        print(f"   {i+1}. {getattr(result, 'name', str(result))}")
    
    # Search for companies
    print("\n2. Searching for 'tech companies revenue':")
    company_results = await graphiti.search("tech companies revenue", num_results=5)
    for i, result in enumerate(company_results[:3]):
        print(f"   {i+1}. {getattr(result, 'name', str(result))}")
    
    # Search for quantum computing
    print("\n3. Searching for 'quantum cryptography':")
    quantum_results = await graphiti.search("quantum cryptography", num_results=5)
    for i, result in enumerate(quantum_results[:3]):
        print(f"   {i+1}. {getattr(result, 'name', str(result))}")
    
    print("\n✨ Native integration complete!")
    print("Check Neo4j browser at http://localhost:7474 to explore the graph")
    print("Default credentials: neo4j / password")


if __name__ == "__main__":
    asyncio.run(main())