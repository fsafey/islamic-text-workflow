# Islamic Text Workflow Dev Container Guide

## 🚀 Overview

This dev container provides a complete development environment for the Islamic Text Workflow project, including:
- **Python 3.11** development environment
- **Neo4j** knowledge graph database
- **Claude Docker API** integration
- **All project tools and aliases** pre-configured
- **VS Code extensions** for optimal development
- **Documentation server** for easy reference

## 🎯 Quick Start

### 1. Prerequisites
- Docker Desktop installed and running
- VS Code with Remote-Containers extension
- Your `~/.claude-docker` authentication set up

### 2. Launch Dev Container
1. Open the project in VS Code
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
3. Type "Dev Containers: Reopen in Container"
4. Wait for the container to build and initialize

### 3. First Run
After the container starts:
```bash
# Check that everything is working
islamic-dev

# View development status
dev-status

# Test knowledge graph connection
test-knowledge
```

## 🏗️ Architecture

### Services Included
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Development   │  │     Neo4j       │  │ Claude Docker   │
│   Container     │  │   Database      │  │      API        │
│   (Python 3.11) │  │  (Knowledge     │  │  (3 Workers)    │
│                 │  │   Graph)        │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                              │
                 ┌─────────────────┐
                 │ Documentation   │
                 │    Server       │
                 │    (Nginx)      │
                 └─────────────────┘
```

### Port Mapping
- **7474**: Neo4j Browser (http://localhost:7474)
- **7687**: Neo4j Bolt protocol (for applications)
- **8000**: Claude Docker API
- **8080**: Documentation server

## 🔧 Development Workflow

### Essential Commands
```bash
# Navigate to workspace
ws

# Start Claude instances
claude2                    # Interactive development
claude-islamic            # Islamic NLP specialist
claude-graphiti           # Knowledge graph worker
claude-engineering        # Software engineering mode

# Knowledge graph operations
gr "Remember this insight"     # Store knowledge
gs "search query"             # Search knowledge
gt "/path/to/file.txt"        # Analyze text file
gst                           # System status

# Project tracking
pstart "session-name"         # Start work session
pdecision "choice made"       # Track decisions
pfeature "name" "status"      # Track features
pproblem "issue" "solution"   # Track problems
pend "summary"               # End session
```

### Development Cycle
1. **Start session**: `pstart "feature-development"`
2. **Work with tools**: Use `claude2`, `gr`, `gs`, etc.
3. **Track progress**: Use `pdecision`, `pfeature` as needed
4. **End session**: `pend "accomplished X and Y"`

## 📁 Project Structure

```
/workspace/
├── .devcontainer/          # Dev container configuration
├── claude-configs/         # Claude instance configurations
│   ├── interactive/CLAUDE.md
│   ├── islamic-nlp/CLAUDE.md
│   └── ...
├── documentation/          # Project documentation
├── graphiti-main/         # Graphiti framework
├── tools/scripts/         # Development scripts
└── research/              # Research outputs
```

## 🛠️ Configuration

### VS Code Extensions Included
- Python development (python, debugpy, pylint)
- Docker support
- Neo4j browser integration
- Jupyter notebook support
- Markdown tools
- GitHub Copilot (if available)

### Environment Variables
- `PYTHONPATH`: /workspace:/workspace/graphiti-main
- `ISLAMIC_TEXT_WORKFLOW`: /workspace
- `NEO4J_URI`: bolt://neo4j:7687
- `NEO4J_USER`: neo4j
- `NEO4J_PASSWORD`: islamictext2024
- `CLAUDE_DOCKER_API`: http://claude-docker-api:8000

## 🔍 Troubleshooting

### Container Won't Start
1. Check Docker Desktop is running
2. Ensure ports 7474, 7687, 8000, 8080 are available
3. Check that `~/.claude-docker` exists and has authentication

### Services Not Responding
```bash
# Check service status
dev-status

# Check specific services
curl http://localhost:7474   # Neo4j
curl http://localhost:8000   # Claude Docker API
docker ps                   # All containers
```

### Neo4j Connection Issues
1. Wait for full initialization (can take 30-60 seconds)
2. Check browser at http://localhost:7474
3. Use credentials: neo4j/islamictext2024

### Claude Docker API Problems
1. Ensure your host `~/.claude-docker` has valid authentication
2. Check API health: `curl http://localhost:8000/health`
3. Restart container if needed

## 🚀 Advanced Usage

### Custom Configuration
Edit files in `.devcontainer/` and rebuild:
```bash
# In VS Code Command Palette
Dev Containers: Rebuild Container
```

### Adding Python Packages
```bash
# Install in container
pip install --user package-name

# Or add to requirements.txt and rebuild
```

### Database Management
```bash
# Access Neo4j browser
neo4j-browser

# Run Cypher queries
docker exec -it islamic-text-workflow-neo4j-1 \
  cypher-shell -u neo4j -p islamictext2024
```

### Multi-Instance Development
The dev container supports multiple Claude instances:
- Main development in VS Code terminal
- `claude2` for parallel work
- Specialized modes for specific tasks
- All share the same knowledge graph

## 🎯 Best Practices

### Development Workflow
1. **Use knowledge graph extensively** - `gr` for insights, `gs` for searching
2. **Track decisions and features** - Maintain project intelligence
3. **Leverage multiple Claude instances** - Parallel processing
4. **Document as you go** - Update markdown files

### Performance Tips
1. **Keep containers running** - Don't rebuild unnecessarily
2. **Use volume mounts** - Persistent storage for packages/cache
3. **Monitor resources** - Check `docker stats` if slow

### Security Notes
1. **Container isolation** - Safe environment for experimentation
2. **Authentication mounting** - Host Claude auth is safely shared
3. **Network separation** - Services communicate via internal network

## 📚 Resources

- **Project Documentation**: http://localhost:8080/docs
- **Neo4j Browser**: http://localhost:7474
- **Claude Docker API**: http://localhost:8000
- **Main README**: /workspace/README.md
- **Configuration Reference**: /workspace/claude-configs/README.md

## 🎉 Success Indicators

Your dev container is working correctly when:
- ✅ `islamic-dev` shows welcome message
- ✅ `dev-status` shows all services running
- ✅ `test-knowledge` imports Graphiti successfully
- ✅ `claude2` starts interactive Claude session
- ✅ Neo4j browser accessible at localhost:7474
- ✅ All project commands (`gr`, `gs`, `gt`) work

**Happy developing! 🕌**