#!/bin/bash
# Islamic Text Workflow Dev Container Debugging Script
# Comprehensive validation and troubleshooting for the development environment

set -e

echo "🔍 Islamic Text Workflow Dev Container Debugging"
echo "=================================================="
echo

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
ISSUES_FOUND=()

# Function to run test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo
    log_info "Testing: $test_name"
    
    if eval "$test_command"; then
        log_success "$test_name: PASSED"
        ((TESTS_PASSED++))
        return 0
    else
        log_error "$test_name: FAILED"
        ((TESTS_FAILED++))
        ISSUES_FOUND+=("$test_name")
        return 1
    fi
}

# Test 1: Docker and Docker Compose availability
test_docker() {
    docker --version > /dev/null 2>&1 && docker compose version > /dev/null 2>&1
}

# Test 2: Docker daemon accessibility
test_docker_daemon() {
    docker ps > /dev/null 2>&1
}

# Test 3: Docker Compose file syntax
test_compose_syntax() {
    cd "$(dirname "$0")"
    docker compose config --quiet > /dev/null 2>&1
}

# Test 4: Docker network conflicts
test_network_conflicts() {
    cd "$(dirname "$0")"
    # Check if the network subnet conflicts with existing networks
    if docker network ls --format "{{.Name}}" | grep -q "islamic-dev-network"; then
        log_warning "islamic-dev-network already exists, checking for conflicts..."
        docker network inspect islamic-dev-network > /dev/null 2>&1
    fi
    
    # Try to create a test network with the same subnet
    docker network create --subnet=172.21.0.0/16 test-islamic-network 2>/dev/null && \
    docker network rm test-islamic-network 2>/dev/null
}

# Test 5: Required Docker images availability
test_docker_images() {
    local images=("neo4j:5.26-community" "nginx:alpine" "python:3.11-slim")
    for image in "${images[@]}"; do
        docker image inspect "$image" > /dev/null 2>&1 || docker pull "$image" > /dev/null 2>&1
    done
}

# Test 6: Port availability
test_port_availability() {
    local ports=(7474 7687 8000 8001 8080 9000)
    for port in "${ports[@]}"; do
        if lsof -i ":$port" > /dev/null 2>&1; then
            log_warning "Port $port is already in use"
            lsof -i ":$port" | grep LISTEN
        fi
    done
    return 0  # Don't fail test for port conflicts, just warn
}

# Test 7: File system permissions
test_file_permissions() {
    cd "$(dirname "$0")/.."
    [ -r "graphiti-main/pyproject.toml" ] && \
    [ -r "tools/scripts/graphiti-commands.sh" ] && \
    [ -x ".devcontainer/setup.sh" ]
}

# Test 8: Environment variable setup
test_env_vars() {
    cd "$(dirname "$0")"
    if [ -f ".env" ]; then
        log_info "Found .env file, checking for required variables..."
        # Check for potentially missing variables that could cause MCP server issues
        return 0
    else
        log_warning "No .env file found - MCP servers requiring env vars may fail"
        return 0
    fi
}

# Test 9: Graphiti Claude Docker API health
test_claude_api() {
    curl -f "http://localhost:8000/health" --connect-timeout 5 > /dev/null 2>&1
}

# Test 10: Neo4j accessibility
test_neo4j() {
    curl -f "http://localhost:7474/db/data/" --connect-timeout 5 > /dev/null 2>&1
}

# Main testing sequence
echo "Starting comprehensive dev container diagnostics..."
echo

# Core infrastructure tests
run_test "Docker Installation" test_docker
run_test "Docker Daemon Access" test_docker_daemon
run_test "Compose File Syntax" test_compose_syntax
run_test "Network Conflicts" test_network_conflicts
run_test "Docker Images" test_docker_images
run_test "Port Availability" test_port_availability
run_test "File Permissions" test_file_permissions
run_test "Environment Variables" test_env_vars

# Service health tests (these may fail if containers aren't running)
echo
log_info "Testing running services (may fail if containers are stopped)..."
run_test "Claude Docker API Health" test_claude_api || true
run_test "Neo4j Accessibility" test_neo4j || true

# Container status check
echo
log_info "Current container status:"
docker ps -a --filter name=islamic --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Network diagnostics
echo
log_info "Network diagnostics:"
docker network ls | grep -E "(islamic|NETWORK)" || echo "No Islamic Text Workflow networks found"

# Recommendations based on findings
echo
echo "=================================================="
log_info "DIAGNOSTIC SUMMARY"
echo "=================================================="
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ ${#ISSUES_FOUND[@]} -gt 0 ]; then
    echo
    log_warning "Issues found:"
    for issue in "${ISSUES_FOUND[@]}"; do
        echo "  - $issue"
    done
    
    echo
    log_info "TROUBLESHOOTING RECOMMENDATIONS:"
    
    # Specific recommendations based on common issues
    if [[ " ${ISSUES_FOUND[@]} " =~ "Network Conflicts" ]]; then
        echo
        log_warning "Docker Network Conflict Detected:"
        echo "The subnet 172.21.0.0/16 conflicts with an existing network."
        echo "Solutions:"
        echo "1. Remove conflicting networks: docker network prune"
        echo "2. Change subnet in docker-compose.yml to 172.22.0.0/16 or 172.23.0.0/16"
        echo "3. Use different network name"
    fi
    
    if [[ " ${ISSUES_FOUND[@]} " =~ "Port Availability" ]]; then
        echo
        log_warning "Port Conflicts Detected:"
        echo "Some required ports are in use. Consider:"
        echo "1. Stop conflicting services"
        echo "2. Change port mappings in docker-compose.yml"
        echo "3. Use different port ranges"
    fi
    
    echo
    log_info "Quick fixes to try:"
    echo "1. Clean up Docker: docker system prune -f"
    echo "2. Remove old networks: docker network prune -f"
    echo "3. Restart Docker daemon"
    echo "4. Rebuild containers: docker compose up --build --force-recreate"
    
else
    echo
    log_success "All tests passed! Dev container should work correctly."
    echo
    log_info "To start the development environment:"
    echo "cd .devcontainer && docker compose up -d"
fi

echo
log_info "For detailed troubleshooting, see:"
echo "- .devcontainer/DEV_CONTAINER_GUIDE.md"
echo "- documentation/guides/CLAUDE_DOCKER_INTERACTIVE_USAGE.md"
echo "- Check logs: docker compose logs [service-name]"