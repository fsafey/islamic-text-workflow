"""
Graphiti + Claude Docker Integration Demo for Islamic Text Analysis

This example demonstrates using Graphiti with your local Claude Docker
infrastructure to analyze Islamic texts and build knowledge graphs.
"""

import asyncio
import json
import logging
import os
from datetime import datetime, timezone
from logging import INFO

from dotenv import load_dotenv

from graphiti_core import Graphiti
from graphiti_core.nodes import EpisodeType
from graphiti_core.search.search_config_recipes import NODE_HYBRID_SEARCH_RRF
from graphiti_core.llm_client.anthropic_client import AnthropicClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

#################################################
# CONFIGURATION
#################################################
# Set up logging and environment variables for
# connecting to Neo4j database and Claude Docker
#################################################

# Configure logging
logging.basicConfig(
    level=INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
)
logger = logging.getLogger(__name__)

load_dotenv()

# Neo4j connection parameters
neo4j_uri = os.environ.get('NEO4J_URI', 'bolt://localhost:7687')
neo4j_user = os.environ.get('NEO4J_USER', 'neo4j')
neo4j_password = os.environ.get('NEO4J_PASSWORD', 'password')

if not neo4j_uri or not neo4j_user or not neo4j_password:
    raise ValueError('NEO4J_URI, NEO4J_USER, and NEO4J_PASSWORD must be set')

# Claude Docker configuration (local API)
claude_base_url = os.environ.get('CLAUDE_DOCKER_URL', 'http://localhost:8000')

# Google API key for embeddings
google_api_key = os.environ.get('GOOGLE_API_KEY')
if not google_api_key:
    raise ValueError('GOOGLE_API_KEY must be set for embeddings')


