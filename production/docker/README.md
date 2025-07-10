# Islamic Text Processing Claude Agents - Docker Implementation

## Overview

This Docker implementation provides a sophisticated **dashboard + orchestrator + 5 agents** system for Islamic text processing, utilizing Claude Code CLI agents with session-based authentication and container isolation.

## Architecture

### Fully Containerized Implementation

- **Knowledge Engineering Dashboard** (Port 8080): World-class monitoring with full pipeline transparency - **NEW**
- **Orchestrator Container** (Port 4000): Coordinates all agents and manages workflow
- **5 Specialized Agent Containers** (Ports 3001-3005): Individual Express servers with Claude CLI integration
- **Session-Based Authentication**: No API keys in environment, uses Claude CLI sessions
- **Container Isolation**: Secure multi-tier Docker network architecture with dashboard included
- **Auto-Restart**: Health monitoring with automatic agent recovery
- **Dependency Management**: Dashboard starts after orchestrator, orchestrator starts after all agents are healthy

### Seven-Container Architecture

1. **Dashboard** (Port 8080) - **NEW**: Knowledge engineering visibility interface with Google Cloud monitoring patterns
2. **Orchestrator** (Port 4000) - Workflow coordination and agent management
3. **Flowchart Mapper** (Port 3001) - Intellectual architecture analysis
4. **Network Mapper** (Port 3002) - Conceptual relationship mapping  
5. **Metadata Hunter** (Port 3003) - Bibliographic research
6. **Content Synthesizer** (Port 3004) - Catalog synthesis
7. **Data Pipeline** (Port 3005) - Production database integration

## Quick Start

### Prerequisites

1. **Claude CLI Authentication**:
   ```bash
   claude auth
   # Verify authentication file exists
   ls ~/.claude.json
   ```

2. **Docker and Docker Compose**:
   ```bash
   docker --version
   docker-compose --version
   ```

3. **Environment Configuration**:
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase and API keys
   ```

### Setup Authentication (claude-docker-model pattern)

⚠️ **IMPORTANT**: This system uses the proven claude-docker-model authentication pattern.

```bash
# Run the authentication setup script
./scripts/setup-auth.sh

# This script will:
# 1. Create persistent directories: ~/.claude-docker/claude-home and ~/.claude-docker/ssh
# 2. Copy .claude.json to build context (temporary)
# 3. Setup SSH keys for git operations (optional)
# 4. Prepare persistent Claude configuration
```

**Manual Setup** (if needed):
```bash
# Create persistent directories
mkdir -p ~/.claude-docker/claude-home
mkdir -p ~/.claude-docker/ssh

# Copy authentication to build context
cp ~/.claude.json .claude.json

# Setup SSH keys for git operations (optional)
ssh-keygen -t rsa -b 4096 -f ~/.claude-docker/ssh/id_rsa -N ''
# Add public key to GitHub: cat ~/.claude-docker/ssh/id_rsa.pub
```

### Start the Complete System

```bash
# Start dashboard + orchestrator + all 5 agents (fully containerized)
docker-compose up --build -d

# System starts in this order:
# 1. All 5 agents start first (ports 3001-3005)
# 2. Orchestrator waits for agents to be healthy (port 4000)
# 3. Dashboard starts last and connects to orchestrator (port 8080)

# Check dashboard health (should be accessible after ~30 seconds)
curl http://localhost:8080/health

# Access the Knowledge Engineering Dashboard
open http://localhost:8080

# Check orchestrator health
curl http://localhost:4000/health

# Check all agents through orchestrator
curl http://localhost:4000/agents-health
```

### Using the Knowledge Engineering Dashboard

```bash
# Access the world-class monitoring dashboard
open http://localhost:8080

# Dashboard API endpoints for programmatic access
curl http://localhost:8080/system-stats        # Enhanced system statistics
curl http://localhost:8080/processing-queue    # Current books with progress
curl http://localhost:8080/system-logs         # Real-time processing logs
curl http://localhost:8080/book/123           # Individual book workflow details
curl http://localhost:8080/agent/flowchart_mapper  # Agent work visibility
```

### Using the Orchestrator

```bash
# Initialize book reservoir
curl -X POST http://localhost:4000/initialize-reservoir

