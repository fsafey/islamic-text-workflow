# Islamic Text Workflow Dev Container

## 🚀 Complete Development Environment with Neo4j & Graphiti

This dev container provides a complete environment for Islamic text analysis with Graphiti knowledge graphs and Neo4j database. **Neo4j, Graphiti, and Claude Code are now core dependencies** and automatically configured on startup.

## 🌟 What's Included

### Neo4j Database
- **UI**: http://localhost:7474
- **Bolt**: bolt://neo4j:7687 
- **Credentials**: neo4j/password
- **Purpose**: Persistent knowledge graph storage

### Graphiti Knowledge Graph
- Real-time knowledge tracking
- Islamic text analysis
- Project decision tracking
- Cross-session memory

### Claude Code (Built-in)
- Anthropic's official CLI pre-installed
- Multi-instance support for parallel processing
- Specialized analysis modes
- Coordinated workflows

## 🚀 Quick Start

### 1. Start the Dev Container
```bash
# From VS Code: Command Palette → "Reopen in Container"
# Or manually:
cd .devcontainer
docker-compose up -d
```

### 2. Install Optional Dependencies
```bash
# Inside the container (optional)
pkg dev-tools       # Install development tools
pkg python-dev      # Install Python development tools
```

### 3. Everything Ready to Use
```bash
# All core tools are automatically configured!
claude              # Start Claude Code
gst                 # Check system status
```

### 4. Start Using Knowledge Graph
```bash
gr "Starting my development session"
gs "development"
gst                 # Check status
```

## 🧠 Knowledge Graph Commands

### Basic Operations
```bash
gr "text"           # Remember in knowledge graph
gs "query"          # Search knowledge graph  
gt "file.txt"       # Analyze text content
gst                 # Show system status
```

### Project Tracking
```bash
pstart "session"    # Start development session
pend "summary"      # End session with summary
pdecision "choice"  # Track technical decisions
pfeature "name"     # Track feature development
```

## 📊 Services Architecture

### App Container
- Base: Python 3.11 + Node.js 18
- User: developer
- Workspace: /workspace
- **Core Dependencies**: Claude Code, Graphiti, Neo4j client, FastAPI, etc.
- Auto-loads Graphiti commands and configuration

### Neo4j Container
- Image: neo4j:5.15
- Ports: 7474 (UI), 7687 (Bolt)
- Plugins: APOC
- Memory: 512MB-1GB heap

## 🔧 Configuration

### Environment Variables
```bash
NEO4J_URI=bolt://neo4j:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=password
GRAPHITI_DATA_DIR=/workspace/graphiti-data
```

### Auto-loaded Scripts
- `/workspace/tools/scripts/graphiti-commands.sh` - Graphiti commands
- Aliases: `gr`, `gs`, `gt`, `gst`
- Project tracking commands

## 🔍 Troubleshooting

### Neo4j Not Starting
```bash
# Check logs
docker-compose logs neo4j

# Restart service
docker-compose restart neo4j
```

### Graphiti Commands Not Working
```bash
# Reload commands
source /workspace/tools/scripts/graphiti-commands.sh

# Check status
gst
```

## 💡 Pro Tips

1. **Everything is auto-configured** on container startup
2. **Claude Code ready immediately** - just run `claude`
3. **Check `gst`** to verify all services are running
4. **Use multiple dev containers** for parallel Claude instances
5. **All containers share** the same `/workspace` directory
6. **Neo4j data persists** across container restarts
7. **Core dependencies built-in** - no manual setup needed

## 🔗 Integration

This dev container integrates seamlessly with:
- Graphiti framework (`/workspace/graphiti-main/`)
- Islamic text analysis tools
- Claude Docker API integration
- Knowledge graph persistence
- Multi-instance coordination

For complete usage patterns, see `/workspace/CLAUDE.md`.