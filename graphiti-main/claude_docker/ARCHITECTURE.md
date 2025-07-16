# Graphiti Worker Architecture

This document describes the stdin/stdout worker architecture that enables Graphiti to function as a flexible, composable component in various workflows.

## Overview

The Graphiti Worker pattern transforms Graphiti from a monolithic application into a Unix-style tool that can be:
1. Used standalone as a software engineering assistant
2. Integrated into NLP processing pipelines
3. Composed with other tools via pipes and message queues

## Core Concepts

### Worker Pattern

The worker follows the Unix philosophy:
- **Read from stdin**: Accept JSON-formatted requests
- **Process**: Execute Graphiti operations
- **Write to stdout**: Return JSON-formatted responses
- **Log to stderr**: Keep logs separate from data

```bash
# Example usage
echo '{"operation": "search", "params": {"query": "database connections"}}' | graphiti-worker
```

### Message Format

#### Request Structure
```json
{
  "id": "unique-request-id",
  "operation": "add_episode",
  "params": {
    "name": "Episode Name",
    "episode_body": "Content to process",
    "entity_types": {
      "CustomType": {
        "description": "A custom entity type",
        "fields": ["field1", "field2"]
      }
    }
  }
}
```

#### Response Structure
```json
{
  "id": "unique-request-id",
  "status": "success|error|progress",
  "result": {
    // Operation-specific results
  },
  "error": "Error message if status is error"
}
```

## Supported Operations

### Core Operations

1. **add_episode** - Add content to the knowledge graph
2. **add_episode_bulk** - Bulk episode processing with streaming
3. **search** - Query the knowledge graph
4. **add_triplet** - Manually add entities and relationships
5. **build_communities** - Analyze graph communities
6. **get_entity** - Retrieve specific entity
7. **get_edges_by_entity** - Get entity relationships
8. **remove_episode** - Remove episodes
9. **retrieve_episodes** - Get historical episodes
10. **health_check** - Worker status check

### Streaming Operations

For long-running operations like bulk processing, the worker supports streaming responses:

```json
{"id": "req-1", "status": "progress", "progress": {"processed": 10, "total": 100}}
{"id": "req-1", "status": "progress", "progress": {"processed": 20, "total": 100}}
...
{"id": "req-1", "status": "completed", "result": {"total_processed": 100}}
```

## Deployment Modes

### 1. Software Engineering Mode

Optimized for code analysis and software architecture:

```yaml
# docker-compose-software-engineering.yml
services:
  graphiti-worker:
    environment:
      - GRAPHITI_MODE=software_engineering
      - GRAPHITI_CONFIG_PATH=/app/config/software_engineering.yaml
```

Features:
- Code-specific entity types (Function, Class, Module)
- Software relationships (CALLS, IMPORTS, INHERITS)
- Integration with development tools

### 2. NLP Pipeline Mode

Designed for text processing workflows:

```yaml
# docker-compose-nlp-pipeline.yml
services:
  graphiti-worker-1:
    environment:
      - GRAPHITI_MODE=nlp_pipeline
      - GRAPHITI_CONFIG_PATH=/app/config/nlp_pipeline.yaml
```

Features:
- Multiple parallel workers
- Dynamic entity type support
- Message queue integration
- Shared graph access

## Configuration System

### Configuration Files

Each mode has its own YAML configuration:

```yaml
# Core settings
mode: software_engineering
neo4j:
  uri: bolt://localhost:7687
  
# Entity types
entity_types:
  Function:
    description: "A function or method"
    fields: [name, module, parameters]
    
# Edge types
edge_types:
  CALLS:
    description: "Function calls"
    source_types: [Function]
    target_types: [Function]
```

### Environment Variables

Configuration can be overridden via environment:

- `GRAPHITI_MODE` - Operation mode
- `NEO4J_URI` - Database connection
- `LLM_PROVIDER` - LLM backend (claude_docker, anthropic)
- `GOOGLE_API_KEY` - For embeddings

## Integration Patterns

### 1. Direct Pipe Usage

```bash
# Single operation
echo '{"operation": "search", "params": {"query": "error handling"}}' | \
  docker run -i graphiti-worker

# Pipeline
text-extractor | graphiti-worker | result-formatter
```

### 2. Named Pipes

```bash
# Create pipes
mkfifo /tmp/graphiti-in /tmp/graphiti-out

# Run worker
graphiti-worker < /tmp/graphiti-in > /tmp/graphiti-out &

# Send requests
echo '{"operation": "add_episode", ...}' > /tmp/graphiti-in
```

### 3. Process Substitution

```bash
# Parallel processing
paste <(graphiti-worker < requests1.jsonl) \
      <(graphiti-worker < requests2.jsonl)
```

### 4. Message Queue Integration

```python
# Redis example
import redis
r = redis.Redis()

# Send to Graphiti
request = {"operation": "search", "params": {...}}
r.lpush("graphiti_input", json.dumps(request))

# Get results
result = json.loads(r.brpop("graphiti_output")[1])
```

## Scaling Strategies

### Horizontal Scaling

Run multiple workers for parallel processing:

```yaml
services:
  graphiti-worker-1:
    deploy:
      replicas: 3
```

### Load Distribution

Use a load balancer or orchestrator:

```python
# Round-robin distribution
workers = [worker1, worker2, worker3]
for i, request in enumerate(requests):
    worker = workers[i % len(workers)]
    worker.send(request)
```

### Shared State

All workers connect to the same Neo4j instance:
- Concurrent reads are safe
- Writes are handled with Neo4j transactions
- Entity deduplication happens at the database level

## Error Handling

### Worker-Level Errors

```json
{
  "id": "req-123",
  "status": "error",
  "error": "Invalid entity type: Unknown"
}
```

### Retry Logic

Workers implement exponential backoff:
```python
retry_attempts: 3
retry_delay: 1  # seconds
```

### Circuit Breaker

For downstream service failures:
- Track failure rate
- Open circuit after threshold
- Periodic health checks

## Monitoring

### Health Checks

```bash
# Check worker health
echo '{"operation": "health_check"}' | graphiti-worker
```

### Metrics

Workers expose metrics via logs:
- Request count
- Processing time
- Error rate
- Queue depth

### Logging

Structured logs to stderr:
```
[graphiti-worker-1] 2024-01-15 10:30:00 - INFO - Processing request req-123: add_episode
[graphiti-worker-1] 2024-01-15 10:30:02 - INFO - Request req-123 completed in 2.1s
```

## Best Practices

1. **Stateless Operations**: Each request should be independent
2. **Idempotent Design**: Same request produces same result
3. **Batch When Possible**: Use bulk operations for efficiency
4. **Stream Large Results**: Avoid memory issues with streaming
5. **Configure Appropriately**: Use mode-specific configurations
6. **Monitor Performance**: Track metrics and adjust scaling

## Example Workflows

### Software Analysis Pipeline

```bash
# 1. Extract code structure
code-parser --lang python myproject/ | \
# 2. Build knowledge graph
graphiti-worker | \
# 3. Generate documentation
doc-generator --format markdown
```

### Text Processing Pipeline

```bash
# 1. Extract text from PDFs
pdf-to-text documents/*.pdf | \
# 2. Chunk into sections
text-chunker --size 1000 | \
# 3. Process with Graphiti
graphiti-worker | \
# 4. Export for search
elastic-indexer
```

## Future Enhancements

1. **gRPC Support**: Binary protocol for performance
2. **WebSocket Interface**: Real-time bidirectional communication
3. **GraphQL API**: Flexible query interface
4. **Kubernetes Operator**: Native cloud deployment
5. **Plugin System**: Extensible entity types and processors