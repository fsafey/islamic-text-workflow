# Graphiti Stack - Containerized Setup

A complete containerized setup for Graphiti with Neo4j, Claude Docker, and Supabase integration using Docker Compose.

## 🏗️ Architecture Overview

The Graphiti Stack consists of the following services:

### Core Services
- **Neo4j** (Port 7474, 7687) - Knowledge graph database
- **Claude Docker API** (Port 8000) - Local Claude processing
- **Graphiti Service** (Port 8080) - Core knowledge graph operations

### Integration Services
- **Commands Gateway** (Port 8090) - API gateway for enhanced commands
- **Supabase Integration** (Port 8083) - Database synchronization
- **Graphiti Monitor** (Port 8082) - System monitoring dashboard
- **Enhanced Commands** (Port 8081) - Command processing service

### Worker Services
- **Graphiti Workers** (3 replicas) - Scalable processing pool

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Google API Key for embeddings
- Claude Docker authentication (optional but recommended)

### Environment Setup
1. **Set Google API Key**:
   ```bash
   export GOOGLE_API_KEY="your_google_api_key_here"
   ```

2. **Claude Docker Authentication** (optional):
   ```bash
   # Ensure Claude Docker is authenticated
   claude auth login
   ```

### Start the Stack
```bash
# Start all services
./infrastructure/docker/start-graphiti-stack.sh

# Or use Docker Compose directly
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml up -d
```

### Stop the Stack
```bash
# Stop all services
./infrastructure/docker/start-graphiti-stack.sh stop

# Or use Docker Compose
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml down
```

## 🔧 Service Configuration

### Neo4j Database
- **URL**: http://localhost:7474
- **Bolt**: bolt://localhost:7687
- **Credentials**: neo4j/password
- **Plugins**: APOC enabled

### Claude Docker API
- **URL**: http://localhost:8000
- **Workers**: 3 parallel instances
- **Authentication**: Uses ~/.claude-docker directory

### Graphiti Service
- **URL**: http://localhost:8080
- **Features**: Full knowledge graph operations
- **Dependencies**: Neo4j, Claude Docker API

## 📊 Monitoring & Management

### Monitoring Dashboard
Access the monitoring dashboard at http://localhost:8082

Features:
- Real-time service health monitoring
- System metrics (nodes, relationships, workers)
- Service response times
- Auto-refresh every 30 seconds

### Health Checks
Each service provides health check endpoints:
- Neo4j: `http://localhost:7474`
- Claude Docker API: `http://localhost:8000/health`
- Graphiti Service: `http://localhost:8080/health`
- Commands Gateway: `http://localhost:8090/health`

## 🛠️ Enhanced Commands Integration

### Using the Commands Gateway
The Commands Gateway provides a REST API for enhanced Graphiti commands:

```bash
# Remember information
curl -X POST http://localhost:8090/commands \
  -H 'Content-Type: application/json' \
  -d '{"command": "gr", "args": ["Important information to remember"]}'

# Search knowledge graph
curl -X POST http://localhost:8090/commands \
  -H 'Content-Type: application/json' \
  -d '{"command": "gs", "args": ["search query"]}'

# Analyze text file
curl -X POST http://localhost:8090/commands \
  -H 'Content-Type: application/json' \
  -d '{"command": "gt", "args": ["/path/to/file.txt"]}'

# Check system status
curl -X POST http://localhost:8090/commands \
  -H 'Content-Type: application/json' \
  -d '{"command": "gst"}'
```

### Project Management Commands
```bash
# Start project session
curl -X POST http://localhost:8090/commands \
  -H 'Content-Type: application/json' \
  -d '{"command": "pstart", "args": ["project-session-name"]}'

# Track decision
curl -X POST http://localhost:8090/commands \
  -H 'Content-Type: application/json' \
  -d '{"command": "pdecision", "args": ["architectural decision made"]}'

# Track feature
curl -X POST http://localhost:8090/commands \
  -H 'Content-Type: application/json' \
  -d '{"command": "pfeature", "args": ["feature-name", "in-progress"]}'
```

## 🔗 Supabase Integration

### Synchronization Features
The Supabase integration service automatically syncs:
- Knowledge graph entries
- Islamic text entities
- Project session data
- Research outputs