async def main():
    print("🕌 Islamic Text Analysis with Graphiti + Claude Docker")
    print("=" * 60)
    
    #################################################
    # INITIALIZATION WITH CLAUDE DOCKER
    #################################################
    # Configure Graphiti to use local Claude Docker
    # instead of external Anthropic API
    #################################################

    # Configure LLM to use local Claude Docker
    llm_config = LLMConfig(
        api_key="local",  # Any non-empty string (not used by local API)
        base_url=claude_base_url,  # Your local Claude Docker API
        model="claude-sonnet-4-0",
        temperature=0.5
    )
    
    # Configure embeddings (still uses Google API)
    gemini_config = GeminiEmbedderConfig(
        api_key=google_api_key,
        embedding_model="models/text-embedding-004"
    )
    
    # Initialize Graphiti with local Claude
    print(f"\n📡 Connecting to Claude Docker API at: {claude_base_url}")
    print(f"🗄️  Connecting to Neo4j at: {neo4j_uri}")
    
    graphiti = Graphiti(
        uri=neo4j_uri,
        user=neo4j_user,
        password=neo4j_password,
        llm_client=AnthropicClient(llm_config),
        embedder=GeminiEmbedder(gemini_config)
    )

    try:
        # Initialize the graph database with graphiti's indices
        await graphiti.build_indices_and_constraints()
        print("✅ Graph database initialized")

        #################################################
        # ADDING ISLAMIC TEXT EPISODES
        #################################################
        # Add various Islamic texts to demonstrate
        # entity extraction and relationship mapping
        #################################################

        print("\n📚 Adding Islamic text episodes...")
        
        # Islamic text episodes
        islamic_episodes = [
            {
                'content': 'The Prophet Muhammad (peace be upon him) said: "Seeking knowledge is '
                          'an obligation upon every Muslim." This hadith is narrated by Ibn Majah '
                          'and emphasizes the importance of education in Islam.',
                'type': EpisodeType.text,
                'description': 'Hadith on seeking knowledge',
                'name': 'Hadith Collection - Education'
            },
            {
                'content': 'Imam al-Ghazali (1058-1111 CE) was a Persian theologian, philosopher, '
                          'and mystic who taught at the Nizamiyyah college in Baghdad. His most '
                          'famous work is Ihya Ulum al-Din (Revival of the Religious Sciences).',
                'type': EpisodeType.text,
                'description': 'Biography of Islamic scholar',
                'name': 'Islamic Scholars - Al-Ghazali'
            },
            {
                'content': {
                    'scholar': 'Ibn Rushd (Averroes)',
                    'birth_year': 1126,
                    'death_year': 1198,
                    'location': 'Cordoba, Al-Andalus',
                    'known_for': ['Philosophy', 'Medicine', 'Jurisprudence'],
                    'influenced': ['Thomas Aquinas', 'European Renaissance'],
                    'major_works': ['The Incoherence of the Incoherence', 'Commentaries on Aristotle']
                },
                'type': EpisodeType.json,
                'description': 'Scholar metadata',
                'name': 'Islamic Scholars - Ibn Rushd'
            },
            {
                'content': 'The five pillars of Islam are: Shahada (declaration of faith), '
                          'Salat (prayer five times daily), Zakat (charitable giving), '
                          'Sawm (fasting during Ramadan), and Hajj (pilgrimage to Mecca). '
                          'These form the foundation of Muslim practice.',
                'type': EpisodeType.text,
                'description': 'Core Islamic concepts',
                'name': 'Islamic Fundamentals - Five Pillars'
            },
            {
                'content': 'Al-Ghazali studied under Imam al-Haramayn al-Juwayni at the '
                          'Nizamiyyah seminary in Nishapur. Later, he became head of the '
                          'Nizamiyyah college in Baghdad, where he influenced many students '
                          'including Abu Bakr ibn al-Arabi.',
                'type': EpisodeType.text,
                'description': 'Academic relationships',
                'name': 'Islamic Education Networks'
            }
        ]

        # Add episodes to the graph
        for episode in islamic_episodes:
            await graphiti.add_episode(
                name=episode['name'],
                episode_body=episode['content']
                if isinstance(episode['content'], str)
                else json.dumps(episode['content']),
                source=episode['type'],
                source_description=episode['description'],
                reference_time=datetime.now(timezone.utc),
            )
            print(f"✅ Added: {episode['name']}")

        #################################################
        # SEARCH DEMONSTRATIONS
        #################################################
        # Demonstrate various search capabilities with
        # Islamic content
        #################################################

        print("\n🔍 Performing searches on Islamic knowledge graph...")
        
        # Search 1: Find information about Islamic scholars
        print("\n1️⃣ Searching for: 'Islamic scholars and philosophers'")
        scholar_results = await graphiti.search('Islamic scholars and philosophers')
        
        print('\nSearch Results:')
        for result in scholar_results[:3]:  # Show top 3
            print(f'Fact: {result.fact}')
            if hasattr(result, 'valid_at') and result.valid_at:
                print(f'Valid from: {result.valid_at}')
            print('---')

        # Search 2: Find educational concepts
        print("\n2️⃣ Searching for: 'Islamic education and learning'")
        education_results = await graphiti.search('Islamic education and learning')
        
        print('\nSearch Results:')
        for result in education_results[:3]:
            print(f'Fact: {result.fact}')
            print('---')

        # Search 3: Find relationships between scholars
        print("\n3️⃣ Searching for: 'Who did Al-Ghazali study with?'")
        relationship_results = await graphiti.search('Who did Al-Ghazali study with?')
        
        print('\nSearch Results:')
        for result in relationship_results[:3]:
            print(f'Fact: {result.fact}')
            print('---')

        #################################################
        # NODE SEARCH FOR ENTITIES
        #################################################
        # Search for specific entities (scholars, concepts)
        # in the knowledge graph
        #################################################

        print('\n4️⃣ Performing entity search for Islamic concepts...')
        
        # Configure node search
        node_search_config = NODE_HYBRID_SEARCH_RRF.model_copy(deep=True)
        node_search_config.limit = 5
        
        # Search for Islamic concepts
        node_results = await graphiti._search(
            query='Islamic pillars and practices',
            config=node_search_config,
        )
        
        print('\nEntity Search Results:')
        for node in node_results.nodes:
            print(f'Entity: {node.name}')
            print(f'Type: {", ".join(node.labels)}')
            summary = node.summary[:100] + '...' if len(node.summary) > 100 else node.summary
            print(f'Summary: {summary}')
            print('---')

        #################################################
        # TEMPORAL QUERIES
        #################################################
        # Demonstrate temporal awareness with historical
        # Islamic figures
        #################################################

        print('\n5️⃣ Searching for temporal information...')
        temporal_results = await graphiti.search('When did Ibn Rushd live?')
        
        print('\nTemporal Search Results:')
        for result in temporal_results[:3]:
            print(f'Fact: {result.fact}')
            if hasattr(result, 'valid_at') and result.valid_at:
                print(f'Valid from: {result.valid_at}')
            if hasattr(result, 'invalid_at') and result.invalid_at:
                print(f'Valid until: {result.invalid_at}')
            print('---')

        print("\n✅ Demo completed successfully!")
        print(f"📊 Knowledge graph now contains Islamic scholars, concepts, and relationships")
        print(f"🔗 View the graph at: http://localhost:7474 (Neo4j Browser)")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        logger.error(f"Demo failed: {e}", exc_info=True)
    
    finally:
        # Close the connection
        await graphiti.close()
        print('\n🔚 Connection closed')


if __name__ == '__main__':
    asyncio.run(main())