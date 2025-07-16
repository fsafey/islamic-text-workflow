#!/bin/bash
# Claude Docker - Graphiti Worker Mode
# JSON API processor for knowledge graph operations

set -e

PROJECT_ROOT="/Users/farieds/Project/islamic-text-workflow"

echo "🧠 Starting Claude Docker - Graphiti Worker Mode"
echo "📝 JSON API processor for knowledge graph operations"
echo "📁 Project: $PROJECT_ROOT"

# Check authentication
if ! docker run --rm \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    claude-docker:latest claude --version >/dev/null 2>&1; then
    echo "❌ Claude Docker not authenticated"
    exit 1
fi

# Mount Graphiti configuration
CLAUDE_CONFIG_DIR="$PROJECT_ROOT/claude-configs/graphiti-worker"
if [[ ! -f "$CLAUDE_CONFIG_DIR/CLAUDE.md" ]]; then
    CLAUDE_CONFIG_DIR="$PROJECT_ROOT/claude-configs/base"
fi

echo "💡 Send JSON like: {\"operation\":\"add_episode\",\"params\":{\"episode_body\":\"Your text here\"}}"
echo ""

docker run -it --rm \
    --name claude-graphiti-worker-$(date +%s) \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    -v "$PROJECT_ROOT:$PROJECT_ROOT:rw" \
    -v "$CLAUDE_CONFIG_DIR/CLAUDE.md:/home/claude-user/.claude/CLAUDE.md:ro" \
    -w "$PROJECT_ROOT" \
    --network="host" \
    claude-docker:latest \
    python graphiti-main/claude_docker/workers/claude_docker_worker_stdio.py --mode software_engineering

echo ""
echo "👋 Graphiti Worker session ended."