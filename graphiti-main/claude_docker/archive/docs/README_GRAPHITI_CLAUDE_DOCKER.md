# Graphiti + Claude Docker Integration

Complete integration of Graphiti knowledge graphs with your local Claude Docker infrastructure for Islamic text analysis.

## What This Does

- **Zero External API Calls**: Uses your local Claude Docker containers instead of Anthropic's cloud API
- **Complete Graphiti Features**: Full temporal knowledge graphs, entity extraction, relationship mapping
- **Islamic Text Analysis**: Pre-configured for academic Islamic studies methodology
- **Production Ready**: Docker Compose deployment with multiple workers and authentication
- **Stdin/Stdout Architecture**: Proper Claude CLI integration using Unix pipes
- **MCP Integration**: Graphiti MCP server allows Claude to query and update the knowledge graph
- **Persistent Storage**: Neo4j data persists across container restarts

## Architecture Overview

```
Graphiti Application
       ↓
AnthropicClient (base_url="http://localhost:8000")
       ↓
Claude Docker API Server (FastAPI on port 8000)
       ↓ 
Worker Pool (3 persistent Python processes)
       ↓
Claude Docker Containers (ephemeral, per-request)
       ↓
Your Authenticated Claude Docker + MCP Servers
```

### How It Works
1. **API Server**: Always running, manages worker pool
2. **Workers**: 3 persistent processes using stdin/stdout pipes
3. **Claude Containers**: Start fresh for each request, process, then exit
4. **Neo4j**: Persistent graph database with Docker volumes

## Prerequisites

⚠️ **CRITICAL**: You must have the main Islamic Text Workflow Claude Docker system set up first:

### 1. Claude Docker Authentication (Required)
Your Claude Docker containers must be authenticated:

```bash
# From the main islamic-text-workflow directory:
cd /Users/farieds/Project/islamic-text-workflow

# Install and authenticate Claude Docker system
./tools/scripts/install.sh

# Test authentication
claude-docker
```

📖 **Full setup guide**: [/Users/farieds/Project/islamic-text-workflow/README.md](../README.md)

### 2. Environment Configuration

#### Required: Google API Key for Embeddings
```bash
# Add to your .env file or export directly
export GOOGLE_API_KEY=your_google_api_key  # Required for semantic search
```

#### Required: CLAUDE.md Configuration
The Claude Docker CLAUDE.md must be configured to enable text analysis:

```bash
# Location: /Users/farieds/.claude-docker/claude-home/CLAUDE.md
# Must include these capabilities:
- Islamic Text Analysis
- Knowledge Graph Construction
- MCP Tools access
- Internet Search
```

#### Required: MCP Configuration
```bash
# Copy MCP config to Claude Docker home
cp /Users/farieds/Project/islamic-text-workflow/infrastructure/configs/.mcp.json \
   /Users/farieds/.claude-docker/claude-home/.mcp.json
```

The `.mcp.json` must include the Graphiti MCP server:
```json
"graphiti": {
  "type": "stdio",
  "command": "uv",
  "args": ["run", "graphiti_mcp_server"],
  "env": {
    "NEO4J_URI": "bolt://host.docker.internal:7687",
    "NEO4J_USER": "neo4j",
    "NEO4J_PASSWORD": "password"
  }
}
```

### 3. Neo4j Database
Install Neo4j for graph storage:

```bash
# Option 1: Docker (recommended)
docker run -d \
    --name neo4j \
    -p 7474:7474 -p 7687:7687 \
    -e NEO4J_AUTH=neo4j/password \
    neo4j:5.26-community

# Option 2: Neo4j Desktop
# Download from: https://neo4j.com/download/
```

## Quick Start

### 1. Start All Services

```bash
# Use the stdio version for streamlined architecture
docker-compose -f docker-compose-stdio.yml up -d

# Check all services are running
docker-compose -f docker-compose-stdio.yml ps
```

You should see:
- `claude-docker-api-stdio` - API server with integrated workers (port 8000)
- `claude-docker-neo4j` - Graph database (ports 7474, 7687)

### 2. Test the Integration

```bash
# Quick API test
curl -X POST http://localhost:8000/v1/messages \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-0","messages":[{"role":"user","content":"Hello"}],"max_tokens":100}'

# Run test script
uv run python test_claude_docker_api.py

# Run Islamic text example
GOOGLE_API_KEY=your_key uv run python examples/quickstart/quickstart_claude_docker_islamic.py
```

### 3. Use in Your Code

