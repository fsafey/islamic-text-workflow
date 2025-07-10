#!/bin/bash

# Islamic Text Processing Pipeline - REAL Implementation Startup Script
# This script starts Claude Desktop MCP integration services

set -e

echo "🚀 Starting REAL Claude Desktop MCP Pipeline..."
echo "==============================================="

# Check if required files exist
if [ ! -f "config.js" ]; then
    echo "❌ Error: config.js not found in production directory"
    exit 1
fi

if [ ! -f "claude-desktop-agent.js" ]; then
    echo "❌ Error: claude-desktop-agent.js not found in production directory"
    exit 1
fi

# Check if Claude Code CLI is installed
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude Code CLI is not installed. Please install Claude Code first."
    exit 1
fi

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "❌ Error: ngrok is not installed. Please install ngrok first."
    exit 1
fi

echo "✅ All dependencies found"
echo ""

# Start Claude Desktop bridge with real MCP integration
echo "🌉 Starting REAL Claude Desktop MCP bridge..."
nohup node claude-desktop-agent.js > /tmp/claude-bridge.log 2>&1 &
BRIDGE_PID=$!
echo "   Claude Desktop bridge started (PID: $BRIDGE_PID)"

# Wait for bridge to start and verify it's listening
sleep 3
if ! curl -s http://localhost:3002/health > /dev/null 2>&1; then
    echo "⚠️  Bridge not responding immediately, waiting longer..."
    sleep 5
    if ! curl -s http://localhost:3002/health > /dev/null 2>&1; then
        echo "❌ Bridge failed to start properly. Check logs:"
        tail -20 /tmp/claude-bridge.log
        kill $BRIDGE_PID 2>/dev/null || true
        exit 1
    fi
fi
echo "✅ Bridge is responding on port 3002"

# Start ngrok tunnel
echo "🌐 Starting ngrok tunnel..."
nohup ngrok http 3002 > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!
echo "   ngrok tunnel started (PID: $NGROK_PID)"

# Wait for ngrok to establish tunnel
sleep 8

# Get ngrok public URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")

if [ -n "$NGROK_URL" ] && [ "$NGROK_URL" != "null" ]; then
    echo "✅ REAL Claude Desktop MCP Pipeline started successfully!"
    echo ""
    echo "📊 Service Status:"
    echo "   - Claude Desktop bridge: http://localhost:3002 (PID: $BRIDGE_PID)"
    echo "   - ngrok tunnel: $NGROK_URL (PID: $NGROK_PID)"
    echo ""
    echo "🔗 Public Endpoints (REAL Implementation):"
    echo "   - Health check: $NGROK_URL/health"
    echo "   - REAL Hybrid Analysis: $NGROK_URL/claude/hybrid-analysis"
    echo "   - REAL Enrichment Execution: $NGROK_URL/claude/enrichment-execution"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Update Make.com scenario URLs: node update-webhook-url.js"
    echo "   2. Test REAL analysis with Islamic text"
    echo "   3. Monitor actual WebSearch and database operations"
    echo ""
    echo "🛑 To stop the pipeline, run: ./stop-pipeline.sh"
else
    echo "❌ Error: Could not obtain ngrok public URL"
    echo "🧹 Cleaning up..."
    kill $BRIDGE_PID $NGROK_PID 2>/dev/null || true
    exit 1
fi

# Save PIDs for stop script
echo "$BRIDGE_PID $NGROK_PID" > .pipeline-pids

# Keep script running
echo "⏳ REAL Pipeline running... Press Ctrl+C to stop"
trap 'kill $BRIDGE_PID $NGROK_PID 2>/dev/null || true; rm -f .pipeline-pids; echo "🛑 REAL Pipeline stopped"; exit 0' INT

wait