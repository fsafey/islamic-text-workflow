#!/bin/bash
# ABOUTME: Installation script for Islamic Text Processing Claude Docker system
# ABOUTME: Based on claude-docker-model patterns for reliable setup

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🕌 Installing Islamic Text Processing Claude Docker system..."

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check Claude authentication
if [ ! -f "$HOME/.claude.json" ]; then
    echo "❌ Claude authentication not found. Please run 'claude auth' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Create persistent directories
echo "📁 Creating persistent directories..."
mkdir -p "$HOME/.claude-docker/claude-home"
mkdir -p "$HOME/.claude-docker/ssh"

# Copy template configuration
echo "📋 Setting up Claude configuration templates..."
if [ ! -f "$HOME/.claude-docker/claude-home/CLAUDE.md" ]; then
    cp "$PROJECT_ROOT/.claude/CLAUDE.md" "$HOME/.claude-docker/claude-home/"
    echo "✅ Copied Islamic text processing CLAUDE.md template"
fi

# Copy Claude authentication
if [ -f "$HOME/.claude/.credentials.json" ] && [ ! -f "$HOME/.claude-docker/claude-home/.credentials.json" ]; then
    cp "$HOME/.claude/.credentials.json" "$HOME/.claude-docker/claude-home/.credentials.json"
    echo "✅ Copied Claude credentials to persistent directory"
fi

# Make scripts executable
chmod +x "$SCRIPT_DIR/claude-docker.sh"
chmod +x "$SCRIPT_DIR/startup.sh"
chmod +x "$PROJECT_ROOT/install-mcp-servers.sh"

# Create symlink for easy access
SYMLINK_PATH="/usr/local/bin/islamic-text-claude"
if [ ! -L "$SYMLINK_PATH" ]; then
    if command -v sudo &> /dev/null; then
        sudo ln -s "$SCRIPT_DIR/claude-docker.sh" "$SYMLINK_PATH"
        echo "✅ Created symlink: islamic-text-claude -> $SCRIPT_DIR/claude-docker.sh"
    else
        echo "⚠️  Could not create symlink (no sudo). Use full path: $SCRIPT_DIR/claude-docker.sh"
    fi
fi

# Check environment file
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "⚠️  No .env file found. Please create one with your Supabase credentials:"
    echo "     SUPABASE_URL=your_supabase_url"
    echo "     SUPABASE_SERVICE_KEY=your_service_key"
    echo "     TWILIO_ACCOUNT_SID=your_twilio_sid (optional)"
    echo "     TWILIO_AUTH_TOKEN=your_twilio_token (optional)"
    echo "     GITHUB_TOKEN=your_github_token (optional)"
fi

# SSH key setup instructions
SSH_KEY_PATH="$HOME/.claude-docker/ssh/id_rsa"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo ""
    echo "🔑 SSH Key Setup (Optional - for git operations):"
    echo "   1. Generate SSH key: ssh-keygen -t rsa -b 4096 -f ~/.claude-docker/ssh/id_rsa -N ''"
    echo "   2. Add to GitHub: cat ~/.claude-docker/ssh/id_rsa.pub"
    echo "   3. Test: ssh -T git@github.com -i ~/.claude-docker/ssh/id_rsa"
    echo ""
fi

echo "🎉 Islamic Text Processing Claude Docker system installed successfully!"
echo ""
echo "📚 Usage Examples:"
echo "   islamic-text-claude --agent flowchart_mapper    # Start flowchart analysis agent"
echo "   islamic-text-claude --agent metadata_hunter     # Start metadata research agent"
echo "   islamic-text-claude --agent orchestrator        # Start workflow orchestrator"
echo "   islamic-text-claude --agent dashboard           # Start monitoring dashboard"
echo ""
echo "🔧 Full workflow:"
echo "   cd your-islamic-text-project"
echo "   islamic-text-claude --agent orchestrator        # Terminal 1"
echo "   islamic-text-claude --agent dashboard           # Terminal 2"
echo ""
echo "📖 Documentation: $PROJECT_ROOT/README.md"