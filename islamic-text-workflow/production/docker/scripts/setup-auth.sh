#!/bin/bash
# Authentication setup script for Islamic Text Processing Docker containers
# Based on claude-docker-model authentication patterns

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔐 Setting up Claude authentication for Islamic Text Processing system..."

# Create persistent directories
echo "📁 Creating persistent Claude directories..."
mkdir -p "$HOME/.claude-docker/claude-home"
mkdir -p "$HOME/.claude-docker/ssh"

# Check if Claude authentication exists
if [ ! -f "$HOME/.claude.json" ]; then
    echo "❌ Claude authentication not found at $HOME/.claude.json"
    echo "   Please run 'claude auth' first to authenticate Claude Code"
    exit 1
fi

echo "✅ Found Claude authentication file"

# Copy authentication file to build context (temporary)
echo "📋 Copying authentication file to build context..."
cp "$HOME/.claude.json" "$PROJECT_ROOT/.claude.json"

# Copy authentication to persistent directory if needed
if [ ! -f "$HOME/.claude-docker/claude-home/.credentials.json" ] && [ -f "$HOME/.claude/.credentials.json" ]; then
    echo "📋 Copying Claude credentials to persistent directory..."
    cp "$HOME/.claude/.credentials.json" "$HOME/.claude-docker/claude-home/.credentials.json"
fi

# Create SSH config if needed
SSH_KEY_PATH="$HOME/.claude-docker/ssh/id_rsa"
SSH_PUB_KEY_PATH="$HOME/.claude-docker/ssh/id_rsa.pub"

if [ ! -f "$SSH_KEY_PATH" ] || [ ! -f "$SSH_PUB_KEY_PATH" ]; then
    echo "⚠️  SSH keys not found for git operations"
    echo "   To enable git push/pull operations:"
    echo "   1. ssh-keygen -t rsa -b 4096 -f ~/.claude-docker/ssh/id_rsa -N ''"
    echo "   2. Add public key to GitHub"
    echo "   3. Test with: ssh -T git@github.com -i ~/.claude-docker/ssh/id_rsa"
    echo ""
    echo "   System will continue without SSH keys (read-only git operations only)"
else
    echo "✅ SSH keys found for git operations"
    
    # Create SSH config
    SSH_CONFIG_PATH="$HOME/.claude-docker/ssh/config"
    if [ ! -f "$SSH_CONFIG_PATH" ]; then
        cat > "$SSH_CONFIG_PATH" << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
EOF
        echo "✅ SSH config created for GitHub"
    fi
fi

echo "🎯 Authentication setup complete!"
echo "📁 Persistent directories:"
echo "   - Claude home: ~/.claude-docker/claude-home/"
echo "   - SSH keys: ~/.claude-docker/ssh/"
echo ""
echo "🚀 Ready to build Docker containers with proper authentication"