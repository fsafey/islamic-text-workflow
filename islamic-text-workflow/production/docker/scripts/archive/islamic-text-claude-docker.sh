#!/bin/bash
# islamic-text-claude-docker.sh - Claude Docker Wrapper Script
# Implements claude-docker patterns for Islamic text workflow
# Based on: https://github.com/VishalJ99/claude-docker

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_IMAGE="islamic-text-claude"
DOCKER_TAG="latest"
FULL_IMAGE="$DOCKER_IMAGE:$DOCKER_TAG"

# Default values
CONTINUE_FLAG=""
REBUILD=false
AGENT_NAME="flowchart_mapper"
AGENT_PORT=3001
DETACHED=false
INTERACTIVE=true
REMOVE_CONTAINER=true

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND]

Islamic Text Processing Claude Docker Wrapper

OPTIONS:
  --continue          Resume previous session
  --rebuild           Force rebuild of Docker image
  --agent NAME        Agent name (default: flowchart_mapper)
  --port PORT         Agent port (default: 3001)
  --detached          Run container in background
  --no-interactive    Disable interactive TTY
  --no-remove         Don't remove container after exit
  --debug             Enable debug logging
  --help              Show this help message

AGENTS:
  flowchart_mapper    Intellectual architecture analysis (port 3001)
  network_mapper      Conceptual relationship mapping (port 3002)  
  metadata_hunter     Bibliographic research (port 3003)
  content_synthesizer Catalog synthesis (port 3004)
  data_pipeline       Production database integration (port 3005)

EXAMPLES:
  $0 --agent flowchart_mapper --continue
  $0 --agent metadata_hunter --port 3003 --rebuild
  $0 --agent data_pipeline --detached --no-remove

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --continue)
            CONTINUE_FLAG="--continue"
            shift
            ;;
        --rebuild)
            REBUILD=true
            shift
            ;;
        --agent)
            AGENT_NAME="$2"
            shift 2
            ;;
        --port)
            AGENT_PORT="$2"
            shift 2
            ;;
        --detached)
            DETACHED=true
            INTERACTIVE=false
            REMOVE_CONTAINER=false
            shift
            ;;
        --no-interactive)
            INTERACTIVE=false
            shift
            ;;
        --no-remove)
            REMOVE_CONTAINER=false
            shift
            ;;
        --debug)
            DEBUG=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            # Pass through unknown arguments to container
            break
            ;;
    esac
done

# Set default ports for different agents
case $AGENT_NAME in
    flowchart_mapper)
        AGENT_PORT=${AGENT_PORT:-3001}
        ;;
    network_mapper)
        AGENT_PORT=${AGENT_PORT:-3002}
        ;;
    metadata_hunter)
        AGENT_PORT=${AGENT_PORT:-3003}
        ;;
    content_synthesizer)
        AGENT_PORT=${AGENT_PORT:-3004}
        ;;
    data_pipeline)
        AGENT_PORT=${AGENT_PORT:-3005}
        ;;
    *)
        log_warn "Unknown agent: $AGENT_NAME, using default port $AGENT_PORT"
        ;;
esac

# Validate environment
validate_environment() {
    log_info "Validating environment..."
    
    # Check Docker is available
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    # Check Docker daemon is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    # Check project directory structure
    if [[ ! -f "$PROJECT_ROOT/Dockerfile" ]]; then
        log_error "Dockerfile not found in $PROJECT_ROOT"
        exit 1
    fi
    
    log_debug "Environment validation passed"
}

# Setup persistent configuration directories
setup_persistent_config() {
    log_info "Setting up persistent configuration..."
    
    # Create Claude home directory (claude-docker pattern)
    local claude_home="$HOME/.claude-docker/claude-home"
    mkdir -p "$claude_home"
    
    # Create SSH directory for git operations
    local ssh_dir="$HOME/.claude-docker/ssh"
    mkdir -p "$ssh_dir"
    
    # Copy SSH keys if they exist
    if [[ -f "$HOME/.ssh/id_rsa" ]]; then
        cp "$HOME/.ssh/id_rsa" "$ssh_dir/" 2>/dev/null || true
        cp "$HOME/.ssh/id_rsa.pub" "$ssh_dir/" 2>/dev/null || true
        chmod 600 "$ssh_dir/id_rsa" 2>/dev/null || true
    fi
    
    # Create agent-specific directories
    local agent_dir="$claude_home/agents/$AGENT_NAME"
    mkdir -p "$agent_dir"
    
    # Copy agent-specific configuration if it exists
    if [[ -f "$PROJECT_ROOT/claude-configs/${AGENT_NAME}.json" ]]; then
        cp "$PROJECT_ROOT/claude-configs/${AGENT_NAME}.json" "$agent_dir/config.json"
        log_debug "Copied agent configuration for $AGENT_NAME"
    fi
    
    # Create project-specific .claude directory
    local project_claude_dir="$PROJECT_ROOT/.claude"
    mkdir -p "$project_claude_dir"
    
    # Copy CLAUDE.md if it doesn't exist in project
    if [[ ! -f "$project_claude_dir/CLAUDE.md" ]]; then
        if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
            cp "$PROJECT_ROOT/CLAUDE.md" "$project_claude_dir/"
            log_debug "Copied CLAUDE.md to project directory"
        fi
    fi
    
    log_debug "Persistent configuration setup complete"
}

