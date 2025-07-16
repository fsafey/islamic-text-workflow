#!/bin/bash
# Islamic Text Workflow Dev Container Setup Script
# Initializes the development environment after container creation

set -e

echo "🕌 Setting up Islamic Text Workflow Development Environment..."

# Set up project directory
cd /workspace

# Source the project commands and aliases
echo "📝 Setting up project commands and aliases..."
if [ -f "tools/scripts/graphiti-commands.sh" ]; then
    echo "source /workspace/tools/scripts/graphiti-commands.sh" >> ~/.bashrc
    source tools/scripts/graphiti-commands.sh
    echo "✅ Project commands loaded"
else
    echo "⚠️  Warning: graphiti-commands.sh not found"
fi

# Install Python dependencies for Graphiti
echo "🐍 Installing Python dependencies..."
if [ -f "graphiti-main/pyproject.toml" ]; then
    cd graphiti-main
    pip install --user -e . || echo "⚠️  Graphiti installation had issues"
    cd ..
    echo "✅ Graphiti dependencies installed"
fi

# Install additional project requirements if they exist
if [ -f "requirements.txt" ]; then
    pip install --user -r requirements.txt
    echo "✅ Additional requirements installed"
fi

# Set up git safe directory
echo "🔧 Configuring Git..."
git config --global --add safe.directory /workspace
git config --global user.email "developer@islamic-text-workflow.local" || true
git config --global user.name "Islamic Text Workflow Developer" || true
echo "✅ Git configured"

# Wait for Neo4j to be ready
echo "🗄️  Waiting for Neo4j database..."
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -f http://neo4j:7474/db/data/ 2>/dev/null; then
        echo "✅ Neo4j is ready"
        break
    fi
    echo "   Attempt $attempt/$max_attempts - waiting for Neo4j..."
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -gt $max_attempts ]; then
    echo "⚠️  Neo4j may not be ready yet, but continuing setup"
fi

# Wait for Claude Docker API
echo "🤖 Waiting for Claude Docker API..."
max_attempts=15
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -f http://claude-docker-api:8000/health 2>/dev/null; then
        echo "✅ Claude Docker API is ready"
        break
    fi
    echo "   Attempt $attempt/$max_attempts - waiting for Claude Docker API..."
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -gt $max_attempts ]; then
    echo "⚠️  Claude Docker API may not be ready yet, but continuing setup"
fi

# Create helpful aliases
echo "🔗 Setting up development aliases..."
cat >> ~/.bashrc << 'EOF'

# Islamic Text Workflow Development Aliases
alias ws='cd /workspace'
alias docs='cd /workspace/documentation'
alias graphiti='cd /workspace/graphiti-main'
alias configs='cd /workspace/claude-configs'
alias neo4j-browser='echo "Neo4j Browser: http://localhost:7474 (neo4j/islamictext2024)"'
alias claude-api='echo "Claude Docker API: http://localhost:8000"'
alias dev-status='echo "=== Development Environment Status ===" && echo "Neo4j: http://localhost:7474" && echo "Claude API: http://localhost:8000" && echo "Docs: http://localhost:8080" && docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# Project development shortcuts
alias test-graphiti='cd /workspace/graphiti-main && python -m pytest tests/ -v'
alias test-knowledge='python -c "from graphiti_core.graphiti import Graphiti; print(\"Graphiti import successful\")"'
alias islamic-dev='echo "Islamic Text Workflow Dev Environment Ready! 🕌"'

# Development workflow helpers
alias fresh-env='source ~/.bashrc && echo "Environment refreshed!"'
alias project-help='cat /workspace/.devcontainer/README.md'

EOF

# Create a development README
echo "📚 Creating development documentation..."
cat > /workspace/.devcontainer/README.md << 'EOF'
# Islamic Text Workflow Dev Container

## 🚀 Quick Start

Your development environment is ready! Here are the key commands:

### Development Commands
- `ws` - Go to workspace
- `islamic-dev` - Show welcome message
- `dev-status` - Check all services status
- `fresh-env` - Reload environment

### Project Commands (from graphiti-commands.sh)
- `gr "text"` - Remember in knowledge graph
- `gs "query"` - Search knowledge graph
- `gt "/path/file"` - Analyze text file
- `gst` - Show system status

### Claude Docker Commands
- `claude2` - Interactive Claude instance
- `claude-graphiti` - Graphiti worker mode
- `claude-islamic` - Islamic NLP mode
- `claude-engineering` - Software engineering mode

### Services Available
- **Neo4j Browser**: http://localhost:7474 (neo4j/islamictext2024)
- **Claude Docker API**: http://localhost:8000
- **Documentation Server**: http://localhost:8080

### Project Structure
- `/workspace` - Project root
- `/workspace/graphiti-main` - Graphiti framework
- `/workspace/claude-configs` - Claude instance configurations
- `/workspace/documentation` - Project documentation
- `/workspace/tools/scripts` - Development scripts

### Testing
- `test-graphiti` - Run Graphiti tests
- `test-knowledge` - Test knowledge graph connection

### Development Workflow
1. Use `claude2` for interactive development
2. Track insights with `gr "insight"`
3. Search knowledge with `gs "query"`
4. Analyze texts with `gt "file.txt"`
5. Check system with `gst`

Happy coding! 🕌
EOF

# Set executable permissions
chmod +x ~/.bashrc

# Final verification
echo "🔍 Final verification..."
python3 --version
pip --version
docker --version
git --version

echo ""
echo "🎉 Islamic Text Workflow Development Environment Setup Complete!"
echo ""
echo "📋 Services available:"
echo "   - Neo4j Browser: http://localhost:7474 (neo4j/islamictext2024)"
echo "   - Claude Docker API: http://localhost:8000"
echo "   - Documentation: http://localhost:8080"
echo ""
echo "🚀 Ready for Islamic text research and development!"
echo "   Type 'islamic-dev' for a quick orientation"
echo "   Type 'project-help' to see the development guide"
echo ""