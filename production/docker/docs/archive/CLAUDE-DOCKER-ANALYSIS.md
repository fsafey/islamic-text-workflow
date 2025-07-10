# Claude-Docker Repository Analysis & Implementation Guide

**Analysis Date**: 2025-07-09  
**Source**: https://github.com/VishalJ99/claude-docker  
**Purpose**: Understand patterns for implementing Claude Code CLI in Docker containers for our Islamic text workflow

---

## 🎯 **Executive Summary**

The claude-docker repository provides a **production-ready pattern** for containerizing Claude Code CLI with proper session management, authentication, and workspace isolation. Their approach solves the exact problems we've encountered and provides a clean, maintainable architecture.

### **Key Insights**
1. **Session-based Authentication Works**: They successfully use `.claude.json` file copying without API keys
2. **Persistent Configuration**: They mount `~/.claude-docker/claude-home/` for persistent settings
3. **Workspace Isolation**: Each project gets its own `.claude/` directory 
4. **MCP Integration**: Modular MCP server configuration for enhanced capabilities
5. **Proper User Management**: UID/GID matching between host and container

---

## 🔧 **Technical Architecture Analysis**

### **1. Authentication Pattern**
```bash
# During build - copy host authentication
COPY .claude.json /tmp/.claude.json
RUN cp /tmp/.claude.json /home/claude-user/.claude.json

# During runtime - mount persistent directory
-v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw"
```

**Key Insight**: They copy the host's `.claude.json` during build time, then mount a persistent directory at runtime. This ensures authentication persists across container restarts.

### **2. User Management Pattern**
```dockerfile
# Create non-root user with matching UID/GID
ARG USER_UID=1000
ARG USER_GID=1000
RUN useradd -m -s /bin/bash -u $USER_UID -g $GROUP_NAME claude-user
```

**Key Insight**: They match host UID/GID to container user to ensure proper file permissions.

### **3. Workspace Isolation Pattern**
```bash
# Each project gets its own .claude directory
if [ ! -d "$CURRENT_DIR/.claude" ]; then
    mkdir -p "$CURRENT_DIR/.claude"
    cp "$PROJECT_ROOT/.claude/CLAUDE.md" "$CURRENT_DIR/.claude/"
fi
```

**Key Insight**: Each project workspace gets its own `.claude/` configuration, enabling project-specific settings.

### **4. Session Management**
```bash
# Startup script handles session continuation
exec claude $CLAUDE_CONTINUE_FLAG --dangerously-skip-permissions "$@"
```

**Key Insight**: They use the `--continue` flag to resume sessions, with the flag passed via environment variable.

---

## 📊 **Key Patterns to Adopt**

### **Pattern 1: Persistent Configuration Architecture**
```
Host System:
~/.claude-docker/claude-home/          # Persistent config
~/.claude-docker/ssh/                  # SSH keys for git

Container:
/home/claude-user/.claude/ → (mounted from host)
/workspace → (current project directory)
```

### **Pattern 2: Environment Variable Management**
```dockerfile
# Build-time: Bake credentials into image
COPY .env /app/.env

# Runtime: Source environment in startup script
source /app/.env
export TWILIO_ACCOUNT_SID
```

### **Pattern 3: MCP Server Configuration**
```bash
# File: mcp-servers.txt
claude mcp add -s user context7 https://mcp.context7.com/sse
claude mcp add-json twilio -s user "{\"command\":\"npx\",\"args\":[\"-y\",\"@yiyang.1i/sms-mcp-server\"]}"
```

### **Pattern 4: Wrapper Script Architecture**
```bash
#!/bin/bash
# Parse arguments (--continue, --rebuild, --memory, --gpus)
# Handle authentication file copying
# Mount appropriate directories
# Execute docker run with proper configuration
```

---

## 🚀 **Implementation Recommendations for Islamic Text Workflow**

### **Immediate Actions**

#### **1. Restructure Authentication (Critical)**
```bash
# CURRENT (BROKEN): Complex jq manipulation
# PROPOSED: Simple file copying pattern

# Build time:
COPY .claude.json /home/claude/.claude.json

# Runtime:
-v "$HOME/.claude-docker/claude-home:/home/claude/.claude:rw"
```

#### **2. Implement Persistent Configuration**
```bash
mkdir -p ~/.claude-docker/claude-home
# Copy our agent-specific configs to persistent location
cp claude-configs/flowchart-mapper.claude.json ~/.claude-docker/claude-home/
```

#### **3. Add Wrapper Script**
```bash
#!/bin/bash
# islamic-text-claude-docker.sh
# Handle --continue flag for session resumption
# Mount proper directories
# Execute with correct agent configuration
```

#### **4. Simplify Startup Process**
```bash
#!/bin/bash
# startup.sh
# Load environment from baked-in .env
# Copy CLAUDE.md if needed
# Start claude with --continue flag
exec claude $CLAUDE_CONTINUE_FLAG --dangerously-skip-permissions "$@"
```

### **Advanced Implementation**

#### **5. MCP Server Integration**
```bash
# Add Supabase MCP server for database operations
claude mcp add-json supabase -s user '{"command":"node","args":["supabase-mcp-server"],"env":{"SUPABASE_URL":"${SUPABASE_URL}"}}'

# Add Context7 for documentation
claude mcp add -s user --transport sse context7 https://mcp.context7.com/sse
```

#### **6. Islamic Text Specific Configuration**
```markdown
# ~/.claude-docker/claude-home/CLAUDE.md
# Islamic Text Processing Agent Protocol
- Focus on Islamic scholarship accuracy
- Use proper Arabic transliteration
- Maintain cultural sensitivity
- Generate structured JSON for database storage
```

