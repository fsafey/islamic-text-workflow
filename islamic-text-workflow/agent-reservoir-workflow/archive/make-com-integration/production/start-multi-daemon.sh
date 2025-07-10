#!/bin/bash

# Islamic Text Processing Pipeline - Multi-Instance Parallel Deployment
# Starts multiple bridge instances on different ports for parallel processing

set -e

echo "🚀 Starting MULTI-INSTANCE Claude Desktop MCP Pipeline..."
echo "==========================================================="

# Configuration
NUM_INSTANCES=3
BASE_PORT=3002
INSTANCE_PIDS=()

# Stop any existing services
./stop-pipeline.sh 2>/dev/null || true

# Function to start a bridge instance
start_bridge_instance() {
    local instance_id=$1
    local port=$((BASE_PORT + instance_id))
    
    echo "🌉 Starting bridge instance $instance_id on port $port..."
    
    # Create instance-specific config
    sed "s/3002/$port/g" claude-desktop-agent.js > "claude-desktop-agent-$instance_id.js"
    
    # Start bridge instance
    nohup node "claude-desktop-agent-$instance_id.js" > "/tmp/claude-bridge-$instance_id.log" 2>&1 &
    local bridge_pid=$!
    
    # Wait and verify
    sleep 3
    if curl -s "http://localhost:$port/health" > /dev/null 2>&1; then
        echo "✅ Bridge instance $instance_id started (PID: $bridge_pid, Port: $port)"
        INSTANCE_PIDS+=("$bridge_pid:$port")
        return 0
    else
        echo "❌ Bridge instance $instance_id failed to start"
        kill $bridge_pid 2>/dev/null || true
        return 1
    fi
}

# Start multiple bridge instances
for i in $(seq 0 $((NUM_INSTANCES - 1))); do
    start_bridge_instance $i
done

# Start load balancer ngrok (points to first instance by default)
echo "🌐 Starting ngrok tunnel (load balancer)..."
nohup ngrok http $BASE_PORT > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!

sleep 5
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "")

if [ -n "$NGROK_URL" ] && [ "$NGROK_URL" != "null" ]; then
    echo "✅ ngrok tunnel started (PID: $NGROK_PID)"
    echo "🔗 Public URL: $NGROK_URL"
else
    echo "⚠️  ngrok tunnel may still be starting..."
fi

# Save all PIDs
echo "${INSTANCE_PIDS[@]} $NGROK_PID" > .multi-pipeline-pids

echo ""
echo "✅ MULTI-INSTANCE Pipeline started successfully!"
echo "📊 Active Instances:"
for pid_port in "${INSTANCE_PIDS[@]}"; do
    IFS=':' read -r pid port <<< "$pid_port"
    echo "   - Instance: http://localhost:$port (PID: $pid)"
done
echo "   - ngrok: $NGROK_URL (PID: $NGROK_PID)"
echo ""
echo "📋 Parallel Processing:"
echo "   - Send requests to different ports for parallel processing"
echo "   - Load balance via ngrok URL or direct port access"
echo "   - Monitor: tail -f /tmp/claude-bridge-*.log"
echo ""
echo "🛑 To stop: ./stop-multi-pipeline.sh"