# Dev Container Debugging Checklist

This checklist helps diagnose and fix issues with the Islamic Text Workflow development container.

## 🚀 Quick Debugging

Run the automated diagnostic script:
```bash
./.devcontainer/debug-devcontainer.sh
```

## 🔍 Manual Debugging Steps

### 1. Pre-flight Checks

- [ ] **Docker is installed and running**
  ```bash
  docker --version
  docker compose version
  docker ps
  ```

- [ ] **Sufficient system resources**
  - At least 4GB RAM available
  - 10GB disk space free
  - No resource limits blocking container creation

- [ ] **File permissions correct**
  ```bash
  ls -la .devcontainer/
  # setup.sh should be executable
  ```

### 2. Network Issues (Most Common)

- [ ] **Check for network conflicts**
  ```bash
  docker network ls | grep 172.21
  # If conflicts exist, try:
  docker network prune -f
  ```

- [ ] **Fix subnet conflicts in docker-compose.yml**
  - Change `172.21.0.0/16` to `172.22.0.0/16` or `172.23.0.0/16`
  - Or use a completely different range like `192.168.100.0/24`

- [ ] **Port conflicts**
  ```bash
  lsof -i :7474 -i :7687 -i :8000 -i :8080
  # Stop conflicting services or change ports
  ```

### 3. Container Build Issues

- [ ] **Check Dockerfile syntax**
  ```bash
  docker build -f .devcontainer/Dockerfile . --dry-run
  ```

- [ ] **Verify base images available**
  ```bash
  docker pull python:3.11-slim
  docker pull neo4j:5.26-community
  docker pull nginx:alpine
  ```

- [ ] **Clear Docker cache if needed**
  ```bash
  docker system prune -a -f
  docker builder prune -a -f
  ```

### 4. Service Dependencies

- [ ] **Neo4j container health**
  ```bash
  docker logs islamic-text-workflow_devcontainer-neo4j-1
  curl http://localhost:7474/db/data/
  ```

- [ ] **Claude Docker API health**
  ```bash
  docker logs islamic-text-workflow_devcontainer-claude-docker-api-1
  curl http://localhost:8000/health
  ```

- [ ] **App container status**
  ```bash
  docker logs islamic-text-workflow_devcontainer-app-1
  docker exec -it islamic-text-workflow_devcontainer-app-1 bash
  ```

### 5. Mount and Permission Issues

- [ ] **Verify volume mounts**
  ```bash
  docker inspect islamic-text-workflow_devcontainer-app-1 | grep -A 10 "Mounts"
  ```

- [ ] **Check workspace accessibility**
  ```bash
  docker exec islamic-text-workflow_devcontainer-app-1 ls -la /workspace
  ```

- [ ] **User permissions inside container**
  ```bash
  docker exec islamic-text-workflow_devcontainer-app-1 whoami
  docker exec islamic-text-workflow_devcontainer-app-1 groups
  ```

### 6. Environment Variables

- [ ] **Required env vars present**
  ```bash
  docker exec islamic-text-workflow_devcontainer-app-1 env | grep -E "(NEO4J|CLAUDE|PYTHONPATH)"
  ```

- [ ] **MCP server env vars (if using .env)**
  ```bash
  cat .devcontainer/.env  # Check for API keys
  ```

### 7. Integration Testing

- [ ] **Graphiti commands work**
  ```bash
  docker exec islamic-text-workflow_devcontainer-app-1 bash -c "source tools/scripts/graphiti-commands.sh && gst"
  ```

- [ ] **Python imports work**
  ```bash
  docker exec islamic-text-workflow_devcontainer-app-1 python -c "from graphiti_core.graphiti import Graphiti; print('OK')"
  ```

- [ ] **Neo4j connection**
  ```bash
  docker exec islamic-text-workflow_devcontainer-app-1 python -c "from neo4j import GraphDatabase; print('Neo4j driver OK')"
  ```

## 🛠️ Common Fixes

### Network Conflict Resolution
```bash
# Method 1: Clean up all networks
docker network prune -f

# Method 2: Change subnet in docker-compose.yml
# Edit networks.islamic-dev-network.ipam.config.subnet
# From: 172.21.0.0/16
# To:   172.22.0.0/16

# Method 3: Use host networking (temporary)
# Add network_mode: host to services (not recommended for production)
```

### Port Conflict Resolution
```bash
# Find what's using ports
lsof -i :7474 -i :7687 -i :8000 -i :8080

# Kill conflicting processes
sudo kill -9 $(lsof -t -i :7474)

# Or change ports in docker-compose.yml
# "7474:7474" -> "17474:7474"
```

### Container Startup Failures
```bash
# Force rebuild everything
docker compose -f .devcontainer/docker-compose.yml down -v
docker compose -f .devcontainer/docker-compose.yml build --no-cache
docker compose -f .devcontainer/docker-compose.yml up -d

# Check individual service logs
docker compose -f .devcontainer/docker-compose.yml logs neo4j
docker compose -f .devcontainer/docker-compose.yml logs app
```

### Development Environment Reset
```bash
# Nuclear option - clean everything
docker compose -f .devcontainer/docker-compose.yml down -v --remove-orphans
docker system prune -a -f
docker volume prune -f
docker network prune -f

# Rebuild from scratch
docker compose -f .devcontainer/docker-compose.yml build --no-cache
docker compose -f .devcontainer/docker-compose.yml up -d
```

## 📊 Context7 Integration for Advanced Debugging

When debugging complex Docker issues, you can use Context7 MCP server (if available in your Claude instance) to pull the latest Docker and development container documentation:

```
@context7 "Docker Compose networking troubleshooting"
@context7 "VS Code dev containers common issues"
@context7 "Neo4j Docker container startup problems"
```

This pulls current documentation and solutions directly from official sources.

## 🚨 Emergency Troubleshooting

If nothing works, try this emergency sequence:

1. **Stop everything**
   ```bash
   docker stop $(docker ps -aq)
   docker system prune -a -f
   ```

2. **Restart Docker daemon**
   - macOS: Restart Docker Desktop
   - Linux: `sudo systemctl restart docker`

3. **Check Docker installation**
   ```bash
   docker run hello-world
   ```

4. **Rebuild with verbose output**
   ```bash
   docker compose -f .devcontainer/docker-compose.yml build --no-cache --progress=plain
   ```

## 📝 Getting Help

When reporting issues, include:
- Output of `debug-devcontainer.sh`
- Docker version: `docker --version`
- System: `uname -a`
- Available resources: `docker system df`
- Container logs: `docker compose logs`

For additional support, see:
- [Claude Docker Integration Guide](../documentation/guides/CLAUDE_DOCKER_INTERACTIVE_USAGE.md)
- [Graphiti Docker Architecture](../graphiti-main/claude_docker/ARCHITECTURE.md)
- [MCP Server Configuration](../infrastructure/claude-docker/MCP_SERVERS.md)