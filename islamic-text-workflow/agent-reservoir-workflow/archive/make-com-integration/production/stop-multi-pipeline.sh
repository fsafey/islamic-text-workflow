#!/bin/bash

# Stop Multi-Instance Claude Desktop MCP Pipeline

echo "🛑 Stopping MULTI-INSTANCE Claude Desktop MCP Pipeline..."
echo "========================================================"

# Read PIDs from file
if [ -f ".multi-pipeline-pids" ]; then
    PID_DATA=$(cat .multi-pipeline-pids)
    echo "📋 Found running services: $PID_DATA"
    
    # Parse and stop each PID
    for pid_info in $PID_DATA; do
        if [[ $pid_info == *":"* ]]; then
            # Bridge instance (PID:PORT format)
            IFS=':' read -r pid port <<< "$pid_info"
            echo "   Stopping bridge instance on port $port (PID: $pid)..."
            kill $pid 2>/dev/null || true
            rm -f "claude-desktop-agent-$(($port - 3002)).js" 2>/dev/null || true
        else
            # ngrok or other service
            echo "   Stopping service (PID: $pid_info)..."
            kill $pid_info 2>/dev/null || true
        fi
    done
    
    rm -f .multi-pipeline-pids
    echo "✅ All services stopped"
else
    echo "⚠️  No PID file found. Attempting to stop known processes..."
    
    # Cleanup any remaining processes
    pkill -f "claude-desktop-agent" 2>/dev/null || true
    pkill -f "ngrok" 2>/dev/null || true
    
    # Cleanup temp files
    rm -f claude-desktop-agent-*.js 2>/dev/null || true
    
    echo "✅ Cleanup complete"
fi

echo ""
echo "📊 MULTI-INSTANCE Pipeline Status: STOPPED"
echo "🚀 To restart, run: ./start-multi-daemon.sh"