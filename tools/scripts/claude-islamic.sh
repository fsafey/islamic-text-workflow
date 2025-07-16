#!/bin/bash
# Claude Docker - Islamic NLP Mode
# Specialized for Arabic text, hadith, and Quranic analysis

set -e

PROJECT_ROOT="/Users/farieds/Project/islamic-text-workflow"

echo "📚 Starting Claude Docker - Islamic Text Analysis Mode"
echo "🕌 Specialized for Arabic text, hadith, and Quranic analysis"
echo "📁 Project: $PROJECT_ROOT"

# Check authentication
if ! docker run --rm \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    claude-docker:latest claude --version >/dev/null 2>&1; then
    echo "❌ Claude Docker not authenticated"
    exit 1
fi

# Mount Islamic NLP configuration
CLAUDE_CONFIG_DIR="$PROJECT_ROOT/claude-configs/islamic-nlp"
if [[ ! -f "$CLAUDE_CONFIG_DIR/CLAUDE.md" ]]; then
    CLAUDE_CONFIG_DIR="$PROJECT_ROOT/claude-configs/base"
fi

docker run -it --rm \
    --name claude-islamic-nlp-$(date +%s) \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    -v "$PROJECT_ROOT:$PROJECT_ROOT:rw" \
    -v "$CLAUDE_CONFIG_DIR/CLAUDE.md:/home/claude-user/.claude/CLAUDE.md:ro" \
    -w "$PROJECT_ROOT" \
    --network="host" \
    claude-docker:latest \
    python graphiti-main/claude_docker/workers/claude_docker_worker_stdio.py --mode nlp_pipeline

echo ""
echo "👋 Islamic NLP session ended."