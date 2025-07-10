#!/bin/bash
# ABOUTME: Startup script for Islamic text processing agents with claude-docker pattern
# ABOUTME: Loads environment vars, checks authentication, copies CLAUDE.md template if needed
# ABOUTME: Starts Claude Code with permissions bypass and continues from last session

# Load environment variables from .env if it exists
# Use the .env file baked into the image at build time
if [ -f /app/.env ]; then
    echo "Loading environment from baked-in .env file"
    set -a
    source /app/.env 2>/dev/null || true
    set +a
    
    # Export environment variables for runtime use
    export SUPABASE_URL
    export SUPABASE_SERVICE_KEY
    export TWILIO_ACCOUNT_SID
    export TWILIO_AUTH_TOKEN
    export TWILIO_FROM_NUMBER
    export TWILIO_TO_NUMBER
    export GITHUB_TOKEN
else
    echo "WARNING: No .env file found in image."
fi

# Check for existing authentication
if [ -f "$HOME/.claude/.credentials.json" ]; then
    echo "Found existing Claude authentication"
else
    echo "No existing authentication found - you will need to log in"
    echo "Your login will be saved for future sessions"
fi

# Handle CLAUDE.md template (claude-docker pattern)
if [ ! -f "$HOME/.claude/CLAUDE.md" ]; then
    echo "✓ No CLAUDE.md found at $HOME/.claude/CLAUDE.md - copying template"
    # Copy from the template that was baked into the image
    if [ -f "/app/.claude/CLAUDE.md" ]; then
        cp "/app/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    elif [ -f "/home/claude-user/.claude/CLAUDE.md" ]; then
        # Fallback for existing images
        cp "/home/claude-user/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    fi
    echo "  Template copied to: $HOME/.claude/CLAUDE.md"
else
    echo "✓ Using existing CLAUDE.md from $HOME/.claude/CLAUDE.md"
    echo "  This maps to: ~/.claude-docker/claude-home/CLAUDE.md on your host"
    echo "  To reset to template, delete this file and restart"
fi

# Agent-specific configuration setup
AGENT_NAME="${AGENT_NAME:-flowchart_mapper}"
AGENT_PORT="${AGENT_PORT:-3001}"

echo "✓ Agent configuration:"
echo "  Agent: $AGENT_NAME"
echo "  Port: $AGENT_PORT"

# Create agent directory and copy agent-specific config if available
mkdir -p "$HOME/.claude/agents/$AGENT_NAME"
if [ -f "/app/claude-configs/${AGENT_NAME}.json" ]; then
    cp "/app/claude-configs/${AGENT_NAME}.json" "$HOME/.claude/agents/$AGENT_NAME/config.json"
    echo "✓ Agent-specific configuration loaded"
fi

# Verify MCP configuration
if [ -n "$TWILIO_ACCOUNT_SID" ] && [ -n "$TWILIO_AUTH_TOKEN" ]; then
    echo "✓ Twilio MCP server configured - SMS notifications enabled"
else
    echo "No Twilio credentials found - SMS notifications disabled"
fi

if [ -n "$GITHUB_TOKEN" ]; then
    echo "✓ GitHub MCP server configured"
else
    echo "No GitHub token found - GitHub MCP server disabled"
fi

# Change to workspace directory
cd /workspace

# Set working directory for the agent
export CLAUDE_HOME="$HOME/.claude"
export CI=true
export TERM=dumb

# Start agent based on type
if [ "$AGENT_NAME" = "orchestrator" ] || [ "$ORCHESTRATOR_MODE" = "true" ]; then
    echo "Starting Islamic Text Processing Orchestrator..."
    exec node /app/orchestrator.js
elif [ "$AGENT_NAME" = "dashboard" ] || [ "$DASHBOARD_MODE" = "true" ]; then
    echo "Starting Islamic Text Processing Dashboard..."
    exec node /app/orchestrator.js
else
    echo "Starting Islamic Text Processing Agent: $AGENT_NAME"
    # Start Claude Code with permissions bypass
    exec claude $CLAUDE_CONTINUE_FLAG --dangerously-skip-permissions "$@"
fi