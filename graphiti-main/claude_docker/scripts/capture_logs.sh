#!/bin/bash
# Script to capture and preserve Claude Docker logs

LOG_DIR="/Users/farieds/Project/islamic-text-workflow/graphiti-main/claude_docker/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

echo "📝 Capturing Claude Docker logs..."

# 1. Capture API server logs
docker logs claude-docker-api --timestamps > "$LOG_DIR/api_server_${TIMESTAMP}.log" 2>&1
echo "✅ API logs saved to: $LOG_DIR/api_server_${TIMESTAMP}.log"

# 2. Capture container inspect for debugging
docker inspect claude-docker-api > "$LOG_DIR/api_inspect_${TIMESTAMP}.json"
echo "✅ Container info saved to: $LOG_DIR/api_inspect_${TIMESTAMP}.json"

# 3. Create a summary report
{
    echo "Claude Docker Log Summary - $TIMESTAMP"
    echo "======================================="
    echo ""
    echo "Container Status:"
    docker ps | grep claude-docker
    echo ""
    echo "Recent Requests (last 10):"
    docker logs claude-docker-api 2>&1 | grep "POST /v1/messages" | tail -10
    echo ""
    echo "Recent Errors:"
    docker logs claude-docker-api 2>&1 | grep -i error | tail -10
    echo ""
    echo "Worker Status:"
    docker logs claude-docker-api 2>&1 | grep "Started worker" | tail -5
} > "$LOG_DIR/summary_${TIMESTAMP}.txt"

echo "✅ Summary saved to: $LOG_DIR/summary_${TIMESTAMP}.txt"
echo ""
echo "📁 All logs saved in: $LOG_DIR"