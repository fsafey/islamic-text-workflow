#!/bin/bash

# Claude Coordination Monitor Script

echo "🔗 Claude Coordination System Monitor"
echo "======================================"

# Get script directory to work from project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$PROJECT_ROOT"

# Check system status
echo "📊 System Status:"
if [ -f "infrastructure/coordination/status/coordination-status.json" ]; then
    echo "✅ Coordination system active"
else
    echo "❌ Coordination system not found"
    exit 1
fi

echo ""

# Check pending tasks
echo "📥 Pending Tasks:"
TASK_COUNT=$(ls infrastructure/coordination/inbox/ 2>/dev/null | wc -l)
if [ $TASK_COUNT -gt 0 ]; then
    echo "📝 $TASK_COUNT task(s) pending:"
    ls infrastructure/coordination/inbox/
else
    echo "✅ No pending tasks"
fi

echo ""

# Check Docker instance status
echo "🐳 Docker Instance Status:"
if [ -f "infrastructure/coordination/status/docker-progress.txt" ]; then
    echo "📄 Latest Status:"
    cat infrastructure/coordination/status/docker-progress.txt
else
    echo "⏳ Docker instance not yet connected"
fi

echo ""

# Check completed results
echo "📤 Available Results:"
RESULT_COUNT=$(ls infrastructure/coordination/outbox/ 2>/dev/null | wc -l)
if [ $RESULT_COUNT -gt 0 ]; then
    echo "✅ $RESULT_COUNT result(s) available:"
    ls infrastructure/coordination/outbox/
else
    echo "⏳ No results yet"
fi

echo ""

# Show recent activity
echo "📋 Recent Activity:"
if [ -f "infrastructure/coordination/logs/coordination-system.log" ]; then
    tail -5 infrastructure/coordination/logs/coordination-system.log
else
    echo "No activity logged yet"
fi

echo ""
echo "🔄 Use 'watch ./infrastructure/coordination/monitor.sh' for live monitoring"