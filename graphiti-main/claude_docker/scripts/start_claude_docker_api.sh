#!/bin/bash
# Start Claude Docker API for Graphiti integration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🚀 Starting Claude Docker API for Graphiti..."
echo "📍 Project root: $PROJECT_ROOT"

# Check if Claude Docker is authenticated
if ! docker run --rm \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    claude-docker:latest claude --version >/dev/null 2>&1; then
    echo "❌ Claude Docker not authenticated. Please run:"
    echo "   docker run -it --rm -v ~/.claude-docker/claude-home:/home/claude-user/.claude -v ~/.claude-docker/ssh:/home/claude-user/.ssh claude-docker:latest claude auth browser"
    exit 1
fi

# Check for required environment variables
if [ -z "$GOOGLE_API_KEY" ]; then
    echo "⚠️  Warning: GOOGLE_API_KEY not set. Loading from .env if available..."
    if [ -f "$PROJECT_ROOT/.env" ]; then
        export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
    fi
fi

# Start services with docker-compose
echo "🐳 Starting Docker services..."
docker-compose -f "$PROJECT_ROOT/claude_docker/docker/docker-compose.yml" up -d

# Wait for API to be ready
echo "⏳ Waiting for API to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:8000/health >/dev/null 2>&1; then
        echo "✅ Claude Docker API is ready!"
        echo "📡 API available at: http://localhost:8000"
        echo "📊 Neo4j available at: http://localhost:7474"
        echo ""
        echo "To test the API:"
        echo "  curl http://localhost:8000/"
        echo ""
        echo "To run examples:"
        echo "  python claude_docker/examples/quickstart_claude_docker_islamic.py"
        echo ""
        echo "To stop services:"
        echo "  docker-compose -f $PROJECT_ROOT/claude_docker/docker/docker-compose.yml down"
        exit 0
    fi
    sleep 1
done

echo "❌ API failed to start. Check logs with:"
echo "  docker-compose -f claude_docker/docker/docker-compose.yml logs"
exit 1