# Quick Start Guide

Get up and running with Claude Docker + Graphiti in 5 minutes.

## Prerequisites

1. **Claude Docker authenticated** (from main islamic-text-workflow project)
2. **Google API key** for embeddings
3. **Docker** installed and running

## Option 1: Native Mode (Simplest)

### 1. Start Neo4j
```bash
cd claude_docker
docker-compose -f docker/docker-compose-native.yml up -d
```

### 2. Set Environment
```bash
export GOOGLE_API_KEY=your_google_api_key
```

### 3. Run Example
```python
from graphiti_core import Graphiti
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig
import os

# Configure
llm_config = LLMConfig(api_key="local", model="sonnet")
embedder_config = GeminiEmbedderConfig(api_key=os.getenv('GOOGLE_API_KEY'))

# Initialize
graphiti = Graphiti(
    uri="bolt://localhost:7687",
    user="neo4j",
    password="password",
    llm_client=ClaudeDockerClient(llm_config),
    embedder=GeminiEmbedder(embedder_config)
)

# Use
await graphiti.add_episode(
    name="Test",
    episode_body="The Prophet Muhammad taught about seeking knowledge."
)
```

## Option 2: Orchestration Mode (Powerful)

### 1. Start Full Stack
```bash
cd claude_docker
docker-compose -f docker/docker-compose.yml up -d
```

### 2. Verify Services
```bash
# Check API health
curl http://localhost:8000/health

# Check Neo4j
curl http://localhost:7474
```

### 3. Run Example
```python
from graphiti_core import Graphiti
from graphiti_core.llm_client.anthropic_client import AnthropicClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

# Configure for orchestration
llm_config = LLMConfig(
    api_key="local",
    base_url="http://localhost:8000"
)
embedder_config = GeminiEmbedderConfig(api_key=os.getenv('GOOGLE_API_KEY'))

# Initialize
graphiti = Graphiti(
    uri="bolt://localhost:7687",
    user="neo4j",
    password="password", 
    llm_client=AnthropicClient(llm_config),
    embedder=GeminiEmbedder(embedder_config)
)

# Process multiple texts in parallel
texts = ["Text 1 about Islamic history...", "Text 2 about scholars...", "Text 3..."]
tasks = [graphiti.add_episode(name=f"Text {i}", episode_body=text) 
         for i, text in enumerate(texts)]
await asyncio.gather(*tasks)
```

## 🔍 Verify Results

### Check Neo4j Browser
1. Open http://localhost:7474
2. Login: neo4j / password
3. Run query:
```cypher
MATCH (n:Entity) RETURN n LIMIT 25
```

### View Logs

Native Mode:
```bash
# See Claude execution
docker logs graphiti-neo4j
```

Orchestration Mode:
```bash
# See worker activity
docker logs claude-docker-api -f
```

## 🚀 Next Steps

1. **Try the examples**:
   - `examples/native_graphiti_integration.py`
   - `examples/quickstart_claude_docker_islamic.py`

2. **Read the full docs**:
   - [Complete Setup Guide](README_GRAPHITI_CLAUDE_DOCKER.md)
   - [Architecture Overview](ECOSYSTEM_VISUALIZATION.md)
   - [Dual Mode Guide](DUAL_MODE_ARCHITECTURE.md)

3. **Customize**:
   - Add MCP tools for your domain
   - Configure CLAUDE.md for your use case
   - Scale workers for production

## 🆘 Troubleshooting

### "Claude Code" Errors
- Check CLAUDE.md is configured for text analysis
- Ensure not in code-only mode

### No Entities Created
- Verify Claude Docker is authenticated
- Check logs for specific errors
- Ensure prompts are being sent correctly

### Connection Refused
- Make sure Docker is running
- Check services: `docker ps`
- Verify ports aren't in use

## 📚 Learn More

- [When to use each mode](DUAL_MODE_ARCHITECTURE.md#decision-matrix)
- [Advanced patterns](ORCHESTRATION_POWER_ANALYSIS.md)
- [Extending with MCP tools](CLAUDE_DOCKER_ECOSYSTEM_ARCHITECTURE.md)