# Graphiti Worker Deployment Guide

## Prerequisites

1. **Docker** and **Docker Compose** installed
2. **Neo4j** compatible graph database
3. **Google API Key** for embeddings (or alternative embedder)
4. **Claude Docker** authenticated (if using native mode)

## Environment Setup

Create a `.env` file in the `claude_docker` directory:

```bash
# Required
GOOGLE_API_KEY=your-google-api-key

# Optional overrides
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password
LLM_PROVIDER=claude_docker
```

## Deployment Modes

### 1. Software Engineering Mode

For code analysis and architecture tracking:

```bash
# Start services
docker-compose -f docker/docker-compose-software-engineering.yml up -d

# Verify services
docker ps
docker logs graphiti-software-engineering

# Test the worker
echo '{"operation": "health_check"}' | \
  docker exec -i graphiti-software-engineering python /app/workers/graphiti_worker.py
```

### 2. NLP Pipeline Mode

For text processing pipelines:

```bash
# Start full stack with 3 workers
docker-compose -f docker/docker-compose-nlp-pipeline.yml up -d

# Scale workers if needed
docker-compose -f docker/docker-compose-nlp-pipeline.yml up -d --scale graphiti-worker=5

# Monitor workers
docker logs -f graphiti-nlp-worker-1
```

## Production Considerations

### 1. Resource Allocation

```yaml
# In docker-compose override
services:
  graphiti-worker:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

### 2. Persistent Storage

```yaml
volumes:
  neo4j_data:
    driver: local
    driver_opts:
      type: none
      device: /data/graphiti/neo4j
      o: bind
```

### 3. Logging

```yaml
services:
  graphiti-worker:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### 4. Health Monitoring

```bash
# Health check script
#!/bin/bash
while true; do
  echo '{"operation": "health_check"}' | \
    docker exec -i graphiti-worker-1 python /app/workers/graphiti_worker.py
  sleep 30
done
```

## Integration Patterns

### 1. Named Pipes

```bash
# Create pipes
mkfifo /tmp/graphiti-in /tmp/graphiti-out

# Run worker
docker run -v /tmp:/tmp graphiti-worker \
  python /app/workers/graphiti_worker.py < /tmp/graphiti-in > /tmp/graphiti-out &
```

### 2. Message Queue Integration

```python
# Redis example
import redis
import json

r = redis.Redis(host='localhost', port=6379)

# Send request
request = {"operation": "search", "params": {"query": "test"}}
r.lpush("graphiti:requests", json.dumps(request))

# Get response
response = r.brpop("graphiti:responses", timeout=30)
```

### 3. REST API Wrapper

```python
# Simple Flask wrapper
from flask import Flask, request, jsonify
import subprocess
import json

app = Flask(__name__)

@app.route('/graphiti', methods=['POST'])
def graphiti_endpoint():
    req = request.json
    
    # Send to worker via subprocess
    proc = subprocess.Popen(
        ['docker', 'exec', '-i', 'graphiti-worker-1', 
         'python', '/app/workers/graphiti_worker.py'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True
    )
    
    result, _ = proc.communicate(json.dumps(req))
    return jsonify(json.loads(result))
```

## Monitoring & Observability

### 1. Prometheus Metrics

Add to worker for metrics export:

```python
from prometheus_client import Counter, Histogram, start_http_server

request_count = Counter('graphiti_requests_total', 'Total requests')
request_duration = Histogram('graphiti_request_duration_seconds', 'Request duration')
```

### 2. Log Aggregation

```yaml
# Fluentd example
services:
  fluentd:
    image: fluent/fluentd
    volumes:
      - ./fluent.conf:/fluentd/etc/fluent.conf
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
```

### 3. Distributed Tracing

```python
# OpenTelemetry example
from opentelemetry import trace
tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("graphiti_request"):
    # Process request
```

## Backup & Recovery

### 1. Neo4j Backup

```bash
# Backup Neo4j
docker exec neo4j neo4j-admin database backup neo4j --to-path=/backups

# Restore
docker exec neo4j neo4j-admin database restore --from-path=/backups/neo4j
```

### 2. Configuration Backup

```bash
# Backup configs
tar -czf graphiti-config-$(date +%Y%m%d).tar.gz config/

# Restore
tar -xzf graphiti-config-20240115.tar.gz
```

## Security

### 1. Network Isolation

```yaml
networks:
  graphiti-internal:
    internal: true
  graphiti-external:
    external: true
```

### 2. Secrets Management

```yaml
secrets:
  google_api_key:
    external: true

services:
  graphiti-worker:
    secrets:
      - google_api_key
    environment:
      - GOOGLE_API_KEY_FILE=/run/secrets/google_api_key
```

### 3. Access Control

```nginx
# Nginx reverse proxy with auth
location /graphiti {
    auth_basic "Graphiti Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://graphiti-worker:8000;
}
```

## Troubleshooting

### Common Issues

1. **Worker not starting**: Check logs with `docker logs graphiti-worker-1`
2. **Neo4j connection failed**: Verify network connectivity between containers
3. **Out of memory**: Increase Docker memory limits
4. **Slow performance**: Scale workers or optimize batch sizes

### Debug Mode

```bash
# Run worker with debug logging
docker run -e LOG_LEVEL=DEBUG graphiti-worker
```

### Performance Tuning

1. Adjust worker count based on workload
2. Configure Neo4j memory settings
3. Enable query caching
4. Use batch operations for bulk data

## Maintenance

### Regular Tasks

1. **Daily**: Check worker health, monitor logs
2. **Weekly**: Review performance metrics, clean up old data
3. **Monthly**: Update dependencies, backup configurations
4. **Quarterly**: Security audit, capacity planning

### Upgrades

```bash
# Update images
docker-compose pull

# Rolling restart
docker-compose up -d --no-deps --scale graphiti-worker=6
docker-compose up -d --no-deps --scale graphiti-worker=3
```