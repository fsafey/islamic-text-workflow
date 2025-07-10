# Islamic Text Processing Agent Reservoir Workflow

> **Automated Islamic Text Enrichment Pipeline** - Transform books through 5 specialized AI agents for comprehensive metadata, categorization, and search enhancement

## 🚀 **Quick Start - Containerized Docker Deployment** ⭐ **RECOMMENDED**

### **What This Does**
This system processes Islamic texts through **7 containerized services** working in coordination:
- 🎛️ **Knowledge Engineering Dashboard** - World-class monitoring with full pipeline transparency (**NEW: Full visibility**)
- 🎛️ **Orchestrator** - Workflow coordination and agent management
- 📊 **Flowchart Mapper** - Intellectual architecture analysis  
- 🕸️ **Network Mapper** - Conceptual relationship mapping
- 🔍 **Metadata Hunter** - Bibliographic research
- 🔬 **Content Synthesizer** - Library catalog synthesis
- 🔄 **Data Pipeline** - Production database integration

### **Prerequisites - Setup First**
```bash
# 1. Ensure Docker and Docker Compose are installed
docker --version && docker-compose --version

# 2. Authenticate with Claude CLI (required for container authentication)
claude auth
ls ~/.claude.json  # Verify authentication file exists

# 3. Navigate to Docker deployment directory
cd /Users/farieds/imam-lib-masha-allah/islamic-text-workflow/agent-reservoir-workflow/production/docker

# 4. Setup environment configuration
cp .env.example .env
# Edit .env with your Supabase URL, Service Key, and other credentials
```

### **🐳 Launch Fully Containerized System** ⭐ **PREFERRED METHOD**

**Complete System Startup** (Dashboard + Orchestrator + All 5 Agents - 7 Containers Total)
```bash
# From docker directory: /production/docker/
docker-compose up --build -d

# ✅ Starts all 7 containers: dashboard (port 8080) + orchestrator (port 4000) + 5 agents (ports 3001-3005)
# ✅ Orchestrator waits for agents to be healthy before starting
# ✅ Dashboard starts after orchestrator and provides world-class monitoring
# ✅ Uses persistent Claude authentication with session management
# ✅ Includes health monitoring and auto-restart capabilities
```

**Verify Complete System Health** (Wait ~30 seconds for full startup)
```bash
# Check dashboard health (world-class monitoring interface)
curl http://localhost:8080/health

# Access the Knowledge Engineering Dashboard
open http://localhost:8080

# Check orchestrator health (starts after agents are healthy)
curl http://localhost:4000/health

# Check all agents through orchestrator
curl http://localhost:4000/agents-health

# View all container logs
docker-compose logs -f

# Check individual container status
docker-compose ps
```

### **🎮 Control Panel Operations**

**Dashboard Control (World-Class Monitoring)**
```bash
# Access the Knowledge Engineering Dashboard
open http://localhost:8080

# Dashboard API endpoints for programmatic access
curl http://localhost:8080/system-stats        # Enhanced system statistics
curl http://localhost:8080/processing-queue    # Current books with progress
curl http://localhost:8080/system-logs         # Real-time processing logs
curl http://localhost:8080/book/123           # Individual book workflow details
curl http://localhost:8080/agent/flowchart_mapper  # Agent work visibility
```

**Initialize Processing Queue**
```bash
# Initialize 1,019 Islamic text processing queue
curl -X POST http://localhost:4000/initialize-reservoir

# Start coordinated 5-agent processing pipeline
curl -X POST http://localhost:4000/start-assembly
```

**Monitor Processing Status**
```bash
# Check processing queue status
curl http://localhost:4000/reservoir-status

# View detailed pipeline status
curl http://localhost:4000/pipeline-status

# Monitor token usage across agents
curl http://localhost:4000/token-usage
```

