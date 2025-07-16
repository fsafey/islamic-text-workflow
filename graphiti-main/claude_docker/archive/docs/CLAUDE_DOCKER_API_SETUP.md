# Claude Docker API Setup Guide

This guide provides detailed instructions for setting up the Claude Docker API integration with Graphiti.

## Prerequisites

1. **Claude Docker Authentication**
   - Must have Claude Docker authenticated and working
   - Test with: `docker run --rm claude-docker:latest claude --version`
   - If not authenticated, see the main Islamic Text Workflow project

2. **Docker & Docker Compose**
   - Docker Engine 20.10+
   - Docker Compose 2.0+

3. **Python Environment**
   - Python 3.9+
   - UV package manager (recommended) or pip

4. **API Keys**
   - Google API Key for embeddings (Gemini)
   - Neo4j credentials (if using existing instance)

## Quick Start

### 1. Environment Setup

Create a `.env` file in the project root:

```bash
# Neo4j Configuration
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password

# Claude Docker Configuration
CLAUDE_DOCKER_URL=http://localhost:8000

# Embeddings Configuration
GOOGLE_API_KEY=your-google-api-key-here
```

### 2. Start Services

```bash
# From project root
./claude_docker/scripts/start_claude_docker_api.sh
```

This script will:
- Verify Claude Docker authentication
- Start the API server and Neo4j
- Wait for services to be ready
- Display connection information

### 3. Verify Installation

```bash
# Check API health
curl http://localhost:8000/health

# Run comprehensive test suite
python claude_docker/tests/comprehensive_test_suite.py
```

## Architecture Overview

### Components

1. **API Server** (`claude_docker/api/claude_docker_api_stdio.py`)
   - FastAPI server on port 8000
   - Anthropic-compatible `/v1/messages` endpoint
   - Manages worker pool for parallel processing

2. **Workers** (`claude_docker/workers/claude_docker_worker_stdio.py`)
   - 3 parallel worker processes
   - Communicate via stdin/stdout
   - Execute Claude Docker containers per request

3. **Runner Script** (`claude_docker/scripts/claude_docker_runner.sh`)
   - Bridges workers to Claude Docker
   - Handles authentication volume mounting
   - Manages container execution

4. **Neo4j Database**
   - Graph storage backend
   - Runs on ports 7474 (browser) and 7687 (bolt)

## Configuration Options

### Docker Compose Configuration

The `claude_docker/docker/docker-compose.yml` file contains:

```yaml
services:
  claude-api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - WORKERS=3  # Number of parallel workers
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ~/.claude-docker:/Users/farieds/.claude-docker:ro

  neo4j:
    image: neo4j:5.26-community
    ports:
      - "7474:7474"  # Browser
      - "7687:7687"  # Bolt
    environment:
      - NEO4J_AUTH=neo4j/password
```

### Worker Configuration

Adjust number of workers in `docker-compose.yml`:
```yaml
environment:
  - WORKERS=5  # Increase for more parallelism
```

### Model Selection

Default model is `claude-sonnet-4-0`. To use a different model:

```python
llm_config = LLMConfig(
    api_key="local",
    base_url="http://localhost:8000",
    model="claude-opus-4-0",  # or another available model
    temperature=0.5
)
```

## Using with Graphiti

### Basic Usage

```python
from graphiti_core import Graphiti
from graphiti_core.llm_client.anthropic_client import AnthropicClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

# Configure LLM for Claude Docker
llm_config = LLMConfig(
    api_key="local",  # Any non-empty string
    base_url="http://localhost:8000",
    model="claude-sonnet-4-0"
)

# Configure embeddings
embedder_config = GeminiEmbedderConfig(
    api_key=os.environ.get('GOOGLE_API_KEY'),
    embedding_model="models/text-embedding-004"
)

# Initialize Graphiti
graphiti = Graphiti(
    uri="bolt://localhost:7687",
    user="neo4j",
    password="password",
    llm_client=AnthropicClient(llm_config),
    embedder=GeminiEmbedder(embedder_config)
)
```

### Advanced Features

1. **Custom Entity Types**
   ```python
   from graphiti_core.nodes import Node
   from pydantic import BaseModel
   
   class ScholarNode(Node):
       birth_year: int
       death_year: int
       major_works: list[str]
   ```

2. **Batch Processing**
   ```python
   episodes = [...]  # Your episodes
   for episode in episodes:
       await graphiti.add_episode(...)
   ```

3. **Search Configuration**
   ```python
   from graphiti_core.search.search_config_recipes import NODE_HYBRID_SEARCH_RRF
   
   config = NODE_HYBRID_SEARCH_RRF.model_copy(deep=True)
   config.limit = 10
   results = await graphiti._search(query, config=config)
   ```

## Troubleshooting

### Common Issues

1. **Claude Docker Not Authenticated**
   ```
   Error: Claude Docker not authenticated
   ```
   Solution: Run authentication in main project:
   ```bash
   cd /Users/farieds/Project/islamic-text-workflow
   ./authenticate_claude_docker.sh
   ```

2. **API Connection Refused**
   ```
   Error: Cannot connect to http://localhost:8000
   ```
   Solution: Check if services are running:
   ```bash
   docker-compose -f claude_docker/docker/docker-compose.yml ps
   docker-compose -f claude_docker/docker/docker-compose.yml logs claude-api
   ```

3. **Neo4j Connection Failed**
   ```
   Error: Cannot connect to Neo4j
   ```
   Solution: Verify Neo4j is running and credentials are correct:
   ```bash
   docker-compose -f claude_docker/docker/docker-compose.yml logs neo4j
   ```

4. **Google API Key Invalid**
   ```
   Error: GOOGLE_API_KEY not set or invalid
   ```
   Solution: Set valid API key in `.env` file

### Debug Mode

Enable detailed logging:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

View worker logs:
```bash
docker-compose -f claude_docker/docker/docker-compose.yml logs -f claude-api
```

## Performance Tuning

1. **Increase Workers**: Edit `WORKERS` environment variable
2. **Adjust Timeouts**: Modify timeout values in worker code
3. **Cache Embeddings**: Implement embedding cache for repeated texts
4. **Batch Operations**: Process multiple episodes together

## Security Considerations

1. **Local Processing**: All LLM processing stays on your machine
2. **Authentication**: Claude Docker credentials are mounted read-only
3. **Network Isolation**: Services can be configured for internal-only access
4. **Data Privacy**: No data leaves your infrastructure

## Next Steps

1. Run the example: `python claude_docker/examples/quickstart_claude_docker_islamic.py`
2. Explore other examples in the main `examples/` directory
3. Build your own domain-specific implementation
4. Scale up with more workers as needed