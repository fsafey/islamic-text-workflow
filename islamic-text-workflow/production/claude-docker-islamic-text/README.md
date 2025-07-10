# Islamic Text Processing Claude Docker

A complete Islamic text processing system with Claude Code agents, specialized for scholarly analysis and metadata enrichment of Islamic texts.

📋 **MCP Setup Guide**: See [MCP_SERVERS.md](MCP_SERVERS.md) for customizing MCP servers

## 🕌 Islamic Text Processing System

This is a specialized implementation of the claude-docker-model for Islamic scholarly text processing.

## What This Does
- **5 Specialized Agents** for Islamic text analysis and enrichment
- **Orchestrated Workflow** for processing books from pending → completed states
- **Pre-configured MCP servers** for enhanced productivity:
  - **Filesystem** - File access across all agents
  - **Memory** - Inter-agent communication and knowledge sharing
  - **Browser** - Metadata research and validation
  - **Context7** - Islamic scholarship documentation lookup
  - **Twilio** - SMS notifications for long-running processes (optional)
  - **GitHub** - Version control integration (optional)
- **Persistent conversation history** - Resumes processing from where it left off
- **Supabase Integration** - Direct database operations for book enrichment
- **Dashboard Monitoring** - Real-time visibility into processing pipeline

## Quick Start
```bash
# 0. Prerequisites: claude-code, docker, and docker-compose installed

# 1. Clone/navigate to project
cd /path/to/islamic-text-workflow/agent-reservoir-workflow/production/claude-docker-islamic-text

# 2. Setup environment
cp .env.example .env
nano .env  # Add your Supabase credentials

# 3. Install
./scripts/install.sh

# 4. Run agents
islamic-text-claude --agent orchestrator    # Terminal 1
islamic-text-claude --agent dashboard       # Terminal 2
islamic-text-claude --agent flowchart_mapper # Terminal 3 (optional)
```

## Prerequisites

⚠️ **IMPORTANT**: Complete these steps BEFORE using the system:

### 1. Claude Code Authentication (Required)
```bash
# Install and authenticate Claude Code
npm install -g @anthropic-ai/claude-code
claude auth

# Verify authentication
ls ~/.claude.json ~/.claude/
```

### 2. Docker Installation (Required)
- **Docker Desktop**: https://docs.docker.com/get-docker/
- **Docker Compose**: Usually included with Docker Desktop

### 3. Supabase Configuration (Required)
Create `.env` file with your Supabase credentials:
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-key
```

### 4. SSH Keys (Optional - for git operations)
```bash
# Generate SSH keys for the Islamic text processing system
ssh-keygen -t rsa -b 4096 -f ~/.claude-docker/ssh/id_rsa -N ''

# Add public key to GitHub
cat ~/.claude-docker/ssh/id_rsa.pub
# Copy and add to GitHub → Settings → SSH Keys

# Test connection
ssh -T git@github.com -i ~/.claude-docker/ssh/id_rsa
```

### 5. Twilio SMS (Optional - for notifications)
Add to your `.env` file:
```bash
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
TWILIO_FROM_NUMBER=+1234567890
TWILIO_TO_NUMBER=+0987654321
```

## Islamic Text Processing Agents

### 🔧 **What Each Agent Does**

#### **Agent 1: Flowchart Mapper** (Port 3001)
- **Analyzes**: Intellectual architecture and argument structures
- **Outputs**: Reasoning patterns, complexity assessments, inferential frameworks
- **Example**: "This text employs syllogistic reasoning with Aristotelian foundations..."

#### **Agent 2: Network Mapper** (Port 3002) 
- **Analyzes**: Conceptual relationships and knowledge networks
- **Outputs**: Key concepts, thematic connections, ideological positioning
- **Example**: "Central concepts: jihad, tawhid, fiqh. Interconnections: legal→theological→practical..."

#### **Agent 3: Metadata Hunter** (Port 3003)
- **Researches**: Authentic bibliographic information using scholarly sources
- **Outputs**: Arabic titles, author names, publication details, historical context
- **Example**: "Original Arabic: كتاب الجهاد، Author: أبو حامد الغزالي، Period: 11th century..."

#### **Agent 4: Content Synthesizer** (Port 3004)
- **Synthesizes**: Previous agent outputs into library catalog format
- **Outputs**: Descriptions, categories, keywords, difficulty levels
- **Example**: "A comprehensive treatise on Islamic jurisprudence combining theoretical foundations..."

#### **Agent 5: Data Pipeline** (Port 3005)
- **Updates**: Production database with enriched metadata
- **Outputs**: Populated book records, search optimization, Algolia sync
- **Example**: Updates your `books` table with 25+ new fields per record

### 🗄️ **Database Integration**

#### **What Gets Updated**
Your existing Supabase database tables get enhanced:
- **`books`** - Title aliases, keywords, descriptions, Arabic metadata
- **`book_metadata`** - Historical periods, difficulty levels, content types  
- **`categories`** - Expanded classification with weighted relationships
- **Search indexes** - Optimized for better discovery and filtering

#### **Processing States** 
Books move through these stages in your `book_enrichment_reservoir` table:
- `pending` → `flowchart` → `network` → `metadata` → `synthesis` → `completed`

## Usage Examples

### Individual Agent Usage
```bash
# Start specific agents
islamic-text-claude --agent flowchart_mapper
islamic-text-claude --agent network_mapper
islamic-text-claude --agent metadata_hunter
islamic-text-claude --agent content_synthesizer
islamic-text-claude --agent data_pipeline