**Individual Agent Control**
```bash
# Restart specific agent if unresponsive
curl -X POST http://localhost:4000/restart-agent \
  -H "Content-Type: application/json" \
  -d '{"agentType": "flowchart_mapper"}'

# Check specific service health
curl http://localhost:8080/health  # Knowledge Engineering Dashboard
curl http://localhost:4000/health  # Orchestrator
curl http://localhost:3001/health  # Flowchart Mapper
curl http://localhost:3002/health  # Network Mapper
curl http://localhost:3003/health  # Metadata Hunter
curl http://localhost:3004/health  # Content Synthesizer
curl http://localhost:3005/health  # Data Pipeline
```

### **⚡ Expected Performance**
- **Processing Capacity**: 600+ books/hour 
- **Queue Size**: 1,019 Islamic texts ready for enrichment
- **Completion Time**: ~1.7 hours for full pipeline
- **Output Quality**: 25+ metadata fields per book with scholarly accuracy

### **🔧 Container Management Commands**

**Service Control** (7 Containers: Dashboard + Orchestrator + 5 Agents)
```bash
# View all container status (dashboard + orchestrator + 5 agents)
docker-compose ps

# View logs for specific services
docker-compose logs -f dashboard         # Dashboard logs
docker-compose logs -f orchestrator      # Orchestrator logs
docker-compose logs -f flowchart_mapper  # Specific agent logs

# Restart specific services
docker-compose restart dashboard         # Restart dashboard
docker-compose restart orchestrator      # Restart workflow coordinator
docker-compose restart metadata_hunter   # Restart specific agent

# Stop all services (dashboard + orchestrator + agents)
docker-compose down

# Start services with fresh build (7 containers)
docker-compose up --build -d
```

**Resource Monitoring**
```bash
# Monitor container resource usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# View agent network isolation
docker network ls | grep islamic_text
docker network inspect islamic_text_agents
```

---

## 🔧 **What Each Agent Does**

### **Agent 1: Flowchart Mapper** (Port 3001)
- **Analyzes**: Intellectual architecture and argument structures
- **Outputs**: Reasoning patterns, complexity assessments, inferential frameworks
- **Example**: "This text employs syllogistic reasoning with Aristotelian foundations..."

### **Agent 2: Network Mapper** (Port 3002) 
- **Analyzes**: Conceptual relationships and knowledge networks
- **Outputs**: Key concepts, thematic connections, ideological positioning
- **Example**: "Central concepts: jihad, tawhid, fiqh. Interconnections: legal→theological→practical..."

### **Agent 3: Metadata Hunter** (Port 3003)
- **Researches**: Authentic bibliographic information using scholarly sources
- **Outputs**: Arabic titles, author names, publication details, historical context
- **Example**: "Original Arabic: كتاب الجهاد، Author: أبو حامد الغزالي، Period: 11th century..."

### **Agent 4: Content Synthesizer** (Port 3004)
- **Synthesizes**: Previous agent outputs into library catalog format
- **Outputs**: Descriptions, categories, keywords, difficulty levels
- **Example**: "A comprehensive treatise on Islamic jurisprudence combining theoretical foundations..."

### **Agent 5: Data Pipeline** (Port 3006)
- **Updates**: Production database with enriched metadata
- **Outputs**: Populated book records, search optimization, Algolia sync
- **Example**: Updates your `books` table with 25+ new fields per record

---

## 🗄️ **Database Integration**

### **What Gets Updated**
Your existing Supabase database tables get enhanced:
- **`books`** - Title aliases, keywords, descriptions, Arabic metadata
- **`book_metadata`** - Historical periods, difficulty levels, content types  
- **`categories`** - Expanded classification with weighted relationships
- **Search indexes** - Optimized for better discovery and filtering

### **Processing States** 
Books move through these stages in your `book_enrichment_reservoir` table:
- `pending` → `flowchart` → `network` → `metadata` → `synthesis` → `completed`

### **Monitor Progress**
```sql
-- Check processing status
SELECT processing_stage, COUNT(*) 
FROM book_enrichment_reservoir 
GROUP BY processing_stage;

-- View recent completions
SELECT title, author_name, created_at, updated_at
FROM book_enrichment_reservoir 
WHERE synthesis_completed = true
ORDER BY updated_at DESC
LIMIT 10;
```

---

## 🔍 **Troubleshooting Common Issues**

