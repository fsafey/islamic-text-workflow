#!/bin/bash
# Graphiti Workflow Commands
# Auto-detects workspace location for dev container compatibility
# Source this file in your shell profile or it will be auto-loaded in dev containers

# Detect workspace directory dynamically
if [ -f "/workspace/CLAUDE.md" ]; then
    WORKSPACE_DIR="/workspace"
elif [ -f "$(pwd)/CLAUDE.md" ]; then
    WORKSPACE_DIR="$(pwd)"
elif [ -f "$(dirname "$0")/../../CLAUDE.md" ]; then
    WORKSPACE_DIR="$(realpath "$(dirname "$0")/../..")"
else
    echo "Warning: Could not detect workspace directory"
    WORKSPACE_DIR="/workspace"
fi

export WORKSPACE_DIR

# Quick memory storage
graph_remember() {
    if [ -z "$1" ]; then
        echo "Usage: graph_remember 'text to remember'"
        return 1
    fi
    echo "Storing in knowledge graph: $1"
    # This would integrate with your Claude Code session
    # For now, we'll create a simple file-based approach
    echo "$(date): $1" >> ~/.claude/graphiti_memory.txt
}

# Search knowledge graph
graph_search() {
    if [ -z "$1" ]; then
        echo "Usage: graph_search 'query'"
        return 1
    fi
    echo "Searching knowledge graph for: $1"
    # This would query through Claude Code
    grep -i "$1" ~/.claude/graphiti_memory.txt 2>/dev/null || echo "No results found"
}

# Quick Islamic text analysis
graph_analyze_text() {
    if [ -z "$1" ]; then
        echo "Usage: graph_analyze_text 'file.txt' or graph_analyze_text 'direct text'"
        return 1
    fi
    
    if [ -f "$1" ]; then
        echo "Analyzing file: $1"
        # File analysis
        cat "$1" | head -10
    else
        echo "Analyzing text: $1"
        # Direct text analysis
        echo "$1" > /tmp/graph_temp.txt
    fi
}

# Start Graphiti session
graph_start() {
    echo "Starting Graphiti knowledge graph session..."
    echo "Available commands:"
    echo "  graph_remember 'text'    - Store information"
    echo "  graph_search 'query'     - Search knowledge"  
    echo "  graph_analyze_text file  - Analyze Islamic text"
    echo "  graph_status            - Check graph status"
    echo "  graph_export            - Export knowledge"
}

# Check graph status
graph_status() {
    echo "Graphiti Status:"
    echo "- Config: ~/.claude/mcp_settings.json"
    echo "- Memory: ~/.claude/graphiti_memory.txt"
    echo "- Neo4j: bolt://localhost:7687"
    echo "- Claude Docker API: http://localhost:8000"
    
    # Check if Neo4j is running
    if nc -z localhost 7687 2>/dev/null; then
        echo "- Neo4j: ✓ Running"
    else
        echo "- Neo4j: ✗ Not running"
    fi
    
    # Check if Claude Docker API is running
    if nc -z localhost 8000 2>/dev/null; then
        echo "- Claude Docker API: ✓ Running"
    else
        echo "- Claude Docker API: ✗ Not running"
        echo "  Start with: cd ${WORKSPACE_DIR}/graphiti-main/claude_docker && ./scripts/start_claude_docker_api.sh"
    fi
}

# Export knowledge graph
graph_export() {
    echo "Exporting knowledge graph..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    if [ -f ~/.claude/graphiti_memory.txt ]; then
        cp ~/.claude/graphiti_memory.txt "${WORKSPACE_DIR}/research/output/knowledge_export_${timestamp}.txt"
        echo "Exported to research/output/"
        echo ""
        echo "📋 Session Summary Template:"
        echo "Create: research/output/${timestamp}-session-[descriptive-title].md"
        echo "Header: # ${timestamp} - [Session Title]"
    else
        echo "No memory file found"
    fi
}

# Create timestamped session summary
graph_create_session_summary() {
    if [ -z "$1" ]; then
        echo "Usage: graph_create_session_summary 'session-title'"
        return 1
    fi
    timestamp=$(date +%Y%m%d_%H%M%S)
    session_file="${WORKSPACE_DIR}/research/output/${timestamp}-session-${1}.md"
    
    cat > "$session_file" << EOF
# ${timestamp} - ${1}

**Session Type**: [Development/Islamic Research/Graphiti Operations]
**Duration**: [time]
**Knowledge Graph Entries**: [count]

## 🎯 Session Objectives

## 🔍 Key Discoveries

## 📋 Technical Changes

## 🧠 Knowledge Graph Insights

## ✅ Session Validation

---

*Session summary auto-generated with timestamp formatting for chronological organization.*
EOF
    
    echo "Created session summary template: $session_file"
}

# Islamic text specific commands
graph_analyze_hadith() {
    if [ -z "$1" ]; then
        echo "Usage: graph_analyze_hadith 'hadith text'"
        return 1
    fi
    echo "Analyzing hadith: $1"
    graph_remember "HADITH: $1"
}

graph_analyze_quran() {
    if [ -z "$1" ]; then
        echo "Usage: graph_analyze_quran 'verse text'"
        return 1
    fi
    echo "Analyzing Quranic verse: $1"
    graph_remember "QURAN: $1"
}

# Aliases for quick access
alias gr='graph_remember'
alias gs='graph_search'  
alias gt='graph_analyze_text'
alias gst='graph_status'
alias gstart='graph_start'

# Claude Docker instances - clean, direct access
alias claude2="${WORKSPACE_DIR}/tools/scripts/interactive-claude-docker.sh"
alias claude-graphiti="${WORKSPACE_DIR}/tools/scripts/claude-graphiti.sh"
alias claude-islamic="${WORKSPACE_DIR}/tools/scripts/claude-islamic.sh"
alias claude-engineering="${WORKSPACE_DIR}/tools/scripts/claude-engineering.sh"

echo "Graphiti commands loaded! Type 'gstart' to begin."