### API Endpoints
- **Health**: `http://localhost:8083/health`
- **Sync Knowledge**: `http://localhost:8083/sync/knowledge-entries`
- **Sync Islamic Entities**: `http://localhost:8083/sync/islamic-entities`
- **List Tables**: `http://localhost:8083/tables`

### Configuration
Set environment variables:
```bash
SUPABASE_URL="your_supabase_url"
SUPABASE_SERVICE_KEY="your_service_key"
```

## 📈 Scaling & Performance

### Worker Scaling
Scale the worker pool based on load:
```bash
# Scale to 5 workers
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml up -d --scale graphiti-worker=5

# Scale down to 2 workers
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml up -d --scale graphiti-worker=2
```

### Resource Limits
Each worker has:
- Memory limit: 2GB
- Memory reservation: 1GB
- CPU: Shared across host

### Performance Monitoring
Monitor performance through:
- Monitoring dashboard metrics
- Docker stats: `docker stats`
- Service logs: `docker-compose logs -f`

## 🔍 Troubleshooting

### Common Issues

#### Service Not Starting
1. Check Docker daemon is running
2. Verify port availability
3. Check logs: `docker-compose logs [service-name]`

#### Health Check Failures
1. Wait for services to fully initialize
2. Check Neo4j connection
3. Verify Google API key is set

#### Memory Issues
1. Increase Docker memory allocation
2. Scale down workers if needed
3. Monitor with `docker stats`

### Log Access
```bash
# View all logs
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml logs -f

# View specific service logs
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml logs -f neo4j
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml logs -f graphiti-service
```

### Service Management
```bash
# Check service status
./infrastructure/docker/start-graphiti-stack.sh status

# Restart specific service
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml restart graphiti-service

# Rebuild and restart
docker-compose -f infrastructure/docker/docker-compose-graphiti-stack.yml up -d --build
```

## 🔧 Development & Customization

### Adding New Services
1. Add service definition to `docker-compose-graphiti-stack.yml`
2. Create Dockerfile in appropriate directory
3. Update health checks and dependencies
4. Add monitoring configuration

### Custom Configurations
1. Modify environment variables in compose file
2. Update service configurations in respective directories
3. Rebuild images: `docker-compose build --no-cache`

### Integration Testing
```bash
# Run health checks
curl http://localhost:8082/health

# Test command execution
curl -X POST http://localhost:8090/commands \
  -H 'Content-Type: application/json' \
  -d '{"command": "gst"}'

# Test Supabase sync
curl -X POST http://localhost:8083/sync/knowledge-entries
```

## 📚 API Documentation

### Graphiti Service API
- **Base URL**: http://localhost:8080
- **Endpoints**:
  - `POST /episodes` - Add episode
  - `POST /search` - Search knowledge graph
  - `GET /episodes` - List episodes
  - `GET /stats` - Get statistics

### Commands Gateway API
- **Base URL**: http://localhost:8090
- **Endpoints**:
  - `POST /commands` - Execute command
  - `GET /health` - Health check

### Monitoring API
- **Base URL**: http://localhost:8082
- **Endpoints**:
  - `GET /` - Dashboard
  - `GET /health` - Health status
  - `GET /metrics` - System metrics
  - `GET /services` - Service status

## 🔒 Security Considerations

### Network Security
- Services communicate within isolated Docker network
- Only necessary ports exposed to host
- No external network access unless required

### Authentication
- Neo4j uses basic authentication
- Claude Docker uses local authentication
- Supabase uses service key authentication

### Data Protection
- Knowledge graph data persisted in Docker volumes
- Logs stored in separate volumes
- Service-specific data isolation

## 📊 Performance Benchmarks

### Typical Performance
- **Neo4j**: ~1-2ms query response time
- **Claude Docker API**: ~500ms-2s per request
- **Graphiti Service**: ~100-500ms per operation
- **Commands Gateway**: ~50-100ms routing overhead

### Scaling Recommendations
- **Small deployment**: 2-3 workers, 4GB RAM
- **Medium deployment**: 3-5 workers, 8GB RAM
- **Large deployment**: 5+ workers, 16GB+ RAM

This containerized setup provides a production-ready Graphiti stack with full monitoring, scaling, and integration capabilities.