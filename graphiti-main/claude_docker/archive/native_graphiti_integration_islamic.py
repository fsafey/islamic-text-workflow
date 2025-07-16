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
sys.path.append('/Users/farieds/Project/islamic-text-workflow/graphiti-main')

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
    
    try:
        # Initialize the graph
        await graphiti.build_indices_and_constraints()
        print("✅ Graph database initialized")
        
        # Add episode about Ulul Amr
        ulul_amr_text = """
        In the Quranic verse 4:59 (Surah An-Nisa), Allah commands: "O you who believe! 
        Obey Allah and obey the Messenger and those in authority among you (Ulul Amr)."
        
        According to the book "Who are the Ulul Amr?" by Sayyid Muhammad Husayn Tabataba'i,
        published on al-islam.org, there are three main interpretations:
        
        1. Sunni interpretation: Ulul Amr refers to Muslim rulers and governors
        2. Another Sunni view: It refers to Islamic scholars and jurists
        3. Shia interpretation: Ulul Amr specifically refers to the Twelve Imams,
           beginning with Imam Ali ibn Abi Talib
        
        Tabataba'i analyzes various hadith including the Hadith of Thaqalayn where
        the Prophet said: "I leave among you two weighty things: the Book of Allah
        and my Ahlul Bayt (household)."
        """
        
        print("\n📚 Adding Ulul Amr episode using native Claude Docker...")
        await graphiti.add_episode(
            name="Ulul Amr Interpretations",
            episode_body=ulul_amr_text,
            source_description="Analysis from Tabataba'i's work on al-islam.org",
            reference_time=datetime.now(timezone.utc)
        )
        print("✅ Episode processed by Claude Docker")
        
        # Search for results
        print("\n🔍 Searching for Ulul Amr interpretations...")
        results = await graphiti.search("What are the different interpretations of Ulul Amr?")
        
        print("\nSearch Results:")
        for i, result in enumerate(results[:5], 1):
            print(f"\n{i}. {result.fact}")
            if hasattr(result, 'valid_at') and result.valid_at:
                print(f"   Valid from: {result.valid_at}")
        
        # Check entities
        print("\n📊 Entities extracted by Claude Docker:")
        query = """
        MATCH (n:Entity) 
        WHERE n.created_at > datetime() - duration('PT5M')
        RETURN n.name as name, labels(n) as labels, n.summary as summary
        LIMIT 10
        """
        with graphiti.driver.session() as session:
            result = session.run(query)
            entities = list(result)
            
        if entities:
            for entity in entities:
                print(f"\n- {entity['name']}")
                print(f"  Type: {', '.join(entity['labels'])}")
                if entity['summary']:
                    print(f"  Summary: {entity['summary'][:100]}...")
        else:
            print("No entities found (yet)")
            
        # Check relationships
        print("\n🔗 Relationships extracted:")
        rel_query = """
        MATCH (s:Entity)-[r:RELATES_TO]->(t:Entity)
        WHERE r.created_at > datetime() - duration('PT5M')
        RETURN s.name as source, r.fact as relationship, t.name as target
        LIMIT 10
        """
        with graphiti.driver.session() as session:
            result = session.run(rel_query)
            relationships = list(result)
            
        if relationships:
            for rel in relationships:
                print(f"\n- {rel['source']} → {rel['target']}")
                print(f"  Relationship: {rel['relationship']}")
        else:
            print("No relationships found (yet)")
            
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        await graphiti.close()
        print("\n🔚 Connection closed")


if __name__ == '__main__':
    asyncio.run(main())