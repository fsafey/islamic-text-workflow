#!/bin/bash
# Graphiti Workflow Commands
# Source this file in your shell profile: source ~/Project/islamic-text-workflow/tools/scripts/graphiti-commands.sh

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
        echo "  Start with: cd /Users/farieds/Project/islamic-text-workflow/graphiti-main/claude_docker && ./scripts/start_claude_docker_api.sh"
    fi
}

# Export knowledge graph
graph_export() {
    echo "Exporting knowledge graph..."
    if [ -f ~/.claude/graphiti_memory.txt ]; then
        cp ~/.claude/graphiti_memory.txt "/Users/farieds/Project/islamic-text-workflow/research/output/knowledge_export_$(date +%Y%m%d_%H%M%S).txt"
        echo "Exported to research/output/"
    else
        echo "No memory file found"
    fi
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
alias claude2='/Users/farieds/Project/islamic-text-workflow/tools/scripts/interactive-claude-docker.sh'
alias claude-graphiti='/Users/farieds/Project/islamic-text-workflow/tools/scripts/claude-graphiti.sh'
alias claude-islamic='/Users/farieds/Project/islamic-text-workflow/tools/scripts/claude-islamic.sh'
alias claude-engineering='/Users/farieds/Project/islamic-text-workflow/tools/scripts/claude-engineering.sh'

echo "Graphiti commands loaded! Type 'gstart' to begin."