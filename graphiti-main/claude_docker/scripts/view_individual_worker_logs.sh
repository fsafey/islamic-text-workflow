#!/bin/bash
# View individual worker logs from the enhanced logging API

echo "🔍 Individual Worker Log Viewer"
echo "=============================="

# Check if API is running
if ! curl -s http://localhost:8000/health > /dev/null; then
    echo "❌ Claude Docker API is not running!"
    exit 1
fi

# Function to view logs for a specific worker
view_worker_logs() {
    local worker_id=$1
    local lines=${2:-50}
    
    echo -e "\n📋 Logs for $worker_id (last $lines lines):"
    echo "----------------------------------------"
    
    # Get logs via API endpoint
    curl -s "http://localhost:8000/logs/$worker_id?lines=$lines" | jq -r '.logs[]' 2>/dev/null || echo "No logs available"
}

# View logs for each worker
for i in 1 2 3; do
    view_worker_logs "worker-$i" 30
done

# Show real-time combined view
echo -e "\n📡 Real-time view (all workers combined):"
echo "Press Ctrl+C to stop"
echo "----------------------------------------"

# If logs are mounted, tail them directly
if [ -d "/Users/farieds/Project/islamic-text-workflow/graphiti-main/claude_docker/logs" ]; then
    tail -f /Users/farieds/Project/islamic-text-workflow/graphiti-main/claude_docker/logs/worker-*.log
else
    # Otherwise, poll the API
    while true; do
        for i in 1 2 3; do
            echo -e "\n[worker-$i]"
            curl -s "http://localhost:8000/logs/worker-$i?lines=5" | jq -r '.logs[]' 2>/dev/null
        done
        sleep 2
    done
fi