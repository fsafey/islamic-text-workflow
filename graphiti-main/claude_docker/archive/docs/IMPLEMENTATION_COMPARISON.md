# Implementation Comparison: Claude Docker vs Graphiti Core

## Architecture Overview

| Component | Graphiti Core | Our Claude Docker |
|-----------|---------------|-------------------|
| **Location** | `/graphiti_core/` | `/claude_docker/` |
| **Purpose** | Core knowledge graph engine | Local Claude integration layer |
| **Role** | Handles graph operations, prompts, embeddings | Provides Anthropic-compatible API using local Claude |

## Key Component Mapping

### 1. LLM Client Layer

| Graphiti Component | Purpose | Claude Docker Equivalent |
|-------------------|---------|--------------------------|
| `graphiti_core/llm_client/anthropic_client.py` | Calls Anthropic's cloud API | Routes to → `claude_docker/api/claude_docker_api_stdio.py` |
| `graphiti_core/llm_client/openai_client.py` | OpenAI integration | N/A - We only support Claude |
| `graphiti_core/llm_client/base.py` | Abstract LLM interface | Implemented by our API server |

### 2. Prompt System

| Graphiti Component | What it Does | How Claude Docker Handles It |
|-------------------|--------------|------------------------------|
| `graphiti_core/prompts/extract_nodes.py` | Generates entity extraction prompts | Receives these prompts via `/v1/messages` endpoint |
| `graphiti_core/prompts/extract_edges.py` | Generates relationship prompts | Receives these prompts via `/v1/messages` endpoint |
| `graphiti_core/prompts/models.py` | Defines prompt data structures | We must parse and respond in compatible format |
| `graphiti_core/prompts/lib.py` | Prompt templates and tools | Claude must understand these tool definitions |

### 3. Core Processing Flow

| Step | Graphiti Core | Our Implementation |
|------|---------------|-------------------|
| 1. User calls | `graphiti.add_episode()` | Same - uses Graphiti API |
| 2. Graphiti creates prompt | `extract_nodes.py` builds complex prompt | Same - Graphiti handles this |
| 3. Send to LLM | `AnthropicClient` → cloud API | `AnthropicClient` → our local API |
| 4. Our API receives | N/A | `claude_docker_api_stdio.py` receives request |
| 5. Worker processes | N/A | `claude_docker_worker_stdio.py` runs Claude |
| 6. Claude execution | N/A | Docker container with CLAUDE.md config |
| 7. Response format | Anthropic JSON response | Must match Anthropic's format exactly |

### 4. Critical Integration Points

| Integration Point | Graphiti Expects | We Must Provide |
|------------------|------------------|-----------------|
| **Endpoint** | `POST /v1/messages` | ✅ Implemented |
| **Request Format** | Anthropic messages API | ✅ Implemented |
| **System Prompts** | Complex extraction instructions | ❌ Currently failing - Claude Code mode |
| **Tool Use** | Function calling for structured output | ❌ Not properly handled |
| **Response Format** | Structured JSON with entities | ❌ Getting errors instead |

### 5. File Structure Comparison

```
graphiti_core/                          claude_docker/
├── llm_client/                         ├── api/
│   ├── anthropic_client.py             │   ├── claude_docker_api_stdio.py
│   └── base.py                         │   └── claude_docker_api_stdio_with_logging.py
├── prompts/                            ├── workers/
│   ├── extract_nodes.py                │   └── claude_docker_worker_stdio.py
│   ├── extract_edges.py                ├── examples/
│   └── models.py                       │   ├── quickstart_claude_docker_islamic.py
├── graphiti.py (main class)            │   └── test_ulul_amr_analysis.py
└── nodes.py, edges.py                  └── scripts/
                                            └── claude_docker_runner.sh
```

## The Core Issue

**Graphiti sends specialized prompts like this:**
```python
# From extract_nodes.py
messages = [
    {"role": "system", "content": "You are an AI assistant that extracts entities..."},
    {"role": "user", "content": episode_content}
]
# Plus complex tool definitions for structured output
```

**But Claude Docker is responding with:**
```
"Starting Claude Code..."
"Execution error"
```

**Root Cause**: The CLAUDE.md configuration is making Claude start in Code mode instead of processing the extraction prompts as an AI assistant.

## Two Solution Paths

### Path 1: Native Integration (Simple, Direct)
Best for: Single documents, development, simple workflows

1. **Implementation**: `ClaudeDockerClient` in `graphiti_core/llm_client/`
2. **Execution**: Direct subprocess to Claude Docker
3. **Benefits**: Low overhead, simple debugging, no servers

### Path 2: Orchestration Mode (Powerful, Scalable)
Best for: Large corpora, parallel processing, production

1. **Implementation**: API bridge with worker pool
2. **Execution**: HTTP API → Workers → Claude containers
3. **Benefits**: Parallel processing, queue management, fresh contexts

## When to Use Each Mode

| Scenario | Use Native Mode | Use Orchestration Mode |
|----------|----------------|----------------------|
| Analyzing single hadith | ✅ Simple, fast | ❌ Overkill |
| Processing entire book | ❌ Sequential only | ✅ Parallel chapters |
| Development/testing | ✅ Easy debugging | ❌ Complex setup |
| Production pipeline | ❌ No scaling | ✅ Auto-scaling workers |
| Quick demos | ✅ Minimal setup | ❌ Requires docker-compose |
| Complex workflows | ❌ Limited | ✅ Full orchestration |

## Configuration Requirements

Both modes require:
1. **CLAUDE.md** configured for entity extraction (not code mode)
2. **MCP tools** available for enhanced analysis
3. **Neo4j** for graph storage
4. **Google API key** for embeddings