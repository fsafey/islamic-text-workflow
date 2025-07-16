#!/bin/bash
# Script to view Claude Docker worker logs and debug output

echo "🔍 Viewing Claude Docker Worker Logs"
echo "===================================="

# 1. Check running containers
echo -e "\n📦 Running containers:"
docker ps | grep claude-docker

# 2. View API server logs with timestamps
echo -e "\n📝 API Server Logs (last 100 lines):"
docker logs claude-docker-api --timestamps --tail 100

# 3. Check for any error patterns
echo -e "\n❌ Recent errors:"
docker logs claude-docker-api 2>&1 | grep -E "ERROR|error|Error|failed|Failed" | tail -20

# 4. Monitor live logs
echo -e "\n📡 Live logs (Ctrl+C to stop):"
echo "Showing: API requests, worker responses, and errors..."
docker logs claude-docker-api -f --tail 20