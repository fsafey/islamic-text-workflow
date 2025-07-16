#!/bin/bash
# Interactive Claude Docker Instance Launcher
# Creates a second Claude CLI instance you can work in directly

set -e

PROJECT_ROOT="/Users/farieds/Project/islamic-text-workflow"

# Default to interactive mode - clean startup like primary Claude
echo "🚀 Starting Interactive Claude Docker Instance"
echo "📁 Project: $PROJECT_ROOT"

# Check if Claude Docker is authenticated
if ! docker run --rm \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    claude-docker:latest claude --version >/dev/null 2>&1; then
    echo "❌ Claude Docker not authenticated. Please run:"
    echo "   docker run -it --rm -v ~/.claude-docker/claude-home:/home/claude-user/.claude -v ~/.claude-docker/ssh:/home/claude-user/.ssh claude-docker:latest claude auth browser"
    exit 1
fi

# Mount interactive configuration
CLAUDE_CONFIG_DIR="$PROJECT_ROOT/claude-configs/interactive"
if [[ ! -f "$CLAUDE_CONFIG_DIR/CLAUDE.md" ]]; then
    CLAUDE_CONFIG_DIR="$PROJECT_ROOT/claude-configs/base"
fi

# Start Claude directly - no conversation options
docker run -it --rm \
    --name claude-interactive-$(date +%s) \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    -v "$PROJECT_ROOT:$PROJECT_ROOT:rw" \
    -v "$CLAUDE_CONFIG_DIR/CLAUDE.md:/home/claude-user/.claude/CLAUDE.md:ro" \
    -w "$PROJECT_ROOT" \
    claude-docker:latest \
    claude --dangerously-skip-permissions

echo ""
echo "👋 Claude Docker session ended."
echo "💡 Run this script again anytime to start a new session!"