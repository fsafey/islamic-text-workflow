"""
Test script for analyzing "Who are the Ulul Amr?" text using Claude Docker
"""

import asyncio
import json
import os
from datetime import datetime, timezone
from dotenv import load_dotenv

# Load environment variables
load_dotenv("../../../.env")  # Load from main project .env
load_dotenv("../.env")  # Also load from claude_docker/.env

from graphiti_core import Graphiti
from graphiti_core.llm_client.anthropic_client import AnthropicClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

async def main():
    print("🕌 Testing Ulul Amr Text Analysis with Claude Docker")
    print("=" * 60)
    
    # Configure LLM to use local Claude Docker
    llm_config = LLMConfig(
        api_key="local",
        base_url="http://localhost:8000",
        model="claude-sonnet-4-0",
        temperature=0.3  # Lower temperature for more consistent extraction
    )
    
    # Configure embeddings
    gemini_config = GeminiEmbedderConfig(
        api_key=os.getenv('GOOGLE_API_KEY'),
        embedding_model="models/text-embedding-004"
    )
    
    # Initialize Graphiti
    graphiti = Graphiti(
        uri="bolt://localhost:7687",
        user="neo4j",
        password="password",
        llm_client=AnthropicClient(llm_config),
        embedder=GeminiEmbedder(gemini_config)
    )
    
    try:
        # Initialize the graph
        await graphiti.build_indices_and_constraints()
        print("✅ Graph database initialized")
        
        # Test episode about Ulul Amr
        ulul_amr_text = """
        The term "Ulul Amr" appears in the Quran in Surah An-Nisa, verse 59: 
        "O you who believe! Obey Allah and obey the Messenger and those in 
        authority among you (Ulul Amr)." 
        
        According to Sayyid Muhammad Husayn Tabataba'i, there are different 
        interpretations of who the Ulul Amr are. Some scholars interpret it 
        as referring to political rulers, while others, particularly in Shia 
        theology, interpret it as referring to the Twelve Imams beginning 
        with Imam Ali ibn Abi Talib.
        
        The hadith of Thaqalayn, narrated by Muslim ibn al-Hajjaj, supports 
        the interpretation that Ulul Amr refers to the Ahlul Bayt (the 
        Prophet's household).
        """
        
        print("\n📚 Adding Ulul Amr text episode...")
        await graphiti.add_episode(
            name="Ulul Amr Analysis",
            episode_body=ulul_amr_text,
            source_description="Analysis of Quranic concept of authority",
            reference_time=datetime.now(timezone.utc)
        )
        print("✅ Episode added")
        
        # Search for the added content
        print("\n🔍 Searching for Ulul Amr information...")
        results = await graphiti.search("What is Ulul Amr and who does it refer to?")
        
        print("\nSearch Results:")
        for i, result in enumerate(results[:5], 1):
            print(f"\n{i}. {result.fact}")
            if hasattr(result, 'valid_at') and result.valid_at:
                print(f"   Valid from: {result.valid_at}")
        
        # Check what entities were created
        print("\n📊 Checking entities in the graph...")
        # Direct Neo4j query to see what was created
        query = "MATCH (n:Entity) RETURN n.name as name, labels(n) as labels LIMIT 10"
        with graphiti.driver.session() as session:
            result = session.run(query)
            entities = list(result)
            
        if entities:
            print("\nEntities found:")
            for entity in entities:
                print(f"- {entity['name']} ({', '.join(entity['labels'])})")
        else:
            print("\n⚠️  No entities found in the graph")
            
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        await graphiti.close()
        print("\n🔚 Connection closed")

if __name__ == '__main__':
    asyncio.run(main())