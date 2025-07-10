# Islamic Text Processing Agents - Developer Quick Start

## 🚀 **Quick Start (1 Minute)**

```bash
# Navigate to Docker directory
cd islamic-text-workflow/agent-reservoir-workflow/production/docker

# Copy environment template
cp .env.example .env
# Edit .env: Set ANTHROPIC_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_KEY

# Start all services
docker-compose up --build -d

# Check status
curl http://localhost:4000/health  # Orchestrator
curl http://localhost:3001/health  # Flowchart Mapper
curl http://localhost:3002/health  # Network Mapper
curl http://localhost:3003/health  # Metadata Hunter
curl http://localhost:3004/health  # Content Synthesizer
curl http://localhost:3005/health  # Data Pipeline
```

## 🎯 **Current Architecture**

```
Orchestrator (Port 4000)
├── Flowchart Mapper (Port 3001) - Intellectual architecture analysis
├── Network Mapper (Port 3002) - Conceptual relationship mapping
├── Metadata Hunter (Port 3003) - Bibliographic research
├── Content Synthesizer (Port 3004) - Library catalog synthesis
└── Data Pipeline (Port 3005) - Production database integration
```

## 🔧 **Essential Commands**

### Development
```bash
# Start all agents
docker-compose up --build -d

# View logs
docker-compose logs -f                    # All agents
docker-compose logs -f flowchart_mapper  # Specific agent

# Restart specific agent
docker-compose restart metadata_hunter

# Stop all
docker-compose down
```

### Orchestrator Control
```bash
# Start assembly line processing
curl -X POST http://localhost:4000/start-assembly

# Check reservoir status
curl http://localhost:4000/reservoir-status

# Agent health check
curl http://localhost:4000/agents-health

# View token usage
curl http://localhost:4000/token-usage

# Emergency stop
curl -X POST http://localhost:4000/stop-pipeline
```

### Monitoring
```bash
# Resource usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Health checks
for port in 3001 3002 3003 3004 3005; do
  echo "Agent on port $port:"
  curl -s http://localhost:$port/health | jq -r '.status'
done

# View structured logs
docker-compose logs --since=1h | grep -E "(ERROR|WARN)"
```

## 🏗️ **Key Components**

### Orchestrator (`orchestrator.js`)
- **Port**: 4000
- **Purpose**: Coordinates all 5 agents, manages workflow
- **Key Endpoints**:
  - `/health` - System status
  - `/start-assembly` - Begin processing
  - `/agents-health` - Check all agents
  - `/token-usage` - Monitor token consumption

### Agents (Ports 3001-3005)
- **Individual servers**: Each agent runs as Express server
- **Common endpoints**: `/health`, `/process`, `/agent-tokens`, `/reset-tokens`
- **Session-based**: Uses Claude CLI session management
- **Auto-restart**: Orchestrator restarts agents on failure

## 🔄 **Production Workflow**

### 1. Initialize System
```bash
# Start orchestrator + all agents
docker-compose up --build -d

# Initialize reservoir with books
curl -X POST http://localhost:4000/initialize-reservoir
```

### 2. Process Books
```bash
# Start assembly line processing
curl -X POST http://localhost:4000/start-assembly

# Monitor progress
curl http://localhost:4000/reservoir-status
```

### 3. Monitor Health
```bash
# Check all agent health
curl http://localhost:4000/agents-health

# View processing metrics
curl http://localhost:4000/processing-metrics
```

## 🛠️ **Troubleshooting**

### Common Issues
```bash
# Agent not responding
docker-compose restart [agent-name]

# Kill stuck agent ports
curl -X POST http://localhost:4000/kill-agent-ports

# Clear processing queues
curl -X POST http://localhost:4000/clear-queues

# Reset agent contexts (token limits)
curl -X POST http://localhost:4000/refresh-all-agents
```

### Debug Mode
```bash
# View detailed logs
docker-compose logs -f --tail=100 flowchart_mapper

# Check container health
docker-compose ps

# Inspect specific agent
curl http://localhost:4000/agent-details/flowchart_mapper
```

### Performance Optimization
```bash
# Check token usage
curl http://localhost:4000/context-performance

# Restart agents with fresh context
curl -X POST http://localhost:4000/restart-agent-context/flowchart_mapper \
  -H "Content-Type: application/json" \
  -d '{"clearContext": true}'
```

## 📊 **Monitoring Dashboards**

### Real-time Status
```bash
# System overview
curl http://localhost:4000/health | jq

# Processing pipeline
curl http://localhost:4000/pipeline-status | jq

# Agent performance
curl http://localhost:4000/enhanced-monitoring | jq
```

### Historical Data
```bash
# System errors
curl http://localhost:4000/system-errors?limit=10 | jq

# Agent workflow
curl http://localhost:4000/reservoir-workflow | jq
```

## 🔐 **Security Features**

- **Container isolation**: Each agent runs in isolated container
- **Network segmentation**: Multi-tier Docker networks
- **Resource limits**: CPU/memory constraints per agent
- **Session-based auth**: No API keys in environment
- **Health monitoring**: Auto-restart on failure

## 📁 **Project Structure**

```
production/docker/
├── orchestrator.js           # Main orchestration server
├── docker-compose.yml        # Production container setup
├── Dockerfile               # Container definition
├── agents/                  # 5 agent implementations
│   ├── enhanced-flowchart-mapper-agent.js
│   ├── enhanced-network-mapper-agent.js
│   ├── enhanced-metadata-hunter-agent.js
│   ├── content-synthesizer-agent.js
│   └── data-pipeline-agent.js
├── lib/                     # Core utilities
│   ├── ClaudeCodeExecutor.js
│   ├── TokenTracker.js
│   └── TaskLogger.js
├── claude-configs/          # Agent configurations
└── scripts/                 # Utility scripts
```

## 🎯 **Quick Reference**

| Service | Port | Purpose |
|---------|------|---------|
| Orchestrator | 4000 | Main coordination |
| Flowchart Mapper | 3001 | Architecture analysis |
| Network Mapper | 3002 | Conceptual networks |
| Metadata Hunter | 3003 | Bibliographic research |
| Content Synthesizer | 3004 | Catalog synthesis |
| Data Pipeline | 3005 | Database integration |

## 📚 **Next Steps**

1. **Run the system**: `docker-compose up --build -d`
2. **Check health**: `curl http://localhost:4000/health`
3. **Start processing**: `curl -X POST http://localhost:4000/start-assembly`
4. **Monitor progress**: `curl http://localhost:4000/reservoir-status`

---

**Note**: This system uses sophisticated orchestration with 5 Claude Code CLI agents working together to process Islamic texts. Each agent specializes in different aspects of text analysis and library cataloging.