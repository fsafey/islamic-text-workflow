# Dual Mode Architecture: Native vs Orchestration

## Overview

Claude Docker + Graphiti integration supports two distinct operational modes, each optimized for different use cases.

## Mode 1: Native Integration

### Architecture
```
Application Code
      ↓
Graphiti.add_episode()
      ↓
ClaudeDockerClient._generate_response()
      ↓
subprocess.run("docker run claude-docker")
      ↓
Single Claude Container (ephemeral)
```

### Characteristics
- **Direct execution** via subprocess
- **Synchronous** processing
- **Single container** per request
- **No intermediate servers**
- **Minimal overhead**

### Code Example
```python
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient

# Simple, direct integration
client = ClaudeDockerClient(config)
graphiti = Graphiti(llm_client=client)

# Process one document
await graphiti.add_episode(
    name="Hadith Analysis",
    episode_body=hadith_text
)
```

### Best For
- Single document analysis
- Development and testing
- Quick prototypes
- Low-latency requirements
- Simple workflows

## Mode 2: Orchestration Architecture

### Architecture
```
Application Code
      ↓
Graphiti.add_episode() [Multiple calls]
      ↓
AnthropicClient → HTTP API (localhost:8000)
      ↓
API Server (FastAPI)
      ↓
Worker Pool Manager
      ↓
┌─────────┐ ┌─────────┐ ┌─────────┐
│Worker 1 │ │Worker 2 │ │Worker 3 │ ... [Scalable]
└────┬────┘ └────┬────┘ └────┬────┘
     ↓           ↓           ↓
Claude Docker Containers (Fresh contexts)
```

### Characteristics
- **HTTP API** interface
- **Asynchronous** processing with queues
- **Multiple workers** (configurable)
- **Load balancing** across workers
- **Fresh context** per task
- **Scalable** (add/remove workers)

### Code Example
```python
from graphiti_core.llm_client.anthropic_client import AnthropicClient

# Orchestration via API bridge
client = AnthropicClient(LLMConfig(
    api_key="local",
    base_url="http://localhost:8000"
))
graphiti = Graphiti(llm_client=client)

# Process many documents in parallel
tasks = []
for chapter in book.chapters:
    task = graphiti.add_episode(
        name=f"Chapter {chapter.number}",
        episode_body=chapter.text
    )
    tasks.append(task)

# All chapters processed in parallel
await asyncio.gather(*tasks)
```

### Best For
- Large document collections
- Parallel processing needs
- Production workloads
- Complex pipelines
- Variable workloads
- Fault tolerance requirements

## Detailed Comparison

| Feature | Native Mode | Orchestration Mode |
|---------|-------------|-------------------|
| **Setup Complexity** | Low (just Neo4j) | Medium (full stack) |
| **Latency** | Low (direct) | Higher (HTTP + queue) |
| **Throughput** | Limited (sequential) | High (parallel) |
| **Scalability** | None | Dynamic workers |
| **Resource Usage** | Minimal | Higher (multiple containers) |
| **Fault Tolerance** | Basic | Advanced (retry, queue) |
| **Context Isolation** | Per request | Per task (better) |
| **Monitoring** | Basic logs | Full metrics possible |
| **Load Balancing** | N/A | Automatic |
| **Queue Management** | N/A | Priority queues |

## Decision Matrix

### Choose Native Mode When:
- [x] Processing < 10 documents
- [x] Need lowest latency
- [x] Simple entity extraction
- [x] Development/debugging
- [x] Resource constrained
- [x] Single-user scenario

### Choose Orchestration Mode When:
- [x] Processing entire books/collections
- [x] Need parallel processing
- [x] Production deployment
- [x] Multiple concurrent users
- [x] Complex multi-stage pipelines
- [x] Need queue management
- [x] Want auto-scaling

## Advanced Patterns

### Pattern 1: Hybrid Usage
```python
class HybridGraphitiClient:
    def __init__(self):
        self.native = ClaudeDockerClient(config)
        self.orchestrated = AnthropicClient(orchestration_config)
    
    async def process(self, documents):
        if len(documents) == 1:
            # Use native for single doc
            return await self.native.process(documents[0])
        else:
            # Use orchestration for multiple
            return await self.orchestrated.batch_process(documents)
```

### Pattern 2: Pipeline with Both Modes
```python
# Stage 1: Quick extraction (Native)
entities = await native_graphiti.extract_entities(text)

# Stage 2: Parallel enrichment (Orchestration)
enriched = await orchestrated_graphiti.enrich_entities_parallel(entities)

# Stage 3: Final processing (Native)
result = await native_graphiti.finalize(enriched)
```

## Performance Characteristics

### Native Mode Performance
- Startup: ~2-3 seconds (container start)
- Processing: Direct (no overhead)
- Memory: Single container
- CPU: Single process

### Orchestration Mode Performance
- Startup: ~5-10 seconds (stack startup)
- Processing: +100-200ms HTTP overhead
- Memory: N workers × container size
- CPU: Parallel across workers

## Migration Between Modes

### From Native to Orchestration
```python
# Before (Native)
graphiti = Graphiti(llm_client=ClaudeDockerClient(config))

# After (Orchestration)
# 1. Start orchestration stack
# docker-compose -f docker/docker-compose.yml up
# 2. Update code
graphiti = Graphiti(
    llm_client=AnthropicClient(
        LLMConfig(base_url="http://localhost:8000")
    )
)
```

### From Orchestration to Native
```python
# Simply replace the client
# No infrastructure changes needed (keep Neo4j running)
```

## Conclusion

Both modes are first-class citizens in the Claude Docker + Graphiti ecosystem:

- **Native Mode**: Optimized for simplicity and direct execution
- **Orchestration Mode**: Optimized for scale and complex workflows

Choose based on your specific requirements, not on a "deprecated" label. Both will continue to be supported and enhanced.