# Copy authentication files for build
copy_authentication() {
    log_info "Copying authentication files..."
    
    # Copy Claude authentication file
    local claude_auth="$HOME/.claude.json"
    if [[ -f "$claude_auth" ]]; then
        cp "$claude_auth" "$PROJECT_ROOT/.claude.json"
        log_debug "Copied Claude authentication file"
    else
        log_warn "Claude authentication file not found at $claude_auth"
        log_warn "You may need to run 'claude auth' to authenticate"
    fi
    
    # Copy environment file
    if [[ -f "$PROJECT_ROOT/.env.example" ]]; then
        if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
            cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
            log_debug "Copied .env.example to .env"
        fi
    fi
}

# Build Docker image
build_image() {
    log_info "Building Docker image: $FULL_IMAGE"
    
    # Change to project directory
    cd "$PROJECT_ROOT"
    
    # Build with proper context
    docker build \
        --build-arg USER_UID="$(id -u)" \
        --build-arg USER_GID="$(id -g)" \
        --tag "$FULL_IMAGE" \
        .
    
    # Clean up authentication file
    rm -f "$PROJECT_ROOT/.claude.json"
    
    log_info "Docker image built successfully"
}

# Check if image needs rebuilding
needs_rebuild() {
    if [[ "$REBUILD" == "true" ]]; then
        return 0
    fi
    
    if ! docker images "$FULL_IMAGE" --format "table {{.Repository}}" | grep -q "$DOCKER_IMAGE"; then
        log_debug "Image $FULL_IMAGE does not exist, rebuild needed"
        return 0
    fi
    
    # Check if Dockerfile is newer than image
    if [[ "$PROJECT_ROOT/Dockerfile" -nt <(docker inspect -f '{{.Created}}' "$FULL_IMAGE" 2>/dev/null) ]]; then
        log_debug "Dockerfile is newer than image, rebuild needed"
        return 0
    fi
    
    return 1
}

# Run Docker container
run_container() {
    log_info "Starting container for agent: $AGENT_NAME"
    
    # Build Docker run command
    local docker_cmd=(
        docker run
    )
    
    # Add interactive flags if needed
    if [[ "$INTERACTIVE" == "true" ]]; then
        docker_cmd+=(--interactive --tty)
    fi
    
    # Add removal flag if needed
    if [[ "$REMOVE_CONTAINER" == "true" ]]; then
        docker_cmd+=(--rm)
    fi
    
    # Add detached flag if needed
    if [[ "$DETACHED" == "true" ]]; then
        docker_cmd+=(--detach)
    fi
    
    # Add volume mounts (claude-docker pattern)
    docker_cmd+=(
        # Mount workspace directory
        --volume "$PROJECT_ROOT:/workspace"
        
        # Mount persistent Claude home directory
        --volume "$HOME/.claude-docker/claude-home:/home/claude/.claude:rw"
        
        # Mount SSH directory for git operations
        --volume "$HOME/.claude-docker/ssh:/home/claude/.ssh:ro"
        
        # Mount project-specific .claude directory
        --volume "$PROJECT_ROOT/.claude:/app/.claude:rw"
    )
    
    # Add environment variables
    docker_cmd+=(
        --env "AGENT_NAME=$AGENT_NAME"
        --env "AGENT_PORT=$AGENT_PORT"
        --env "CLAUDE_CONTINUE_FLAG=$CONTINUE_FLAG"
        --env "CLAUDE_HOME=/home/claude/.claude"
        --env "CI=true"
        --env "TERM=dumb"
    )
    
    # Add port mapping
    docker_cmd+=(
        --publish "$AGENT_PORT:$AGENT_PORT"
    )
    
    # Add network for agent communication
    docker_cmd+=(
        --network "islamic_text_agents"
    )
    
    # Add container name
    docker_cmd+=(
        --name "islamic-text-${AGENT_NAME}-$(date +%s)"
    )
    
    # Add image
    docker_cmd+=("$FULL_IMAGE")
    
    # Add remaining arguments
    docker_cmd+=("$@")
    
    log_debug "Docker command: ${docker_cmd[*]}"
    
    # Execute container
    exec "${docker_cmd[@]}"
}

# Main execution
main() {
    log_info "Islamic Text Processing Claude Docker Wrapper"
    log_info "Agent: $AGENT_NAME | Port: $AGENT_PORT"
    
    # Validate environment
    validate_environment
    
    # Setup persistent configuration
    setup_persistent_config
    
    # Check if rebuild is needed
    if needs_rebuild; then
        log_info "Image rebuild required"
        copy_authentication
        build_image
    else
        log_info "Using existing image: $FULL_IMAGE"
    fi
    
    # Run container
    run_container "$@"
}

# Execute main function
main "$@"