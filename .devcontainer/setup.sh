#!/bin/bash
# Minimal Islamic Text Workflow Dev Container Setup Script

set -e

echo "🕌 Minimal Islamic Text Workflow Setup..."

# Set up project directory
cd /workspace

# Basic git configuration
git config --global --add safe.directory /workspace
git config --global user.email "developer@islamic-text-workflow.local" || true
git config --global user.name "Islamic Text Workflow Developer" || true

# Create essential aliases and load Graphiti commands
cat >> ~/.bashrc << 'EOF'

# Essential aliases
alias ws='cd /workspace'
alias pkg='install-packages.sh'

# On-demand installation helpers
alias install-claude='install-packages.sh claude'
alias install-dev='install-packages.sh dev-tools'
alias install-all='install-packages.sh all'

# Auto-load Graphiti commands if available
if [ -f /workspace/tools/scripts/graphiti-commands.sh ]; then
    source /workspace/tools/scripts/graphiti-commands.sh
fi

# Auto-configure Graphiti with Neo4j
auto_setup_graphiti() {
    echo "🧠 Auto-configuring Graphiti with Neo4j..."
    
    # Wait for Neo4j to be ready
    echo "⏳ Waiting for Neo4j to be ready..."
    timeout=60
    while [ $timeout -gt 0 ] && ! nc -z neo4j 7687; do
        sleep 2
        timeout=$((timeout - 2))
    done
    
    if [ $timeout -le 0 ]; then
        echo "⚠️  Neo4j not ready after 60s, but continuing..."
    else
        echo "✅ Neo4j is ready"
    fi
    
    # Create .env file with Neo4j connection
    cat > /workspace/.env << 'ENVEOF'
NEO4J_URI=bolt://neo4j:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=password
OPENAI_API_KEY=not-needed-for-local-claude
GRAPHITI_DATA_DIR=/workspace/graphiti-data
ENVEOF
    
    # Create graphiti data directory
    mkdir -p /workspace/graphiti-data
    
    echo "✅ Graphiti configured for Neo4j"
}

# Run auto-setup in background
auto_setup_graphiti &

# Helper function for manual Graphiti setup (now mostly automatic)
setup_graphiti() {
    echo "🧠 Graphiti is automatically configured!"
    echo "✅ Dependencies: Already installed in container"
    echo "✅ Neo4j connection: Auto-configured"
    echo "✅ Commands loaded: gr, gs, gt, gst available"
    echo "💡 Use 'gst' to check system status"
}

# Helper function for multi-instance Claude workflow
new_claude() {
    echo "🤖 Multi-Instance Claude Workflow:"
    echo ""
    echo "OPTION 1: Multiple Dev Containers (Recommended)"
    echo "  1. Open VS Code → Command Palette → 'Reopen in Container'"
    echo "  2. In each container, run: claude"
    echo "  3. Each container gets its own Claude instance"
    echo "  4. All share the same /workspace directory"
    echo ""
    echo "OPTION 2: Docker Compose"
    echo "  docker-compose -f .devcontainer/docker-compose.yml up -d --scale app=3"
    echo "  docker exec -it islamic-text-workflow-app-1 claude"
    echo "  docker exec -it islamic-text-workflow-app-2 claude"
    echo "  docker exec -it islamic-text-workflow-app-3 claude"
    echo ""
    echo "💡 All instances share knowledge graph and workspace files"
}

EOF

# Quick start message
echo ""
echo "🎉 Minimal Dev Container Ready!"
echo ""
echo "📦 Optional packages (install as needed):"
echo "   pkg dev-tools        - Install vim, nano, etc."
echo "   pkg python-dev       - Install pytest, jupyter, etc."
echo "   pkg all              - Install everything"
echo ""
echo "🧠 Graphiti & Neo4j Knowledge Graph (READY):"
echo "   gr 'text'            - Remember in knowledge graph"
echo "   gs 'query'           - Search knowledge graph"
echo "   gt 'file.txt'        - Analyze text files"
echo "   gst                  - Show system status"
echo "   Neo4j UI: http://localhost:7474 (neo4j/password)"
echo "   ✅ Auto-configured with Neo4j backend"
echo ""
echo "🤖 Claude Code (READY):"
echo "   claude               - Start Claude Code (built-in)"
echo "   new_claude           - Show multi-instance workflow"
echo ""
echo "🚀 Fast startup, install only what you need!"
echo ""