#!/bin/bash
# On-demand package installer for Islamic Text Workflow Dev Container

install_claude() {
    echo "🤖 Installing Claude Code..."
    # First ensure Node.js is installed
    if ! command -v node &> /dev/null; then
        echo "Installing Node.js first..."
        install_nodejs
    fi
    # Install Claude Code via npm (official method with sudo)
    sudo npm install -g @anthropic-ai/claude-code
    echo "✅ Claude Code installed"
}

install_dev_tools() {
    echo "🔧 Installing development tools..."
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
        vim nano jq tree htop ncdu ripgrep fd-find bat
    echo "✅ Development tools installed"
}

install_docker() {
    echo "🐳 Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
        docker.io docker-compose
    sudo usermod -aG docker developer
    echo "✅ Docker installed"
}

install_build_tools() {
    echo "🔨 Installing build tools..."
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
        build-essential pkg-config libssl-dev libffi-dev
    echo "✅ Build tools installed"
}

install_python_dev() {
    echo "🐍 Installing Python development tools..."
    pip install --user --no-cache-dir \
        uv black flake8 pylint pytest jupyter ipython
    echo "✅ Python dev tools installed"
}

install_graphiti() {
    echo "📊 Installing Graphiti dependencies..."
    pip install --user --no-cache-dir \
        requests aiohttp fastapi uvicorn pydantic neo4j anthropic openai
    echo "✅ Graphiti dependencies installed"
}

install_nodejs() {
    echo "📦 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash -
    sudo apt-get install -y nodejs
    echo "✅ Node.js installed"
}

# Helper function to show available packages
show_packages() {
    echo "Available packages:"
    echo "  claude        - Claude Code CLI"
    echo "  dev-tools     - vim, nano, jq, tree, htop, etc."
    echo "  docker        - Docker and docker-compose"
    echo "  build-tools   - build-essential, pkg-config, etc."
    echo "  python-dev    - black, flake8, pytest, jupyter, etc."
    echo "  graphiti      - Graphiti framework dependencies"
    echo "  nodejs        - Node.js runtime"
    echo ""
    echo "Usage: install-packages.sh <package-name>"
    echo "Example: install-packages.sh claude"
}

# Main execution
case "${1:-}" in
    claude)
        install_claude
        ;;
    dev-tools)
        install_dev_tools
        ;;
    docker)
        install_docker
        ;;
    build-tools)
        install_build_tools
        ;;
    python-dev)
        install_python_dev
        ;;
    graphiti)
        install_graphiti
        ;;
    nodejs)
        install_nodejs
        ;;
    all)
        install_claude
        install_dev_tools
        install_docker
        install_build_tools
        install_python_dev
        install_graphiti
        install_nodejs
        ;;
    *)
        show_packages
        ;;
esac