### **Dashboard Won't Load**
```bash
# Check if port 4000 is already in use
lsof -i:4000

# Kill existing processes
lsof -ti:4000 | xargs kill -9

# Restart\

npm run dev
```

### **Agents Show Offline**
```bash
# Check if all agent ports are available
lsof -i:3001,3002,3003,3004,3006

# Clear any stuck processes
pkill -f "enhanced-.*-agent"

# Use Dashboard "Start Assembly" button to relaunch
```

### **No Books Processing**
```bash
# Check if reservoir is initialized
curl http://localhost:4000/reservoir-status

# Initialize manually if needed
curl -X POST http://localhost:4000/initialize-reservoir
```

### **Database Connection Issues**
- Verify Supabase credentials in `orchestrator.js:18-21`
- Ensure your database has the `book_enrichment_reservoir` table
- Check network connectivity to Supabase

---

## 🛠️ **Alternative Deployment Methods**

### **Legacy Node.js Deployment** (Not Recommended)
If Docker is unavailable, use the legacy orchestration method:

```bash
# Navigate to orchestration directory
cd /Users/farieds/imam-lib-masha-allah/islamic-text-workflow/agent-reservoir-workflow/production/orchestration

# Install dependencies (first time only)
npm install

# Start dashboard interface
npm run dev

# Manually navigate to: http://localhost:4000/monitor/
```

**Manual Agent Control** (For Development/Debugging)
```bash
# Navigate to project root first
cd /Users/farieds/imam-lib-masha-allah/islamic-text-workflow/agent-reservoir-workflow

# Run orchestrator manually
node production/orchestration/orchestrator.js

# Run individual agents (separate terminals) - from project root
node production/agents/enhanced-flowchart-mapper-agent.js
node production/agents/enhanced-network-mapper-agent.js  
node production/agents/enhanced-metadata-hunter-agent.js
node production/agents/content-synthesizer-agent.js
node production/agents/data-pipeline-agent.js
```

### **🔗 Complete API Reference**

**Health Monitoring**
```bash
curl http://localhost:4000/health                    # Orchestrator health
curl http://localhost:4000/agents-health             # All agents status
curl http://localhost:4000/system-errors?limit=10    # System error logs
```

**Pipeline Control**
```bash
curl -X POST http://localhost:4000/initialize-reservoir  # Setup processing queue
curl -X POST http://localhost:4000/start-assembly        # Begin processing
curl -X POST http://localhost:4000/stop-pipeline         # Emergency stop
curl -X POST http://localhost:4000/clear-queues          # Reset queues
```

**Status Monitoring**
```bash
curl http://localhost:4000/reservoir-status              # Queue status
curl http://localhost:4000/pipeline-status               # Processing status
curl http://localhost:4000/token-usage                   # Resource usage
curl http://localhost:4000/context-performance           # Performance metrics
```

**Agent Management**
```bash
# Restart specific agent
curl -X POST http://localhost:4000/restart-agent \
  -H "Content-Type: application/json" \
  -d '{"agentType": "flowchart_mapper"}'

# Get agent details
curl http://localhost:4000/agent-details/metadata_hunter

# Refresh all agents with fresh context
curl -X POST http://localhost:4000/refresh-all-agents \
  -H "Content-Type: application/json" \
  -d '{"clearContext": true}'
```

---

## 📖 **Additional Documentation**

### **Docker-Specific Documentation**
- **[Docker Implementation Guide](production/docker/README.md)** - Complete containerized deployment documentation
- **[Docker Configuration](production/docker/CLAUDE.md)** - Agent-specific configuration and security settings
- **[Quick Start Guide](production/docker/DEVELOPER_QUICK_START.md)** - Essential Docker commands for development

### **Legacy Documentation**
- **[System Architecture](docs/LOCAL-ORCHESTRATION-GUIDE.md)** - Technical deep-dive into the 5-agent system
- **[Assembly Line Setup](docs/ASSEMBLY-LINE-README.md)** - Step-by-step configuration guide (legacy)
- **[Agent Methodologies](guidance/)** - Individual agent prompts and approaches

