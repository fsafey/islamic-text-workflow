#!/bin/bash

# Islamic Text Processing Pipeline - REAL Implementation Stop Script
# This script stops Claude Desktop MCP integration services

echo "🛑 Stopping REAL Claude Desktop MCP Pipeline..."
echo "==============================================="

# Check if PID file exists
if [ -f ".pipeline-pids" ]; then
    PIDS=$(cat .pipeline-pids)
    echo "📋 Found running services (PIDs: $PIDS)"
    
    # Kill all processes
    for pid in $PIDS; do
        if kill -0 $pid 2>/dev/null; then
            echo "   Stopping process $pid..."
            kill $pid 2>/dev/null || true
        fi
    done
    
    # Remove PID file
    rm -f .pipeline-pids
    echo "✅ All services stopped"
else
    echo "⚠️  No PID file found. Attempting to stop known processes..."
    
    # Stop processes by name
    pkill -f "claude-desktop-agent.js" || true
    pkill -f "ngrok http 3002" || true
    
    echo "✅ Cleanup complete"
fi

echo ""
echo "📊 REAL Pipeline Status: STOPPED"
echo "🚀 To restart the REAL pipeline, run: ./start-pipeline.sh"