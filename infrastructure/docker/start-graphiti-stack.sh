#!/bin/bash
# Start Graphiti Stack - Complete containerized setup
# This script orchestrates the full Graphiti ecosystem

set -e

echo "🚀 Starting Graphiti Stack with Neo4j, Claude Docker, and Supabase Integration"
echo "=" * 70

# Configuration
COMPOSE_FILE="/workspace/infrastructure/docker/docker-compose-graphiti-stack.yml"
DOCKER_NETWORK="graphiti-network"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Create necessary directories
setup_directories() {
    log_info "Setting up directories..."
    
    mkdir -p /workspace/research/output
    mkdir -p /workspace/tools/docker/templates
    mkdir -p /workspace/infrastructure/docker/volumes/neo4j-data
    mkdir -p /workspace/infrastructure/docker/volumes/neo4j-logs
    mkdir -p /workspace/infrastructure/docker/volumes/claude-logs
    
    log_info "Directories created"
}

# Check environment variables
check_environment() {
    log_info "Checking environment variables..."
    
    # Check for Google API Key
    if [ -z "$GOOGLE_API_KEY" ]; then
        if [ -f "/workspace/graphiti-main/claude_docker/.env" ]; then
            export GOOGLE_API_KEY=$(grep GOOGLE_API_KEY /workspace/graphiti-main/claude_docker/.env | cut -d'=' -f2)
            log_info "Google API Key loaded from .env file"
        else
            log_warning "Google API Key not found. Some services may not work properly."
        fi
    fi
    
    # Check for Claude Docker authentication
    if [ ! -d "$HOME/.claude-docker" ]; then
        log_warning "Claude Docker authentication not found at $HOME/.claude-docker"
        log_warning "Some services may not work properly."
    fi
    
    log_info "Environment check completed"
}

# Build images
build_images() {
    log_info "Building Docker images..."
    
    cd /workspace
    
    # Build images with proper context
    docker-compose -f "$COMPOSE_FILE" build --no-cache
    
    log_info "Docker images built successfully"
}

# Start services in order
start_services() {
    log_info "Starting services..."
    
    cd /workspace
    
    # Start Neo4j first
    log_info "Starting Neo4j database..."
    docker-compose -f "$COMPOSE_FILE" up -d neo4j
    
    # Wait for Neo4j to be ready
    log_info "Waiting for Neo4j to be ready..."
    sleep 30
    
    # Start Claude Docker API
    log_info "Starting Claude Docker API..."
    docker-compose -f "$COMPOSE_FILE" up -d claude-docker-api
    
    # Wait for Claude Docker API
    log_info "Waiting for Claude Docker API to be ready..."
    sleep 20
    
    # Start Graphiti Service
    log_info "Starting Graphiti Service..."
    docker-compose -f "$COMPOSE_FILE" up -d graphiti-service
    
    # Wait for Graphiti Service
    log_info "Waiting for Graphiti Service to be ready..."
    sleep 15
    
    # Start remaining services
    log_info "Starting remaining services..."
    docker-compose -f "$COMPOSE_FILE" up -d graphiti-commands supabase-integration graphiti-monitor commands-gateway
    
    # Start worker pool
    log_info "Starting worker pool..."
    docker-compose -f "$COMPOSE_FILE" up -d graphiti-worker
    
    log_info "All services started successfully"
}

# Check service health
check_health() {
    log_info "Checking service health..."
    
    services=(
        "neo4j:7474"
        "claude-docker-api:8000"
        "graphiti-service:8080"
        "graphiti-commands:8081"
        "graphiti-monitor:8082"
        "supabase-integration:8083"
        "commands-gateway:8090"
    )
    
    for service in "${services[@]}"; do
        name=$(echo $service | cut -d':' -f1)
        port=$(echo $service | cut -d':' -f2)
        
        log_info "Checking $name on port $port..."
        
        # Wait up to 60 seconds for service to be ready
        for i in {1..12}; do
            if curl -f "http://localhost:$port/health" &> /dev/null || curl -f "http://localhost:$port" &> /dev/null; then
                log_info "$name is healthy"
                break
            fi
            
            if [ $i -eq 12 ]; then
                log_warning "$name may not be ready yet"
            else
                sleep 5
            fi
        done
    done
    
    log_info "Health check completed"
}

# Display service URLs
display_services() {
    log_info "Graphiti Stack is running! Service URLs:"
    echo ""
    echo "🔍 Monitoring Dashboard:     http://localhost:8082"
    echo "🧠 Graphiti Service:         http://localhost:8080"
    echo "🐳 Claude Docker API:        http://localhost:8000"
    echo "📊 Neo4j Browser:            http://localhost:7474"
    echo "⚡ Commands Gateway:         http://localhost:8090"
    echo "🔗 Supabase Integration:     http://localhost:8083"
    echo "🛠️ Enhanced Commands:        http://localhost:8081"
    echo ""
    echo "📋 Neo4j Credentials:"
    echo "   Username: neo4j"
    echo "   Password: password"
    echo ""
    echo "🚀 To use enhanced commands, run:"
    echo "   curl -X POST http://localhost:8090/commands -H 'Content-Type: application/json' -d '{\"command\": \"gst\"}'"
    echo ""
    echo "🛑 To stop the stack:"
    echo "   docker-compose -f $COMPOSE_FILE down"
}

# Main execution
main() {
    check_prerequisites
    setup_directories
    check_environment
    build_images
    start_services
    check_health
    display_services
    
    log_info "Graphiti Stack startup completed successfully!"
}

# Handle script arguments
case "$1" in
    "stop")
        log_info "Stopping Graphiti Stack..."
        docker-compose -f "$COMPOSE_FILE" down
        log_info "Graphiti Stack stopped"
        ;;
    "restart")
        log_info "Restarting Graphiti Stack..."
        docker-compose -f "$COMPOSE_FILE" down
        sleep 5
        main
        ;;
    "logs")
        service="${2:-}"
        if [ -n "$service" ]; then
            docker-compose -f "$COMPOSE_FILE" logs -f "$service"
        else
            docker-compose -f "$COMPOSE_FILE" logs -f
        fi
        ;;
    "status")
        docker-compose -f "$COMPOSE_FILE" ps
        ;;
    *)
        main
        ;;
esac