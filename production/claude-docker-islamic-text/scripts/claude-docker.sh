#!/bin/bash
# ABOUTME: Wrapper script to run Islamic Text Processing agents in Docker containers
# ABOUTME: Based on claude-docker-model patterns for reliable session management

# Parse command line arguments
NO_CACHE=""
FORCE_REBUILD=false
CONTINUE_FLAG=""
MEMORY_LIMIT=""
GPU_ACCESS=""
AGENT_NAME=""
ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --rebuild)
            FORCE_REBUILD=true
            shift
            ;;
        --continue)
            CONTINUE_FLAG="--continue"
            shift
            ;;
        --memory)
            MEMORY_LIMIT="$2"
            shift 2
            ;;
        --gpus)
            GPU_ACCESS="$2"
            shift 2
            ;;
        --agent)
            AGENT_NAME="$2"
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

# Get the absolute path of the current directory
CURRENT_DIR=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if .claude directory exists in current project, create if not
if [ ! -d "$CURRENT_DIR/.claude" ]; then
    echo "Creating .claude directory for this project..."
    mkdir -p "$CURRENT_DIR/.claude"
    
    # Copy template files
    cp "$PROJECT_ROOT/.claude/CLAUDE.md" "$CURRENT_DIR/.claude/"
    
    echo "✓ Claude configuration created"
fi

# Check if .env exists for building
ENV_FILE="$PROJECT_ROOT/.env"
if [ -f "$ENV_FILE" ]; then
    echo "✓ Found .env file with credentials"
    # Source .env to get configuration variables
    set -a
    source "$ENV_FILE" 2>/dev/null || true
    set +a
else
    echo "⚠️  No .env file found at $ENV_FILE"
    echo "   Islamic text processing features will be limited."
fi

# Use environment variables as defaults if command line args not provided
if [ -z "$MEMORY_LIMIT" ] && [ -n "$DOCKER_MEMORY_LIMIT" ]; then
    MEMORY_LIMIT="$DOCKER_MEMORY_LIMIT"
    echo "✓ Using memory limit from environment: $MEMORY_LIMIT"
fi

if [ -z "$GPU_ACCESS" ] && [ -n "$DOCKER_GPU_ACCESS" ]; then
    GPU_ACCESS="$DOCKER_GPU_ACCESS"
    echo "✓ Using GPU access from environment: $GPU_ACCESS"
fi

# Check if we need to rebuild the image
NEED_REBUILD=false
IMAGE_NAME="islamic-text-claude-docker"

if ! docker images | grep -q "$IMAGE_NAME"; then
    echo "Building Islamic Text Processing Claude Docker image for first time..."
    NEED_REBUILD=true
fi

if [ "$FORCE_REBUILD" = true ]; then
    echo "Forcing rebuild of Islamic Text Processing Claude Docker image..."
    NEED_REBUILD=true
fi

if [ "$NEED_REBUILD" = true ]; then
    # Copy authentication files to build context
    if [ -f "$HOME/.claude.json" ]; then
        cp "$HOME/.claude.json" "$PROJECT_ROOT/.claude.json"
    fi
    
    # Get git config from host
    GIT_USER_NAME=$(git config --global --get user.name 2>/dev/null || echo "")
    GIT_USER_EMAIL=$(git config --global --get user.email 2>/dev/null || echo "")
    
    # Build docker command with conditional system packages and git config
    BUILD_ARGS="--build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g)"
    if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
        BUILD_ARGS="$BUILD_ARGS --build-arg GIT_USER_NAME=\"$GIT_USER_NAME\" --build-arg GIT_USER_EMAIL=\"$GIT_USER_EMAIL\""
    fi
    if [ -n "$SYSTEM_PACKAGES" ]; then
        echo "✓ Building with additional system packages: $SYSTEM_PACKAGES"
        BUILD_ARGS="$BUILD_ARGS --build-arg SYSTEM_PACKAGES=\"$SYSTEM_PACKAGES\""
    fi
    
    eval "docker build $NO_CACHE $BUILD_ARGS -t $IMAGE_NAME:latest \"$PROJECT_ROOT\""
    
    # Clean up copied auth files
    rm -f "$PROJECT_ROOT/.claude.json"
