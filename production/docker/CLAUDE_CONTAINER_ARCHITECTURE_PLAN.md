# Claude Container Architecture Migration Plan

## Executive Summary

This document outlines the migration from the current subprocess-based Claude CLI execution to a claude-docker inspired architecture where Claude CLI runs as the main container process. This resolves authentication timeout issues and provides a more robust containerized agent system.

## Current Architecture Issues

### Problem Analysis
- **Authentication Failures**: Claude CLI spawned as subprocess cannot access authentication files properly
- **Timeout Errors**: 30-second timeouts when Claude CLI tries to authenticate within containers
- **Process Management**: Complex subprocess management with stdio piping creates reliability issues
- **Environment Isolation**: Subprocess environment doesn't inherit container authentication properly

### Current Flow
```
Container Start → Node.js Express Server → Spawn Claude CLI subprocess → Authentication Failure
```

## Target Architecture (Claude-Docker Pattern)

### Solution Overview
- **Claude CLI as Main Process**: Run Claude directly as container entrypoint
- **Build-Time Authentication**: Copy authentication files during Docker build
- **Direct Project Mounting**: Mount Islamic text workflow as working directory
- **Startup Script**: Handle environment setup and launch Claude with proper flags

### Target Flow
```
Container Start → Startup Script → Authentication Setup → exec claude --dangerously-skip-permissions
```

## Implementation Plan

### Phase 1: Architecture Restructuring

#### 1.1 Container Redesign
**Current Structure:**
```
Container → Node.js Server → HTTP Endpoints → Spawn Claude CLI
```

**New Structure:**
```
Container → Startup Script → Environment Setup → Claude CLI (main process)
```

#### 1.2 Authentication Handling
**Build-Time Authentication Copy:**
```dockerfile
# Copy authentication files during build (claude-docker pattern)
COPY .claude.json /tmp/.claude.json
RUN cp /tmp/.claude.json /home/claude/.claude.json && \
    rm -f /tmp/.claude.json && \
    chown claude:claude /home/claude/.claude.json
```

#### 1.3 Project Structure Changes
```
docker/
├── Dockerfile.claude-agent          # New Claude-focused Dockerfile
├── startup-scripts/
│   ├── flowchart-mapper.sh         # Agent-specific startup
│   ├── network-mapper.sh
│   ├── metadata-hunter.sh
│   ├── content-synthesizer.sh
│   └── data-pipeline.sh
├── claude-configs/
│   ├── flowchart-mapper/
│   │   ├── CLAUDE.md               # Agent-specific instructions
│   │   └── prompts/
│   ├── network-mapper/
│   └── [other agents]/
└── orchestrator/                    # Separate orchestrator container
    ├── Dockerfile
    └── orchestrator.js
```

### Phase 2: Component Implementation

#### 2.1 New Dockerfile Structure
```dockerfile
# Based on claude-docker implementation
FROM node:20-slim

# Install Claude CLI and dependencies
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user
RUN useradd -m -s /bin/bash claude

# Copy authentication files (build-time)
COPY .claude.json /tmp/.claude.json
RUN cp /tmp/.claude.json /home/claude/.claude.json && \
    chown claude:claude /home/claude/.claude.json

# Copy agent-specific configurations
COPY claude-configs/${AGENT_TYPE}/ /home/claude/.claude/
COPY startup-scripts/${AGENT_TYPE}.sh /app/startup.sh

# Set working directory to project
WORKDIR /workspace

# Switch to non-root user
USER claude

# Use startup script as entrypoint
ENTRYPOINT ["/app/startup.sh"]
```

#### 2.2 Agent-Specific Startup Scripts
**Example: flowchart-mapper.sh**
```bash
#!/bin/bash
# Load environment variables
source /app/.env

# Verify authentication
if [ -f "$HOME/.claude/.credentials.json" ]; then
    echo "✓ Claude authentication found"
else
    echo "✗ No Claude authentication - login required"
fi

# Set agent-specific environment
export AGENT_TYPE="flowchart-mapper"
export AGENT_ROLE="Intellectual Architecture Mapping"

# Start Claude with agent-specific prompt
exec claude --dangerously-skip-permissions --print \
    "I am the Flowchart Mapper agent. My role is to analyze Islamic texts and create intellectual architecture mappings. I am ready to process book enrichment requests."
```