# Start assembly line processing
curl -X POST http://localhost:4000/start-assembly

# Monitor processing status
curl http://localhost:4000/reservoir-status

# Check token usage
curl http://localhost:4000/token-usage

# Stop pipeline
curl -X POST http://localhost:4000/stop-pipeline
```

### Docker Compose Commands

```bash
# Start all services (dashboard + orchestrator + 5 agents)
docker-compose up --build -d

# View logs
docker-compose logs -f                    # All services (dashboard + orchestrator + agents)
docker-compose logs -f dashboard         # Dashboard logs
docker-compose logs -f orchestrator      # Orchestrator logs
docker-compose logs -f flowchart_mapper  # Specific agent

# Restart specific services
docker-compose restart dashboard         # Restart dashboard
docker-compose restart orchestrator      # Restart orchestrator
docker-compose restart metadata_hunter   # Restart specific agent

# Stop all services
docker-compose down
```

## Agent-Specific Management

### Individual Service Health Checks
```bash
# Check dashboard health
curl http://localhost:8080/health  # Knowledge Engineering Dashboard

# Check orchestrator health
curl http://localhost:4000/health  # Orchestrator

# Check specific agent health
curl http://localhost:3001/health  # Flowchart Mapper
curl http://localhost:3002/health  # Network Mapper
curl http://localhost:3003/health  # Metadata Hunter
curl http://localhost:3004/health  # Content Synthesizer
curl http://localhost:3005/health  # Data Pipeline
```

### Agent Control via Orchestrator
```bash
# Restart specific agent
curl -X POST http://localhost:4000/restart-agent \
  -H "Content-Type: application/json" \
  -d '{"agentType": "flowchart_mapper"}'

# Start specific agent
curl -X POST http://localhost:4000/start-agent \
  -H "Content-Type: application/json" \
  -d '{"agentType": "metadata_hunter"}'

# Stop specific agent
curl -X POST http://localhost:4000/stop-agent \
  -H "Content-Type: application/json" \
  -d '{"agentType": "network_mapper"}'
```

### Agent Performance Monitoring
```bash
# Get detailed agent information
curl http://localhost:4000/agent-details/flowchart_mapper

# Check token usage for specific agent
curl http://localhost:4000/context-performance

# Reset agent context (performance optimization)
curl -X POST http://localhost:4000/restart-agent-context/metadata_hunter \
  -H "Content-Type: application/json" \
  -d '{"clearContext": true}'
```

## Configuration Management

### Persistent Configuration Hierarchy

1. **Global Configuration**: `~/.claude-docker/claude-home/`
2. **Agent-Specific Configuration**: `~/.claude-docker/claude-home/agents/{agent_name}/`
3. **Project Configuration**: `./.claude/`

### Agent-Specific Configuration Files

- `claude-configs/{agent_name}.json` - Agent behavior settings
- `claude-configs/{agent_name}.md` - Agent-specific CLAUDE.md instructions

## Session Management

### Session Continuation (claude-docker pattern)

Sessions automatically persist across container restarts:

```bash
# Start session
./scripts/islamic-text-claude-docker.sh --agent flowchart_mapper

# Continue existing session
./scripts/islamic-text-claude-docker.sh --agent flowchart_mapper --continue
```

### Session Storage

- **Session Metadata**: `/app/sessions/{agent_name}/session.json`
- **Claude Configuration**: `~/.claude-docker/claude-home/`
- **Project State**: `./.claude/`

## Security Features

### Container Security (claude-docker pattern)

- **Non-root execution** with matching host UID/GID
- **Capability dropping** with minimal required capabilities
- **Read-only filesystem** where possible
- **Tmpfs mounts** for temporary files
- **Network isolation** with dedicated bridge network

### Authentication Security

- **Build-time credential baking** eliminates runtime credential exposure
- **SSH key isolation** separate from host SSH keys
- **Credential persistence** in secure mounted volumes

## Resource Management

### Memory Allocation by Agent Type

- **Flowchart Mapper**: 1024M (complex intellectual architecture analysis)
- **Network/Metadata/Content**: 512M (standard processing)
- **Data Pipeline**: 256M (lightweight database operations)

### Resource Monitoring

```bash
# Monitor resource usage
docker stats --format "table {{.Container}}\\t{{.CPUPerc}}\\t{{.MemUsage}}"

