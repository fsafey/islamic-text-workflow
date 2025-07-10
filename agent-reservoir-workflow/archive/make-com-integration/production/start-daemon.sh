#!/bin/bash

# Islamic Text Processing Pipeline - Daemon Mode Startup
# This script starts services in the background and exits

set -e

echo "🚀 Starting REAL Claude Desktop MCP Pipeline (Daemon Mode)..."
echo "============================================================="

# Check dependencies
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude Code CLI is not installed"
    exit 1
fi

if ! command -v ngrok &> /dev/null; then
    echo "❌ Error: ngrok is not installed"
    exit 1
fi

# Stop any existing services
./stop-pipeline.sh 2>/dev/null || true

# Start Claude Desktop bridge
echo "🌉 Starting Claude Desktop bridge..."
nohup node claude-desktop-agent.js > /tmp/claude-bridge.log 2>&1 &
BRIDGE_PID=$!

# Wait and verify bridge
sleep 3
if curl -s http://localhost:3002/health > /dev/null 2>&1; then
    echo "✅ Bridge started successfully (PID: $BRIDGE_PID)"
else
    echo "❌ Bridge failed to start. Check /tmp/claude-bridge.log"
    kill $BRIDGE_PID 2>/dev/null || true
    exit 1
fi

# Start ngrok tunnel
echo "🌐 Starting ngrok tunnel..."
nohup ngrok http 3002 > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!

# Wait for ngrok
sleep 5
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")

if [ -n "$NGROK_URL" ] && [ "$NGROK_URL" != "null" ]; then
    echo "✅ ngrok tunnel started (PID: $NGROK_PID)"
    echo "🔗 Public URL: $NGROK_URL"
else
    echo "⚠️  ngrok tunnel may still be starting..."
fi

# Save PIDs
echo "$BRIDGE_PID $NGROK_PID" > .pipeline-pids

echo ""
echo "✅ REAL Pipeline started in daemon mode"
echo "📊 Service Status:"
echo "   - Bridge: http://localhost:3002 (PID: $BRIDGE_PID)"
echo "   - ngrok: $NGROK_URL (PID: $NGROK_PID)"
echo ""
echo "📋 Next Steps:"
echo "   1. Update webhook URLs: node update-webhook-url.js"
echo "   2. Test analysis: curl -X POST http://localhost:3002/claude/hybrid-analysis ..."
echo "   3. Check logs: tail -f /tmp/claude-bridge.log"
echo ""
echo "🛑 To stop: ./stop-pipeline.sh"