fi

# Ensure the claude-home and ssh directories exist
mkdir -p "$HOME/.claude-docker/claude-home"
mkdir -p "$HOME/.claude-docker/ssh"

# Copy authentication files to persistent claude-home if they don't exist
if [ -f "$HOME/.claude/.credentials.json" ] && [ ! -f "$HOME/.claude-docker/claude-home/.credentials.json" ]; then
    echo "✓ Copying Claude authentication to persistent directory"
    cp "$HOME/.claude/.credentials.json" "$HOME/.claude-docker/claude-home/.credentials.json"
fi

# Check SSH key setup
SSH_KEY_PATH="$HOME/.claude-docker/ssh/id_rsa"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "⚠️  SSH keys not found for git operations - Islamic text processing will work in read-only mode"
fi

# Prepare Docker run arguments
DOCKER_OPTS=""
ENV_ARGS=""

# Add memory limit if specified
if [ -n "$MEMORY_LIMIT" ]; then
    echo "✓ Setting memory limit: $MEMORY_LIMIT"
    DOCKER_OPTS="$DOCKER_OPTS --memory $MEMORY_LIMIT"
fi

# Add GPU access if specified
if [ -n "$GPU_ACCESS" ]; then
    if docker info 2>/dev/null | grep -q nvidia || which nvidia-docker >/dev/null 2>&1; then
        echo "✓ Enabling GPU access: $GPU_ACCESS"
        DOCKER_OPTS="$DOCKER_OPTS --gpus $GPU_ACCESS"
    else
        echo "⚠️  GPU access requested but NVIDIA Docker runtime not found"
    fi
fi

# Set agent-specific environment
if [ -n "$AGENT_NAME" ]; then
    ENV_ARGS="$ENV_ARGS -e AGENT_NAME=$AGENT_NAME"
    
    # Set port based on agent
    case $AGENT_NAME in
        flowchart_mapper)
            ENV_ARGS="$ENV_ARGS -e AGENT_PORT=3001"
            DOCKER_OPTS="$DOCKER_OPTS -p 3001:3001"
            ;;
        network_mapper)
            ENV_ARGS="$ENV_ARGS -e AGENT_PORT=3002"
            DOCKER_OPTS="$DOCKER_OPTS -p 3002:3002"
            ;;
        metadata_hunter)
            ENV_ARGS="$ENV_ARGS -e AGENT_PORT=3003"
            DOCKER_OPTS="$DOCKER_OPTS -p 3003:3003"
            ;;
        content_synthesizer)
            ENV_ARGS="$ENV_ARGS -e AGENT_PORT=3004"
            DOCKER_OPTS="$DOCKER_OPTS -p 3004:3004"
            ;;
        data_pipeline)
            ENV_ARGS="$ENV_ARGS -e AGENT_PORT=3005"
            DOCKER_OPTS="$DOCKER_OPTS -p 3005:3005"
            ;;
        orchestrator)
            ENV_ARGS="$ENV_ARGS -e ORCHESTRATOR_MODE=true -e AGENT_PORT=4000"
            DOCKER_OPTS="$DOCKER_OPTS -p 4000:4000"
            ;;
        dashboard)
            ENV_ARGS="$ENV_ARGS -e DASHBOARD_MODE=true -e AGENT_PORT=8080"
            DOCKER_OPTS="$DOCKER_OPTS -p 8080:8080"
            ;;
    esac
fi

# Run Islamic Text Processing Claude in Docker
echo "Starting Islamic Text Processing Claude Agent: ${AGENT_NAME:-default}"
docker run -it --rm \
    $DOCKER_OPTS \
    -v "$CURRENT_DIR:/workspace" \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    $ENV_ARGS \
    -e CLAUDE_CONTINUE_FLAG="$CONTINUE_FLAG" \
    --workdir /workspace \
    --name "islamic-text-claude-$(basename "$CURRENT_DIR")-$$" \
    $IMAGE_NAME:latest "${ARGS[@]}"