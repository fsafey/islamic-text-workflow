# Quick Start Guide: Graphiti + Claude Docker

## 🚀 Start Everything in 2 Minutes

### Prerequisites Check
```bash
# Verify Claude Docker authentication works
echo "What is 2+2?" | /Users/farieds/Project/islamic-text-workflow/tools/scripts/claude-docker.sh --api --print
# Should return: 4

# Check environment
cat /Users/farieds/Project/islamic-text-workflow/infrastructure/configs/.env | grep GOOGLE_API_KEY
# Should show your Google API key
```

### Start Services
```bash
cd /Users/farieds/Project/islamic-text-workflow/graphiti-main

# Start everything
docker-compose -f docker-compose-stdio.yml up -d

# Verify (wait 10 seconds for startup)
sleep 10
curl http://localhost:8000/health
# Should return: {"status":"ok","service":"claude-docker-api-stdio"}
```

### Run Basic Test
```bash
# Test the integration
uv run python simple_integration_test.py
# Should show: "ALL TESTS PASSED"
```

## 🧪 Try Islamic Text Analysis

### Quick Entity Extraction
```python
import asyncio
from graphiti_core import Graphiti
from graphiti_core.llm_client.anthropic_client import AnthropicClient
from graphiti_core.llm_client.config import LLMConfig

async def quick_test():
    # Setup
    llm_config = LLMConfig(
        api_key="local",
        base_url="http://localhost:8000",
        model="claude-sonnet-4-0"
    )
    
    graphiti = Graphiti(
        uri="bolt://localhost:7687",
        user="neo4j",
        password="password",
        llm_client=AnthropicClient(llm_config)
    )
    
    # Extract entities from Islamic text
    text = """
    Imam Malik ibn Anas, founder of the Maliki school of jurisprudence,
    compiled Al-Muwatta in Medina. He was a student of Imam Ja'far al-Sadiq
    and taught Imam Shafi'i, creating a chain of knowledge transmission.
    """
    
    result = await graphiti.add_episode(
        name="malik_example",
        episode_body=text,
        source_description="Imam Malik biography"
    )
    
    print(f"Extracted {len(result.nodes)} entities")
    for node in result.nodes:
        print(f"- {node.name}")
    
    await graphiti.close()

# Run it
asyncio.run(quick_test())
```

### Search Islamic Content
```python
async def search_example():
    # ... setup graphiti as above ...
    
    # Search for content
    results = await graphiti.search(
        "Islamic jurisprudence schools madhab",
        num_results=10
    )
    
    print(f"Found {len(results)} relationships")
    for edge in results:
        print(f"- {edge.source_node.name} → {edge.target_node.name}")
        print(f"  Relationship: {edge.fact}")

asyncio.run(search_example())
```

## 📊 View in Neo4j Browser

1. Open http://localhost:7474
2. Login: neo4j / password
3. Run queries:

```cypher
// See all entities
MATCH (n:Entity) RETURN n LIMIT 50

// Find Islamic scholars
MATCH (n:Entity)
WHERE n.name CONTAINS 'Imam' OR n.name CONTAINS 'ibn'
RETURN n

// Show relationships
MATCH (n:Entity)-[r:RELATES_TO]->(m:Entity)
RETURN n, r, m LIMIT 50
```

## 🛑 Stop Everything
```bash
docker-compose -f docker-compose-stdio.yml down
```

## 📈 Monitor Performance
```bash
# Watch API logs
docker logs -f claude-docker-api-stdio

# Check worker status
docker exec claude-docker-api-stdio ps aux

# Monitor Neo4j
docker stats claude-docker-neo4j
```

## 🔧 Common Issues

### Timeout Errors
```python
# Increase timeout in llm_config
llm_config = LLMConfig(
    api_key="local",
    base_url="http://localhost:8000",
    model="claude-sonnet-4-0",
    timeout=120  # 2 minutes instead of 30 seconds
)
```

### Memory Issues
```bash
# Restart services
docker-compose -f docker-compose-stdio.yml restart

# Clear Neo4j data if needed
docker exec claude-docker-neo4j cypher-shell -u neo4j -p password "MATCH (n) DETACH DELETE n"
```

### Port Conflicts
```bash
# Check what's using ports
lsof -i :8000
lsof -i :7687
lsof -i :7474

# Use different ports in docker-compose-stdio.yml if needed
```

## 💡 Next: Explore Advanced Features

See `HANDOFF_GRAPHITI_INTEGRATION.md` for:
- Custom entity types
- Temporal analysis
- Scholar network mapping
- Arabic language support
- Bulk text processing
- And much more!

Happy knowledge graphing! 🌟