---

## 🔍 **Critical Differences from Our Current Approach**

### **What We're Doing Wrong**
1. **Over-complicating authentication**: Using jq to manipulate JSON configs
2. **No persistent storage**: Configurations lost on container restart
3. **Missing session management**: No --continue flag support
4. **No wrapper script**: Direct docker-compose without abstraction
5. **No MCP integration**: Missing enhanced capabilities

### **What They Do Right**
1. **Simple file copying**: Just copy `.claude.json` and mount persistent directory
2. **Persistent configuration**: `~/.claude-docker/claude-home/` survives restarts
3. **Session continuation**: Built-in `--continue` flag support
4. **Wrapper script abstraction**: `claude-docker.sh` handles complexity
5. **MCP ecosystem**: Extensible capabilities through MCP servers

---

## 🛠 **Proposed Implementation Plan**

### **Phase 1: Foundation (Immediate)**
1. **Implement persistent configuration pattern**
   - Create `~/.claude-docker/claude-home/` structure
   - Mount this directory in containers
   - Copy authentication files during build

2. **Add wrapper script**
   - Create `islamic-text-claude-docker.sh`
   - Handle --continue, --rebuild flags
   - Manage container lifecycle

3. **Simplify startup process**
   - Remove complex jq operations
   - Use simple file copying
   - Add --continue flag support

### **Phase 2: Enhancement (Next)**
1. **Add MCP server integration**
   - Context7 for documentation
   - Supabase MCP for database operations
   - Custom Islamic text processing MCP

2. **Implement project-specific configurations**
   - Each agent gets its own `.claude/` directory
   - Agent-specific CLAUDE.md files
   - Tool permission management

### **Phase 3: Production (Later)**
1. **Add notification system**
   - SMS notifications via Twilio MCP
   - Email alerts for long-running tasks
   - Slack integration for team updates

2. **Implement advanced features**
   - Memory limits and resource management
   - GPU access for NLP tasks
   - Advanced logging and monitoring

---

## 📋 **Specific Code Changes Required**

### **1. New File Structure**
```
islamic-text-workflow/agent-reservoir-workflow/production/docker/
├── scripts/
│   ├── islamic-text-claude-docker.sh    # Wrapper script
│   └── startup.sh                       # Container startup
├── .claude/
│   ├── CLAUDE.md                        # Islamic text processing protocol
│   └── settings.json                    # Claude settings
├── mcp-servers.txt                      # MCP server configuration
├── install-mcp-servers.sh               # MCP installation script
└── Dockerfile                           # Simplified container
```

### **2. Updated Dockerfile**
```dockerfile
FROM node:18-alpine

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create user with matching UID/GID
ARG USER_UID=1001
ARG USER_GID=1001
RUN addgroup -g $USER_GID claude && adduser -S claude -u $USER_UID -G claude

# Copy configuration
COPY .claude /app/.claude
COPY .env /app/.env
COPY scripts/startup.sh /app/

# Copy authentication
COPY .claude.json /home/claude/.claude.json

# Set ownership
RUN chown -R claude:claude /app /home/claude

USER claude
WORKDIR /workspace
ENTRYPOINT ["/app/startup.sh"]
```

### **3. Wrapper Script Template**
```bash
#!/bin/bash
# islamic-text-claude-docker.sh

# Parse arguments
CONTINUE_FLAG=""
REBUILD=false
AGENT_NAME="flowchart_mapper"

while [[ $# -gt 0 ]]; do
    case $1 in
        --continue) CONTINUE_FLAG="--continue"; shift ;;
        --rebuild) REBUILD=true; shift ;;
        --agent) AGENT_NAME="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Ensure persistent directory exists
mkdir -p ~/.claude-docker/claude-home

# Build if needed
if ! docker images | grep -q "islamic-text-claude" || [ "$REBUILD" = true ]; then
    cp ~/.claude.json .claude.json
    docker build -t islamic-text-claude:latest .
    rm .claude.json
fi

# Run container
docker run -it --rm \
    -v "$(pwd):/workspace" \
    -v "$HOME/.claude-docker/claude-home:/home/claude/.claude:rw" \
    -e CLAUDE_CONTINUE_FLAG="$CONTINUE_FLAG" \
    -e AGENT_NAME="$AGENT_NAME" \
    islamic-text-claude:latest "$@"
```

---

## 🎯 **Success Metrics**

### **Technical Metrics**
- **Authentication Success Rate**: 100% (vs current ~0%)
- **Session Persistence**: Conversations resume across container restarts
- **Configuration Persistence**: Agent settings survive container rebuilds
- **Startup Time**: <30 seconds (vs current timeout failures)

### **Operational Metrics**
- **Developer Experience**: Single command to start any agent
- **Maintenance**: No complex jq operations or Python dependencies
- **Scalability**: Easy to add new agents or MCP servers
- **Security**: No API keys in environment variables

---

## 🔚 **Conclusion**

The claude-docker repository provides a **battle-tested, production-ready pattern** for containerizing Claude Code CLI. Their approach solves all the authentication and session management issues we've encountered.

**Key Takeaway**: We should abandon our current complex approach and adopt their proven patterns. The authentication issue we're debugging is fundamentally an architectural problem that their design solves elegantly.

**Recommendation**: Implement Phase 1 immediately to resolve authentication issues, then proceed with Phase 2 for enhanced capabilities.

---

**Sources**:
- [claude-docker Repository](https://github.com/VishalJ99/claude-docker)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [MCP Documentation](https://modelcontextprotocol.io/)