#### 2.3 Agent-Specific CLAUDE.md Files
**Example: claude-configs/flowchart-mapper/CLAUDE.md**
```markdown
# Flowchart Mapper Agent

## Role
Intellectual Architecture Mapping for Islamic Text Processing

## Capabilities
- Analyze book content structure and themes
- Create conceptual flowcharts and mind maps
- Identify key intellectual connections
- Generate hierarchical topic structures

## Input Format
- Book metadata and content excerpts
- Processing queue requests from orchestrator

## Output Format
- Structured JSON with intellectual mappings
- Flowchart data for visualization
- Hierarchical topic classifications

## Tools Available
- Supabase database access
- Text analysis libraries
- Flowchart generation utilities
```

### Phase 3: Orchestrator Redesign

#### 3.1 Simplified Orchestrator
**New orchestrator.js (HTTP client, not subprocess manager):**
```javascript
// Orchestrator becomes HTTP client to Claude containers
class AgentOrchestrator {
  async processBook(bookId, agentType) {
    const agentEndpoint = `http://islamic-text-${agentType}:8080/process`;
    
    // Send HTTP request to Claude container
    const response = await fetch(agentEndpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bookId, task: 'enrich' })
    });
    
    return response.json();
  }
}
```

#### 3.2 Container Communication
```yaml
# docker-compose.yml
version: '3.8'
services:
  orchestrator:
    build: 
      context: .
      dockerfile: Dockerfile.orchestrator
    environment:
      - NODE_ENV=production
    depends_on:
      - flowchart-mapper
      - network-mapper
    networks:
      - islamic-text-network

  flowchart-mapper:
    build:
      context: .
      dockerfile: Dockerfile.claude-agent
      args:
        AGENT_TYPE: flowchart-mapper
    environment:
      - AGENT_TYPE=flowchart-mapper
      - AGENT_PORT=8080
    volumes:
      - ./../../:/workspace  # Mount Islamic text workflow
    networks:
      - islamic-text-network
```

### Phase 4: Migration Steps

#### 4.1 Preparation
1. **Backup current implementation**
2. **Test claude-docker authentication** on host system
3. **Verify .claude.json accessibility**
4. **Create agent-specific configurations**

#### 4.2 Implementation Order
1. **Create new Dockerfile.claude-agent**
2. **Implement startup scripts for each agent**
3. **Create agent-specific CLAUDE.md configurations**
4. **Update docker-compose.yml**
5. **Rebuild orchestrator as HTTP client**
6. **Test single agent (flowchart-mapper)**
7. **Scale to all 5 agents**

#### 4.3 Testing Strategy
```bash
# Test individual agent
docker-compose up flowchart-mapper

# Test agent communication
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -d '{"bookId": "test-book", "task": "analyze"}'

# Test orchestrator coordination
docker-compose up orchestrator
```

## Benefits of New Architecture

### Technical Benefits
- **Eliminates subprocess authentication issues**
- **Simpler container lifecycle management**
- **Better resource utilization**
- **Improved debugging and logging**
- **More reliable error handling**

### Operational Benefits
- **Faster agent startup times**
- **Better scalability**
- **Easier maintenance**
- **Clear separation of concerns**
- **Simplified troubleshooting**

## Risk Mitigation

### Potential Issues
1. **Authentication file access**: Mitigated by build-time copying
2. **Container communication**: Addressed through Docker networking
3. **Resource management**: Handled by container limits
4. **Error handling**: Improved through direct process management

### Rollback Plan
- **Maintain current implementation** until migration complete
- **Test new architecture** in parallel
- **Gradual migration** agent by agent
- **Monitoring and validation** at each step

## Success Metrics

### Technical Metrics
- **Zero authentication timeouts**
- **Sub-5 second agent startup times**
- **99%+ container health check success**
- **Consistent agent response times**

### Operational Metrics
- **Successful book processing pipeline**
- **Error rate reduction**
- **Simplified deployment process**
- **Improved monitoring capabilities**

## Next Steps

1. **Review and approve** this migration plan
2. **Set up development environment** for testing
3. **Implement Phase 1** (architecture restructuring)
4. **Test with single agent** (flowchart-mapper)
5. **Scale to full agent ecosystem**
6. **Deploy and monitor** production system

---

**Document Status**: Draft for Review  
**Created**: 2025-01-09  
**Last Updated**: 2025-01-09  
**Next Review**: After Phase 1 completion