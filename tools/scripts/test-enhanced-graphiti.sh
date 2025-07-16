#!/bin/bash
# Test Enhanced Graphiti Commands Integration
# This script tests the enhanced commands to ensure they work properly

echo "🧪 Testing Enhanced Graphiti Commands Integration"
echo "=" * 50

# Source the enhanced commands
if [ -f "/workspace/tools/scripts/enhanced-graphiti-commands.sh" ]; then
    source "/workspace/tools/scripts/enhanced-graphiti-commands.sh"
    echo "✅ Enhanced commands loaded"
else
    echo "❌ Enhanced commands not found"
    exit 1
fi

echo ""
echo "🔍 Test 1: System Status Check"
echo "-" * 30
gst

echo ""
echo "🧠 Test 2: Knowledge Storage"
echo "-" * 30
echo "Testing knowledge storage with gr command..."
gr "TEST: Enhanced Graphiti integration test at $(date)"

echo ""
echo "🔍 Test 3: Search Functionality"
echo "-" * 30
echo "Testing search functionality with gs command..."
gs "TEST Enhanced Graphiti"

echo ""
echo "📄 Test 4: Text Analysis"
echo "-" * 30
echo "Testing text analysis with gt command..."
echo "This is a test document for enhanced Graphiti integration. It contains information about Docker containers, Claude Code integration, and knowledge graph functionality." > /tmp/test-document.txt
gt "/tmp/test-document.txt"

echo ""
echo "🚀 Test 5: Project Tracking"
echo "-" * 30
echo "Testing project tracking commands..."
pstart "enhanced-graphiti-test-session"
pdecision "Using enhanced Graphiti commands for knowledge management"
pfeature "enhanced-commands" "testing"

echo ""
echo "🔍 Test 6: Project Search"
echo "-" * 30
echo "Testing project search..."
psearch "enhanced-graphiti-test"

echo ""
echo "📊 Test 7: Project Overview"
echo "-" * 30
echo "Testing project overview..."
poverview

echo ""
echo "🧹 Cleanup"
echo "-" * 30
rm -f /tmp/test-document.txt
echo "✅ Temporary files cleaned up"

echo ""
echo "✅ Enhanced Graphiti Commands Integration Test Complete!"
echo ""
echo "📋 Test Results Summary:"
echo "  🔍 System Status: Check output above"
echo "  🧠 Knowledge Storage: Check if information was stored"
echo "  🔍 Search: Check if search returned relevant results"
echo "  📄 Text Analysis: Check if file was analyzed properly"
echo "  🚀 Project Tracking: Check if session/decision/feature were tracked"
echo "  📊 Project Search & Overview: Check if project data was found"
echo ""
echo "🎯 If all tests show proper integration with Neo4j and Claude Docker,"
echo "   the enhanced commands are working correctly!"
echo ""
echo "⚠️  If any tests fail, check:"
echo "  - Neo4j is running (docker run -d --name neo4j -p 7687:7687 -p 7474:7474 -e NEO4J_AUTH=neo4j/password neo4j:latest)"
echo "  - Claude Docker API is running (cd /workspace/graphiti-main/claude_docker && ./scripts/start_claude_docker_api.sh)"
echo "  - Google API key is set (export GOOGLE_API_KEY=your_key_here)"
echo "  - Graphiti dependencies are installed (cd /workspace/graphiti-main && pip install -e .)"