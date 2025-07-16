# Graphiti + Claude Docker Integration

Transform Graphiti into a flexible, composable worker that can be used as:
1. **Software Engineering Assistant** - Analyze codebases and track architecture
2. **NLP Pipeline Worker** - Process text in larger data pipelines

## Overview

This integration provides two powerful modes for using Claude Docker with Graphiti knowledge graphs:

1. **Native Mode** - Direct integration for standalone use
2. **Orchestration Mode** - Worker pool architecture for pipeline integration

Both modes enable local knowledge graph construction without external API calls.

## 🚀 Quick Start

### Software Engineering Mode
```bash
# Start the stack
docker-compose -f docker/docker-compose-software-engineering.yml up

# Analyze your codebase
echo '{"operation": "add_episode", "params": {"name": "MyCode", "episode_body": "...code..."}}' | \
  docker exec -i graphiti-software-engineering python /app/workers/graphiti_worker.py
```

### NLP Pipeline Mode
```bash
# Start the pipeline stack
docker-compose -f docker/docker-compose-nlp-pipeline.yml up

# Use in a pipeline
text-extractor | graphiti-worker | downstream-processor
```

## 📊 Architecture

The Graphiti Worker follows the Unix philosophy:
- **Read from stdin**: JSON requests
- **Process**: Graphiti operations
- **Write to stdout**: JSON responses
- **Log to stderr**: Diagnostics

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed design documentation.

## 🔧 Configuration

### Software Engineering Configuration
```yaml
# config/software_engineering.yaml
entity_types:
  Function:
    fields: [name, module, parameters]
  Class:
    fields: [name, methods, base_classes]
    
edge_types:
  CALLS:
    source_types: [Function]
    target_types: [Function]
```

### NLP Pipeline Configuration
```yaml
# config/nlp_pipeline.yaml
entity_types:
  Person:
    fields: [name, role, organization]
  Organization:
    fields: [name, type, location]
    
worker:
  batch_size: 10
  enable_streaming: true
```

## 📁 Directory Structure

```
claude_docker/
├── workers/
│   ├── graphiti_worker.py          # Main worker implementation
│   └── claude_docker_worker_stdio.py # Reference implementation
├── config/
│   ├── software_engineering.yaml    # Software mode config
│   └── nlp_pipeline.yaml           # Pipeline mode config
├── docker/
│   ├── docker-compose-software-engineering.yml
│   ├── docker-compose-nlp-pipeline.yml
│   └── Dockerfile.worker
├── examples/
│   ├── software_engineering_example.py
│   └── nlp_pipeline_example.py
├── archive/                        # Legacy Islamic-specific files
├── ARCHITECTURE.md                 # Detailed architecture docs
└── README.md                       # This file
```

## 💡 Usage Examples

### Software Engineering Analysis
```python
# Analyze code structure
request = {
    "operation": "add_episode",
    "params": {
        "name": "auth_module.py",
        "episode_body": code_content,
        "entity_types": {
            "Function": {...},
            "Class": {...}
        }
    }
}

# Search for patterns
search_request = {
    "operation": "search",
    "params": {
        "query": "error handling patterns",
        "num_results": 20
    }
}
```

### NLP Pipeline Processing
```python
# Process documents in pipeline
bulk_request = {
    "operation": "add_episode_bulk",
    "params": {
        "episodes": documents,
        "batch_size": 10
    }
}

# Stream results as they complete
# {"status": "progress", "progress": {"processed": 10, "total": 100}}
```

## 🎯 Key Features

- **Dual Mode Support** - Standalone or pipeline integration
- **Local Processing** - No external LLM API calls with Claude Docker
- **Flexible Schema** - Configure entity types per use case
- **Streaming Support** - Handle large datasets efficiently
- **Full Graphiti Features** - All graph operations available

## 🏗️ Deployment

### Development
```bash
# Software engineering mode
docker-compose -f docker/docker-compose-software-engineering.yml up

# Pipeline mode with 3 workers
docker-compose -f docker/docker-compose-nlp-pipeline.yml up
```

### Production
```bash
# Scale workers
docker-compose -f docker/docker-compose-nlp-pipeline.yml up --scale graphiti-worker=5

# With orchestrator
docker-compose -f docker/docker-compose-nlp-pipeline.yml --profile orchestrator up
```

## 🔍 Monitoring

Check worker health:
```bash
echo '{"operation": "health_check"}' | docker exec -i graphiti-worker-1 python /app/workers/graphiti_worker.py
```

View logs:
```bash
docker logs graphiti-worker-1 -f
```

## 📚 Examples

See the `examples/` directory for:
- `software_engineering_example.py` - Code analysis patterns
- `nlp_pipeline_example.py` - Pipeline integration patterns
- `native_graphiti_integration.py` - Direct usage example

## 🆘 Troubleshooting

### Worker Not Responding
- Check Docker logs: `docker logs graphiti-worker-1`
- Verify Neo4j is running: `curl http://localhost:7474`
- Test health: `echo '{"operation": "health_check"}' | graphiti-worker`

### Performance Issues
- Increase worker count for parallel processing
- Adjust batch sizes in configuration
- Enable streaming for large datasets

## 📈 Performance

- **Latency**: ~1-5ms JSON overhead per request
- **Throughput**: Scales linearly with workers
- **Memory**: Each worker maintains own Graphiti instance
- **Caching**: Shared LLM cache improves performance

## 🚀 Next Steps

1. Review [ARCHITECTURE.md](ARCHITECTURE.md) for detailed design
2. Try the examples in `examples/`
3. Configure for your use case
4. Deploy and monitor

For more information about Graphiti itself, see the [main Graphiti documentation](../README.md).