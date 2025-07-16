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

# Helper function for seamless Graphiti setup
setup_graphiti() {
    echo "🧠 Setting up Graphiti for seamless integration..."
    pkg graphiti
    echo "✅ Graphiti dependencies installed"
    echo "💡 Use 'gr', 'gs', 'gt', 'gst' commands for knowledge graph operations"
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
echo "📦 Install packages as needed:"
echo "   pkg claude           - Install Claude Code"
echo "   pkg dev-tools        - Install vim, nano, etc."
echo "   pkg python-dev       - Install pytest, jupyter, etc."
echo "   pkg graphiti         - Install Graphiti dependencies"
echo "   pkg all              - Install everything"
echo ""
echo "🧠 Graphiti commands automatically loaded:"
echo "   gr 'text'            - Remember in knowledge graph"
echo "   gs 'query'           - Search knowledge graph"
echo "   gt 'file.txt'        - Analyze text files"
echo "   gst                  - Show system status"
echo ""
echo "🤖 Multi-Instance Claude support:"
echo "   claude               - Start Claude in this container"
echo "   new_claude           - Show multi-instance workflow"
echo ""
echo "🚀 Fast startup, install only what you need!"
echo ""