```python
from graphiti_core import Graphiti
from graphiti_core.llm_client.anthropic_client import AnthropicClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

# Configure to use local Claude Docker
llm_config = LLMConfig(
    api_key="local",  # Any non-empty string
    base_url="http://localhost:8000",  # Your local API!
    model="claude-sonnet-4-0",
    temperature=0.5
)

gemini_config = GeminiEmbedderConfig(
    api_key=os.getenv('GOOGLE_API_KEY'),
    embedding_model="models/text-embedding-004"
)

# Create Graphiti with local Claude
graphiti = Graphiti(
    uri="bolt://localhost:7687",
    user="neo4j", 
    password="password",
    llm_client=AnthropicClient(llm_config),
    embedder=GeminiEmbedder(gemini_config)
)

# Use normally - Graphiti doesn't know it's using local Claude!
await graphiti.add_episode(
    name="islamic_text_analysis",
    episode_body="The Prophet Muhammad taught about seeking knowledge...",
    source_description="Islamic Studies Research"
)
```

## How Claude Docker Integration Works

### 1. Your Claude Docker System
The integration builds on your existing Claude Docker infrastructure:

- **Authentication**: Uses your authenticated Claude Docker containers
- **MCP Servers**: Includes Serena, Context7, Twilio for enhanced capabilities 
- **Persistence**: Leverages your `~/.claude-docker/` persistent configuration
- **SSH Keys**: Uses your dedicated Claude Docker SSH keys for git operations

### 2. API Bridge Architecture
The integration creates an API bridge that:

```bash
# Workers execute Claude like this:
echo "Extract entities from Islamic text" | docker run -i claude-docker:latest claude --print --model claude-sonnet-4-0
```

- **Stdin/Stdout**: Uses real Claude CLI with Unix pipes (no file mounting)
- **Anthropic Compatible**: Exposes `/v1/messages` endpoint matching Anthropic's API
- **File Coordination**: Uses file-based task queue between API server and workers
- **Multiple Workers**: 3 parallel workers for scalable processing

### 3. Technical Implementation
```python
# Worker communicates with Claude using proper CLI syntax
docker_cmd = [
    "docker", "run", "--rm", "-i",
    "claude-docker:latest", 
    "claude", "--print", 
    "--model", "claude-sonnet-4-0",
    "--output-format", "json"  # For structured output
]

# Send prompt via stdin, receive response from stdout
stdout, stderr = await process.communicate(input=prompt.encode('utf-8'))
```

## Features

### 🎓 Islamic Text Analysis
- **Entity Extraction**: Scholars, concepts, places, dates from Islamic texts
- **Relationship Mapping**: Connections between Islamic concepts and figures
- **Temporal Awareness**: Historical timeline tracking for Islamic events
- **Cross-Reference Detection**: Links between different Islamic sources

### 🔄 Knowledge Evolution
- **Incremental Updates**: Add new texts without rebuilding entire graph
- **Historical Tracking**: Track how understanding evolved over time  
- **Deduplication**: Intelligent merging of similar entities and concepts
- **Search Capabilities**: Semantic, keyword, and graph-based queries

### 🚀 Production Features
- **Zero Downtime**: Hot-reload workers without stopping API
- **Monitoring**: Health checks and comprehensive logging
- **Scalable**: Add more workers for increased throughput
- **Authenticated**: Secure access using your Claude credentials

## Configuration

### Docker Compose Services

```yaml
# API Server - Exposes Anthropic-compatible endpoint
api-server:
  ports: ["8000:8000"]
  
# Workers - Process requests using your Claude Docker
worker-1, worker-2, worker-3:
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock  # Docker-in-Docker
    - coordination:/coordination                  # Task coordination
```

### Environment Variables

Key configuration in `docker-compose.yml`:

```yaml
environment:
  - COORDINATION_PATH=/coordination
  - CLAUDE_DOCKER_PATH=/Users/farieds/Project/islamic-text-workflow/infrastructure/claude-docker
  - WORKER_ID=worker-1
```

### Custom Models

Change the Claude model in your Graphiti configuration:

```python
# Available models (update as Claude releases new ones)
llm_config = LLMConfig(
    model="claude-sonnet-4-0",          # Latest Sonnet 4
    # model="claude-opus-4-20250514",   # Opus 4 (if available)
    # model="claude-haiku-4-0",         # Haiku 4 (if available)
    temperature=0.5                     # Balanced creativity
)
```

## Comprehensive Test Suite

Run the full test suite to validate all features:

```bash
python comprehensive_test_suite.py
```

Tests demonstrate:
1. **Entity Extraction** - Islamic scholars, concepts, places
2. **Relationship Mapping** - Connections between entities  
3. **Temporal Awareness** - Historical events and timelines
4. **Knowledge Evolution** - Information updates over time
5. **Complex Queries** - Multi-modal search capabilities
6. **Cross-References** - Links between different texts
7. **Advanced Features** - Deduplication and metadata handling

## Monitoring & Debugging

### Check Service Health
```bash
# API server health
curl http://localhost:8000/health

# Service status  
docker-compose ps

# Worker logs
docker logs claude-docker-worker-1 -f
```