# Start management components
islamic-text-claude --agent orchestrator
islamic-text-claude --agent dashboard
```

### Workflow Management
```bash
# Continue previous session
islamic-text-claude --agent orchestrator --continue

# Force rebuild (after updating .env)
islamic-text-claude --agent orchestrator --rebuild

# Use custom memory limit
islamic-text-claude --agent orchestrator --memory 2g
```

### Full Pipeline Setup
```bash
# Terminal 1: Start orchestrator
islamic-text-claude --agent orchestrator

# Terminal 2: Start dashboard
islamic-text-claude --agent dashboard

# Terminal 3: Monitor specific agent
islamic-text-claude --agent metadata_hunter --continue
```

## Features

### 🤖 Full Islamic Text Processing Autonomy
- Agents run with complete access to process Islamic texts
- No permission prompts for scholarly analysis operations
- Specialized for Islamic academic and theological content

### 🔌 Islamic Scholarship MCP Integration
- **Filesystem**: Access to Islamic text files and resources
- **Memory**: Knowledge base for Islamic concepts and terminology
- **Browser**: Research capabilities for Islamic sources
- **Context7**: Islamic scholarship documentation lookup
- **Supabase**: Direct database operations for book enrichment

### 📱 SMS Notifications for Long Processes
- Get notified when book processing completes
- Ideal for large-scale Islamic library processing
- Step away while agents work on extensive collections

### 🔑 Persistent Islamic Text Processing
- Sessions continue across restarts
- Islamic text processing state maintained
- Authentication persists for extended scholarly work

### 📊 Monitoring Dashboard
- Real-time view of book processing pipeline
- Agent health and performance monitoring
- Processing statistics and completion rates

## Configuration

### Agent-Specific Configuration
Edit files in `claude-configs/` to customize agent behavior:
- `flowchart-mapper.claude.json` - Intellectual analysis parameters
- `metadata-hunter.claude.json` - Research source preferences
- `content-synthesizer.claude.json` - Catalog format specifications

### MCP Server Configuration
Edit `mcp-servers.txt` to add or modify MCP servers:
```bash
# Add new MCP server
claude mcp add -s user new-server -- npx -y @provider/new-server

# Add server with environment variables
claude mcp add-json custom -s user '{"command":"npx","args":["-y","@provider/custom"],"env":{"API_KEY":"${CUSTOM_API_KEY}"}}'
```

## Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
docker logs islamic-text-claude-$(basename $(pwd))-$$

# Rebuild image
islamic-text-claude --agent orchestrator --rebuild
```

#### Authentication Issues
```bash
# Verify Claude authentication
ls ~/.claude.json ~/.claude/

# Re-authenticate if needed
claude auth
```

#### Database Connection Issues
```bash
# Check .env file
cat .env

# Test Supabase connection
psql $SUPABASE_URL
```

### Getting Help
- Check agent logs in dashboard
- Review processing state in Supabase
- Verify MCP server configuration
- Ensure all prerequisites are met

## Security Notes
- Credentials are baked into Docker image during build
- SSH keys are isolated in separate directory
- Each agent runs in isolated container
- Database operations use service key authentication

## Development
- Modify agent behavior in `claude-configs/`
- Add new MCP servers in `mcp-servers.txt`
- Extend dashboard in `orchestration-visibility/`
- Update Islamic text processing logic in agent files

---

**Created for**: Islamic scholarly text processing and library management
**Based on**: claude-docker-model architecture patterns
**Specialized for**: Academic rigor in Islamic text analysis