# View agent logs
docker-compose logs -f flowchart_mapper

# Check health status
curl http://localhost:3001/health
```

## Troubleshooting

### System Health Issues

```bash
# Check dashboard health
curl http://localhost:8080/health

# Check orchestrator health
curl http://localhost:4000/health

# Check all agents
curl http://localhost:4000/agents-health

# View system errors
curl http://localhost:4000/system-errors?limit=10

# Dashboard-specific monitoring
curl http://localhost:8080/system-stats
curl http://localhost:8080/processing-queue
curl http://localhost:8080/system-logs
```

### Agent Issues

```bash
# Restart unresponsive agent
curl -X POST http://localhost:4000/restart-agent \
  -H "Content-Type: application/json" \
  -d '{"agentType": "flowchart_mapper"}'

# Kill stuck agent ports
curl -X POST http://localhost:4000/kill-agent-ports

# Clear processing queues
curl -X POST http://localhost:4000/clear-queues
```

### Performance Issues

```bash
# Check token usage (context degradation)
curl http://localhost:4000/context-performance

# Refresh all agents with fresh context
curl -X POST http://localhost:4000/refresh-all-agents \
  -H "Content-Type: application/json" \
  -d '{"clearContext": true}'

# Monitor resource usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## Integration with claude-docker Infrastructure

This implementation leverages patterns from `/infrastructure/claude-docker`:

- **Session Management**: Persistent Claude home directory mounting
- **Authentication**: Build-time credential copying with runtime persistence
- **Configuration**: Project-specific `.claude` directory handling
- **Resource Management**: Memory and CPU limits with proper scaling
- **Security**: Container hardening with capability management
- **Wrapper Scripts**: Simplified container lifecycle management

## Development Workflow

1. **Development**: Use wrapper script for rapid iteration
2. **Testing**: Use docker-compose for multi-agent scenarios  
3. **Production**: Deploy with orchestration tools (Kubernetes, Docker Swarm)

## Quick Reference

| Service | Port | Purpose | Container Status |
|---------|------|---------|------------------|
| **Dashboard** | 8080 | Knowledge engineering visibility interface | ✅ **NEW - CONTAINERIZED** |
| **Orchestrator** | 4000 | Main coordination server | ✅ **CONTAINERIZED** |
| **Flowchart Mapper** | 3001 | Intellectual architecture analysis | ✅ Containerized |
| **Network Mapper** | 3002 | Conceptual relationship mapping | ✅ Containerized |
| **Metadata Hunter** | 3003 | Bibliographic research | ✅ Containerized |
| **Content Synthesizer** | 3004 | Library catalog synthesis | ✅ Containerized |
| **Data Pipeline** | 3005 | Production database integration | ✅ Containerized |

## Development Resources

- **Quick Start Guide**: See `DEVELOPER_QUICK_START.md` for essential commands
- **Implementation Plan**: See `CLAUDE-CODE-INTEGRATION-PLAN.md` for architecture details
- **Current Architecture**: Orchestrator + 5 agents with session-based authentication

## Next Steps

1. **Load Testing**: Test system under realistic Islamic text processing workload
2. **Performance Optimization**: Monitor and optimize token usage patterns
3. **Production Deployment**: Deploy to production environment with monitoring
4. **Quality Assurance**: Validate Islamic scholarship accuracy

---

**Note**: This system provides sophisticated orchestration of 5 Claude Code CLI agents specialized in Islamic text processing, with a world-class knowledge engineering dashboard for full pipeline transparency. The orchestrator manages workflow coordination, health monitoring, and automatic recovery, while the dashboard provides real-time visibility into agent work, database progress, and individual book workflow stages.