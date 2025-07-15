#!/bin/bash
# Project-Specific Graphiti Commands for Islamic Text Workflow
# Tracks development sessions, decisions, and project building activities

PROJECT_ROOT="/Users/farieds/Project/islamic-text-workflow"
PROJECT_MEMORY="$HOME/.claude/project_memory.txt"

# Ensure graphiti commands are loaded
if ! command -v graph_remember >/dev/null 2>&1; then
    source "/Users/farieds/Project/islamic-text-workflow/tools/scripts/graphiti-commands.sh"
fi

# Start a new work session
project_session_start() {
    local session_name="${1:-$(date '+%Y-%m-%d-%H%M')}"
    echo "🚀 Starting project session: $session_name"
    
    # Log session start
    echo "$(date): SESSION_START - $session_name" >> "$PROJECT_MEMORY"
    
    # Record current project state
    cd "$PROJECT_ROOT"
    local git_branch=$(git branch --show-current 2>/dev/null || echo "no-git")
    local git_status=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
    
    graph_remember "PROJECT_SESSION: Started '$session_name' on branch '$git_branch' with $git_status modified files"
    
    echo "Session '$session_name' started and logged to knowledge graph"
}

# End work session with summary
project_session_end() {
    local summary="$1"
    if [ -z "$summary" ]; then
        echo "Usage: project_session_end 'Brief summary of what was accomplished'"
        return 1
    fi
    
    echo "🏁 Ending project session with summary: $summary"
    
    # Log session end
    echo "$(date): SESSION_END - $summary" >> "$PROJECT_MEMORY"
    
    # Record current project state
    cd "$PROJECT_ROOT"
    local git_branch=$(git branch --show-current 2>/dev/null || echo "no-git")
    local git_status=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
    
    graph_remember "PROJECT_SESSION_END: '$summary' on branch '$git_branch' with $git_status modified files"
    
    echo "Session ended and logged to knowledge graph"
}

# Track a development decision
project_decision() {
    local decision="$1"
    if [ -z "$decision" ]; then
        echo "Usage: project_decision 'Description of technical/architectural decision made'"
        return 1
    fi
    
    echo "📋 Recording project decision: $decision"
    echo "$(date): DECISION - $decision" >> "$PROJECT_MEMORY"
    graph_remember "PROJECT_DECISION: $decision"
}

# Track a problem encountered
project_problem() {
    local problem="$1"
    local solution="${2:-pending}"
    if [ -z "$problem" ]; then
        echo "Usage: project_problem 'Problem description' ['Solution or next steps']"
        return 1
    fi
    
    echo "⚠️  Recording project problem: $problem"
    echo "$(date): PROBLEM - $problem | SOLUTION - $solution" >> "$PROJECT_MEMORY"
    graph_remember "PROJECT_PROBLEM: $problem | SOLUTION: $solution"
}

# Track a feature implementation
project_feature() {
    local feature="$1"
    local status="${2:-in-progress}"
    if [ -z "$feature" ]; then
        echo "Usage: project_feature 'Feature description' [status: planned|in-progress|completed|blocked]"
        return 1
    fi
    
    echo "🔧 Recording project feature: $feature ($status)"
    echo "$(date): FEATURE - $feature | STATUS - $status" >> "$PROJECT_MEMORY"
    graph_remember "PROJECT_FEATURE: $feature | STATUS: $status"
}

# Track code changes
project_code_change() {
    local file="$1"
    local change="$2"
    if [ -z "$file" ] || [ -z "$change" ]; then
        echo "Usage: project_code_change 'file/path' 'Description of changes made'"
        return 1
    fi
    
    echo "💻 Recording code change in $file: $change"
    echo "$(date): CODE_CHANGE - $file | $change" >> "$PROJECT_MEMORY"
    graph_remember "PROJECT_CODE_CHANGE: Modified '$file' - $change"
}

# Track research/learning
project_research() {
    local topic="$1"
    local findings="$2"
    if [ -z "$topic" ]; then
        echo "Usage: project_research 'Research topic' 'Key findings or insights'"
        return 1
    fi
    
    echo "📚 Recording research: $topic"
    echo "$(date): RESEARCH - $topic | FINDINGS - $findings" >> "$PROJECT_MEMORY"
    graph_remember "PROJECT_RESEARCH: $topic | FINDINGS: $findings"
}

# Search project history
project_search() {
    local query="$1"
    if [ -z "$query" ]; then
        echo "Usage: project_search 'search terms'"
        return 1
    fi
    
    echo "🔍 Searching project history for: $query"
    
    # Search both local memory and knowledge graph
    echo "=== Local Project Memory ==="
    grep -i "$query" "$PROJECT_MEMORY" 2>/dev/null | tail -10 || echo "No local results found"
    
    echo "=== Knowledge Graph ==="
    graph_search "PROJECT.*$query"
}

# Get project overview
project_overview() {
    echo "📊 Islamic Text Workflow Project Overview"
    echo "========================================"
    
    cd "$PROJECT_ROOT"
    
    # Git info
    local git_branch=$(git branch --show-current 2>/dev/null || echo "no-git")
    local git_commits=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    local git_status=$(git status --porcelain 2>/dev/null | wc -l || echo "0")
    
    echo "Git Status:"
    echo "  Branch: $git_branch"
    echo "  Commits: $git_commits"
    echo "  Modified files: $git_status"
    echo ""
    
    # Recent sessions
    echo "Recent Sessions:"
    tail -5 "$PROJECT_MEMORY" 2>/dev/null | grep "SESSION_START\|SESSION_END" || echo "  No recent sessions"
    echo ""
    
    # Recent decisions
    echo "Recent Decisions:"
    tail -3 "$PROJECT_MEMORY" 2>/dev/null | grep "DECISION" || echo "  No recent decisions"
    echo ""
    
    # Project structure
    echo "Key Directories:"
    find "$PROJECT_ROOT" -maxdepth 2 -type d -name "graphiti*" -o -name "infrastructure" -o -name "tools" -o -name "documentation" 2>/dev/null | head -5
}

# Auto-track git commits
project_auto_commit_hook() {
    if [ -n "$1" ]; then
        local commit_msg="$1"
        echo "📝 Auto-tracking commit: $commit_msg"
        graph_remember "PROJECT_COMMIT: $commit_msg"
        echo "$(date): COMMIT - $commit_msg" >> "$PROJECT_MEMORY"
    fi
}

# Set up auto-tracking for current session
project_setup_auto_tracking() {
    echo "🤖 Setting up auto-tracking for current shell session..."
    
    # Create project memory file if it doesn't exist
    touch "$PROJECT_MEMORY"
    
    # Add git commit hook (optional)
    echo "Auto-tracking enabled. Use project commands:"
    echo "  pstart [name]           - Start work session"
    echo "  pend 'summary'          - End work session"
    echo "  pdecision 'decision'    - Track decision"
    echo "  pproblem 'issue'        - Track problem"
    echo "  pfeature 'feature'      - Track feature work"
    echo "  pcode 'file' 'change'   - Track code changes"
    echo "  presearch 'topic'       - Track research"
    echo "  psearch 'query'         - Search project history"
    echo "  poverview              - Get project overview"
}

# Aliases for quick access
alias pstart='project_session_start'
alias pend='project_session_end'
alias pdecision='project_decision'
alias pproblem='project_problem'
alias pfeature='project_feature'
alias pcode='project_code_change'
alias presearch='project_research'
alias psearch='project_search'
alias poverview='project_overview'
alias ptrack='project_setup_auto_tracking'

echo "🏗️  Project tracking commands loaded! Type 'ptrack' to begin."