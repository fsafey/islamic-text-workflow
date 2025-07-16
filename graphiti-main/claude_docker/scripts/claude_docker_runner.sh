#!/bin/bash
# Container-friendly Claude Docker runner
# This script works from within containers to call the host Claude Docker system

# Set up proper environment for Claude Docker execution
export HOME=/Users/farieds

# Parse command line arguments to handle --api, --print, --model, etc.
CLAUDE_ARGS=""
API_MODE=false
PRINT_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --api)
            API_MODE=true
            ;;
        --print)
            PRINT_MODE=true
            ;;
        --model)
            CLAUDE_ARGS="$CLAUDE_ARGS --model $2"
            shift 2
            continue
            ;;
        --output-format)
            # Skip this - Claude Docker doesn't support this flag
            shift 2
            continue
            ;;
        *)
            CLAUDE_ARGS="$CLAUDE_ARGS $1"
            ;;
    esac
    shift
done

# Build the docker run command with proper authentication mounts
# Use the exact pattern that works from the host system
exec docker run --rm -i \
    -v "/Users/farieds/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "/Users/farieds/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    --network host \
    claude-docker:latest \
    claude --print $CLAUDE_ARGS