### Debug Workflow
```bash
# Check coordination directories
docker exec claude-docker-api ls -la /coordination/inbox/
docker exec claude-docker-api ls -la /coordination/outbox/

# Monitor task processing
docker exec claude-docker-worker-1 ls -la /coordination/inbox/
```

### Common Issues

**"Claude Code" refusing text analysis tasks:**
- **Problem**: Claude responds with "I'm Claude Code, a software engineering assistant"
- **Solution**: Update `/Users/farieds/.claude-docker/claude-home/CLAUDE.md` to include text analysis capabilities
- **Required sections**: Add capabilities for Islamic Text Analysis, Knowledge Graph Construction

**Workers not processing tasks:**
- Check Claude Docker authentication: `docker run --rm claude-docker:latest claude --version`
- Monitor active containers: `docker ps | grep claude-docker`
- Check worker logs: `docker logs claude-docker-api-stdio`

**Virtual environment warnings:**
- **Warning**: `VIRTUAL_ENV does not match the project environment path`
- **Solution**: Use `uv run` for all Python commands, or `unset VIRTUAL_ENV`

**Neo4j "Index already exists" messages:**
- These are informational only, not errors
- Indicates the database schema is already set up

**Long processing times:**
- Normal: Each Claude request takes 10-30 seconds
- Monitor progress in Neo4j Browser: http://localhost:7474
- Check container lifecycle: `watch -n 1 'docker ps | grep claude-docker'`

## Benefits vs External APIs

### ✅ Advantages
- **No External Costs**: No per-token charges to Anthropic
- **Data Privacy**: Your Islamic texts never leave your infrastructure  
- **Customization**: Modify workers for specific Islamic studies needs
- **Integration**: Uses your existing Claude Docker MCP servers
- **Offline Capable**: Works without internet (except for embeddings)

### ⚠️ Requirements  
- **Authentication Needed**: Must authenticate Claude Docker first
- **Resource Usage**: Runs Claude containers locally
- **Embeddings**: Still requires Google API for semantic search

## Data Persistence & Access

### Neo4j Data Storage
- **Location**: Docker volume `graphiti-main_neo4j-data`
- **Persistence**: ✅ Data survives container restarts
- **Access**: Neo4j Browser at http://localhost:7474 (neo4j/password)

### Viewing Your Knowledge Graph
```cypher
# See all nodes
MATCH (n) RETURN n LIMIT 50

# Find Islamic entities
MATCH (n:Entity) 
WHERE n.name CONTAINS 'Islam' OR n.name CONTAINS 'Al-'
RETURN n.name, labels(n)

# View relationships
MATCH (s:Entity)-[r:RELATES_TO]->(t:Entity)
RETURN s.name, r.fact, t.name
LIMIT 20
```

### Backup Your Graph
```bash
# Export Neo4j data
docker run --rm -v graphiti-main_neo4j-data:/data \
  -v $(pwd):/backup alpine \
  tar czf /backup/neo4j-backup-$(date +%Y%m%d).tar.gz -C /data .
```

## Next Steps

1. **Enable Graph Memory**: Configure Graphiti MCP server for Claude to query the graph
2. **Scale Up**: Add more workers for increased throughput
3. **Custom Analysis**: Modify workers for specific Islamic methodology
4. **Integration**: Connect to Islamic databases and manuscript sources
5. **Monitoring**: Add metrics and alerting for production use

## File Structure

```
graphiti-main/
├── claude_docker_api_stdio.py          # Streamlined API server with stdio workers
├── claude_docker_worker_stdio.py       # Worker using stdin/stdout pipes
├── claude_docker_runner.sh             # Claude Docker execution script
├── docker-compose-stdio.yml            # Production deployment config
├── Dockerfile.api-stdio                # API server Docker image
├── test_claude_docker_api.py           # API test suite
├── examples/
│   └── quickstart/
│       └── quickstart_claude_docker_islamic.py  # Islamic text demo
└── README_GRAPHITI_CLAUDE_DOCKER.md    # This file

Claude Docker Configuration:
├── /Users/farieds/.claude-docker/
│   └── claude-home/
│       ├── CLAUDE.md                   # Claude behavior configuration
│       └── .mcp.json                   # MCP servers configuration
```

## Support

For issues:
1. **Claude Docker Issues**: Check main [README.md](../README.md) authentication guide
2. **Graphiti Issues**: Refer to official Graphiti documentation
3. **Integration Issues**: Check worker logs and coordination directories
4. **Islamic Studies**: Leverage Context7 MCP for up-to-date documentation

---

**Built on**: [Islamic Text Workflow Claude Docker Infrastructure](../README.md)
**Graphiti Framework**: [GitHub](https://github.com/getzep/graphiti)