### **Current File Structure**
```
agent-reservoir-workflow/
├── production/
│   ├── docker/              # ⭐ CONTAINERIZED DEPLOYMENT (RECOMMENDED)
│   │   ├── docker-compose.yml
│   │   ├── Dockerfile
│   │   ├── orchestrator.js
│   │   ├── agents/          # 5 specialized agents
│   │   ├── claude-configs/  # Agent-specific configurations
│   │   └── scripts/         # Container startup scripts
│   ├── orchestration/       # Legacy Node.js deployment
│   └── agents/              # Individual agent implementations
├── docs/                    # Documentation (mostly legacy)
└── guidance/                # Agent prompt engineering
```

---

## 🎯 **Success Indicators**

### **Complete Containerized System Health Indicators**
- ✅ All 7 containers running: `docker-compose ps` (dashboard + orchestrator + 5 agents)
- ✅ Dashboard responds: `curl http://localhost:8080/health`
- ✅ Dashboard UI accessible: `open http://localhost:8080`
- ✅ Orchestrator responds: `curl http://localhost:4000/health` 
- ✅ All agents respond: `curl http://localhost:300[1-5]/health`
- ✅ Orchestrator reports agents healthy: `curl http://localhost:4000/agents-health`
- ✅ Processing progress increases: `curl http://localhost:4000/reservoir-status`
- ✅ No critical errors: `docker-compose logs | grep ERROR`

### **Expected Performance**
- **Processing Speed**: 600+ books/hour at full capacity
- **Quality Rate**: 90%+ books successfully complete all stages
- **Accuracy**: 85%+ authentic Arabic metadata discovery
- **Completeness**: 25+ fields populated per book

### **Completion Criteria**
- ✅ All 1,019 books processed through 5-stage pipeline
- ✅ Production database updated with enriched metadata
- ✅ Search functionality enhanced with new fields
- ✅ Quality validation passed for academic standards

---

## 🏆 **What You'll Achieve**

**Before**: Basic book records with minimal metadata
**After**: Comprehensive Islamic library with:
- 📚 Rich bibliographic metadata (authentic Arabic titles, authors)
- 🏷️ Intelligent categorization (genre, methodology, historical period)
- 🔍 Enhanced search capabilities (keywords, descriptions, complexity levels)
- 🎯 Academic quality annotations (sectarian awareness, scholarly context)
- 📊 Intellectual architecture analysis (argument structures, reasoning patterns)

**Result**: A professionally enhanced Islamic digital library ready for scholarly research, educational use, and public access with authentic, academically rigorous metadata.

---

## 🚨 **Troubleshooting Docker Issues**

### **Container Won't Start**
```bash
# Check Docker daemon status
docker info

# Clear any conflicting containers
docker-compose down --volumes --remove-orphans

# Rebuild with fresh images
docker-compose up --build --force-recreate -d
```

### **Authentication Issues**
```bash
# Verify Claude CLI authentication
claude auth
ls ~/.claude.json

# Check container has access to auth
docker-compose exec flowchart_mapper ls -la /home/claude/.claude/

# Restart with auth reset
docker-compose down && docker-compose up --build -d
```

### **Agent Unresponsive**
```bash
# Check specific agent logs
docker-compose logs flowchart_mapper

# Restart specific service
docker-compose restart metadata_hunter

# Force recreate unresponsive agent
docker-compose up --force-recreate flowchart_mapper -d
```

### **Port Conflicts**
```bash
# Check for port conflicts
lsof -i:8080,4000,3001,3002,3003,3004,3005

# Kill conflicting processes
docker-compose down
pkill -f "enhanced-.*-agent"
docker-compose up -d
```

---

*This **fully containerized system** transforms raw book data into a sophisticated Islamic digital library through 7 coordinated Docker containers. The complete containerization (including orchestrator and world-class knowledge engineering dashboard) provides enhanced security, isolation, persistent authentication, and eliminates host dependency issues - solving the Claude CLI hanging problems that affected previous implementations. The dashboard provides full pipeline transparency for knowledge engineers to track agent work, monitor database progress, and view individual book workflow stages.*

