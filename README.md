# Islamic Text Workflow - AI-Powered Academic Research Platform

A complete AI-powered research platform for Islamic text analysis, built on Claude Docker with autonomous academic workflows, **Graphiti temporal knowledge graphs**, and **multiple parallel Claude instances** for advanced research coordination.

📋 **MCP Setup Guide**: See [infrastructure/claude-docker/MCP_SERVERS.md](infrastructure/claude-docker/MCP_SERVERS.md) for customizing or adding more MCP servers

## 🧠 **NEW: Graphiti Knowledge Graph Integration**

This project now includes **complete Graphiti temporal knowledge graph capabilities** with Claude Docker integration:

### ⚡ **Quick Commands**
```bash
# Knowledge graph operations (available in all terminals)
gr "Store Islamic text insights"        # Remember information
gs "search for concepts"                # Search knowledge graph  
gt "file.txt"                          # Analyze text files

# Project development tracking
pstart "session-name"                   # Start work session
pdecision "architectural choice"        # Track decisions
pfeature "feature-name" "status"       # Track features
psearch "query"                        # Search project history
poverview                              # Project overview

# Launch second Claude Docker instance
claude2                                # Interactive second Claude instance
```

### 🎯 **Key Features**
- **🧠 Temporal Knowledge Graphs**: Track Islamic scholarship evolution over time
- **🔍 Hybrid Search**: Semantic + keyword + graph traversal search
- **🤖 Local Processing**: Zero external API costs via Claude Docker
- **📊 Project Intelligence**: Persistent memory of development decisions
- **🕌 Islamic Text Specialization**: Arabic NLP and Islamic entity extraction
- **🔄 Multiple Claude Instances**: Parallel processing and specialized tasks

### 📚 **Complete Documentation**

#### Essential Guides (Start Here)
- **[CLAUDE.md](CLAUDE.md)** - 🎯 **Main reference for all commands and workflows**
- **[Project Tracking Guide](documentation/guides/PROJECT_TRACKING_WITH_GRAPHITI.md)** - Development intelligence system  
- **[Graphiti Workflow Commands](documentation/guides/GRAPHITI_WORKFLOW_COMMANDS.md)** - Complete command reference
- **[Interactive Claude Docker](documentation/guides/CLAUDE_DOCKER_INTERACTIVE_USAGE.md)** - Multiple instance usage

#### Technical Architecture  
- **[Graphiti Integration Details](graphiti-main/claude_docker/README.md)** - Local processing architecture
- **[Graphiti Core Framework](graphiti-main/CLAUDE.md)** - Framework development commands
- **[MCP Server Configuration](infrastructure/claude-docker/MCP_SERVERS.md)** - Protocol setup
- **[Coordination System](infrastructure/coordination/README.md)** - Multi-agent communication

### 🔗 **Integration Reference**
This comprehensive integration was developed through detailed conversation and implementation. For the complete setup process, troubleshooting, and advanced usage patterns, refer to the implementation conversation that covers:
- ✅ **Complete Graphiti framework integration** (120,854+ lines of code)
- ✅ **Claude Docker local processing setup** (zero external API costs)
- ✅ **Multiple Claude instance configuration** (`claude2` command)
- ✅ **Project development tracking system** (sessions, decisions, features)
- ✅ **Islamic text analysis specialization** (Arabic NLP, temporal entities)
- ✅ **Knowledge graph command interface** (gr, gs, gt shortcuts)

The conversation demonstrates practical usage, troubleshooting steps, and real-world implementation details for all features.

## 🏗️ Project Structure

```
islamic-text-workflow/
├── graphiti-main/              # 🧠 Complete Graphiti knowledge graph framework
│   ├── graphiti_core/          # Core temporal knowledge graph library
│   ├── claude_docker/          # Claude Docker integration for local processing
│   ├── mcp_server/             # Model Context Protocol server
│   ├── server/                 # FastAPI REST service
│   └── tests/                  # Comprehensive test suite
├── research/                    # Core research activities
│   ├── analysis/               # Analysis results and reports
│   ├── methodology/            # Research methodologies
│   ├── templates/              # Analysis templates
│   └── output/                 # Generated research outputs (includes knowledge exports)
├── infrastructure/             # Technical infrastructure
│   ├── claude-docker/          # Claude Docker setup and configuration
│   ├── coordination/           # Multi-agent coordination system
│   └── configs/                # Environment and MCP configurations
├── documentation/              # Project documentation
│   ├── guides/                 # User guides and tutorials (includes Graphiti docs)
│   ├── api/                    # API documentation
│   └── academic/               # Academic methodology documentation
├── tools/                      # Automation and utilities
│   ├── scripts/                # Shell commands (gr, gs, pstart, claude2, etc.)
│   ├── automation/             # Automated research workflows
│   └── utilities/              # Helper tools and scripts
├── alias*.csv                  # Islamic text datasets (199 entries)
└── archive/                    # Historical and reference materials
    ├── legacy/                 # Legacy files and configurations
    ├── demos/                  # Demo projects and examples
    └── backups/                # Backup files and archives
```

## 🚀 AI Coding Agent Starter Pack

This is a complete starter pack for autonomous AI development with **optimized dev container support**.

## What This Does
- **Complete AI coding agent setup** with Claude Code in an isolated Docker container
- **Optimized Dev Container** - Fast-startup minimal environment with on-demand package installation
- **Pre-configured MCP servers** for maximum coding productivity:
  - **Serena** - Advanced coding agent toolkit with project indexing and symbol manipulation
  - **Context7** - Pulls up-to-date, version-specific documentation and code examples straight from the source into your prompt
  - **Twilio** - SMS notifications when long-running tasks complete (perfect for >10min jobs)
- **Persistent conversation history** - Resumes from where you left off, even after crashes
- **Remote work notifications** - Get pinged via SMS when tasks finish, so you can step away from your monitor
- **Simple one-command setup and usage** - Zero friction set up for plug and play integration with existing cc workflows.
- **Fully customizable** - Modify the can modify the files at `~/.claude-docker` for custom slash commands, settings and claude.md files.

## 🐳 Dev Container Quick Start

### Option 1: VS Code Dev Container (Recommended)
```bash
# 1. Open in VS Code
code .

# 2. Reopen in Container (Command Palette: "Reopen in Container")
# Container starts fast with minimal dependencies

# 3. Install packages as needed
pkg dev-tools python-dev graphiti

# 4. Load project commands
source tools/scripts/graphiti-commands.sh

# 5. Begin development
gr "Starting Islamic text research session"
```

### Option 2: Docker Compose
```bash
# Start dev container
docker-compose -f .devcontainer/docker-compose.yml up -d

# Attach to container
docker exec -it islamic-text-workflow-app-1 bash

# Install what you need
pkg all
```

### Dev Container Features
- **⚡ Fast Startup**: Minimal base image loads in seconds
- **📦 On-Demand Installation**: `pkg claude`, `pkg dev-tools`, `pkg python-dev`, `pkg graphiti`
- **💾 Persistent Storage**: Installed packages persist across rebuilds
- **🔄 Efficient Development**: No waiting for unnecessary dependencies
- **🕌 Islamic Text Workflow**: Full project functionality available

## Quick Start

### 1. Setup Islamic Text Research Platform
```bash
# 1. Configure environment
cp infrastructure/configs/.env.example infrastructure/configs/.env
nano infrastructure/configs/.env  # Add your API keys (Twilio, etc.)

# 2. Install Claude Docker
./tools/scripts/install.sh

# 3. Start autonomous research session
claude-docker

# 4. Begin Islamic text analysis
"Read research/methodology/ and analyze new Islamic texts using our established methodology"
```

### 2. Multi-Agent Coordination
```bash
# Monitor coordination between Claude instances
./infrastructure/coordination/monitor.sh

# Assign tasks to Docker instance
echo "Analyze academic methodology" > infrastructure/coordination/inbox/research-task.md
```

## Prerequisites

⚠️ **IMPORTANT**: Complete these steps BEFORE using claude-docker:

### 1. Claude Code Authentication (Required)
You must authenticate Claude Code on your host system first:
```bash
# Install Claude Code globally
npm install -g @anthropic-ai/claude-code

# Run and complete authentication
claude

# Verify authentication files exist
ls ~/.claude.json ~/.claude/
```

📖 **Full Claude Code Setup Guide**: https://docs.anthropic.com/en/docs/claude-code

### 2. Docker Installation (Required)
- **Docker Desktop**: https://docs.docker.com/get-docker/
- Ensure Docker daemon is running before proceeding

### 3. Git Configuration (Required)
Git configuration is automatically loaded from your host system during Docker build:
- Make sure you have configured git on your host system first:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```
- **Important**: Claude Docker will commit to your current branch - make sure you're on the correct branch before starting

### 4. SSH Keys for Git Push (Optional - for push/pull operations)
Claude Docker uses dedicated SSH keys (separate from your main SSH keys for security):

**Setup SSH keys:**
```bash
# 1. Create directory for Claude Docker SSH keys
mkdir -p ~/.claude-docker/ssh

# 2. Generate SSH key for Claude Docker
ssh-keygen -t rsa -b 4096 -f ~/.claude-docker/ssh/id_rsa -N ''

# 3. Add public key to GitHub
cat ~/.claude-docker/ssh/id_rsa.pub
# Copy output and add to: GitHub → Settings → SSH and GPG keys → New SSH key

# 4. Test connection
ssh -T git@github.com -i ~/.claude-docker/ssh/id_rsa
```

**Why separate SSH keys?**
- ✅ **Security Isolation**: Claude can't access or modify your personal SSH keys, config, or known_hosts
- ✅ **SSH State Persistence**: The SSH directory is mounted at runtime.
- ✅ **Easy Revocation**: Delete `~/.claude-docker/ssh/` to instantly revoke Claude's git access
- ✅ **Clean Audit Trail**: All Claude SSH activity is isolated and easily traceable

**Technical Note**: We mount the SSH directory rather than copying keys because SSH operations modify several files (`known_hosts`, connection state) that must persist between container sessions for a smooth user experience.

### 5. Twilio Account (Optional - for SMS notifications)
If you want SMS notifications when tasks complete:
- Create free trial account: https://www.twilio.com/docs/usage/tutorials/how-to-use-your-free-trial-account
- Get your Account SID and Auth Token from the Twilio Console
- Get a phone number for sending SMS

### Why Pre-authentication?
The Docker container needs your existing Claude authentication to function. This approach:
- ✅ Uses your existing Claude subscription/API access
- ✅ Maintains secure credential handling
- ✅ Enables persistent authentication across container restarts


### Environment Variables (infrastructure/configs/.env)
```bash
# SMS notifications (highly recommended for research workflows!)
# Perfect for long-running Islamic text analysis - step away and get notified when done
TWILIO_ACCOUNT_SID=your_twilio_sid  
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_FROM_NUMBER=+1234567890
TWILIO_TO_NUMBER=+0987654321

# Optional - Custom conda paths (for academic environments)
CONDA_PREFIX=/path/to/your/conda
CONDA_EXTRA_DIRS="/path/to/envs /path/to/pkgs"

# Optional - System packages for NLP and text processing
SYSTEM_PACKAGES="libopenslide0 libgdal-dev python3-dev"
```

⚠️ **Security Note**: Credentials are baked into the Docker image. Keep your image secure!

## 🎓 Academic Research Features

### Islamic Text Analysis
- **Automated Methodology**: AI applies consistent academic analysis frameworks
- **Multi-Agent Research**: Parallel Claude instances coordinate on complex research tasks
- **Quality Assurance**: Academic standards compliance and citation management
- **Scalable Processing**: Batch analysis of multiple Islamic texts simultaneously

### Research Coordination System
- **File-Based Communication**: Seamless task distribution between Claude instances
- **Progress Tracking**: Real-time monitoring of research activities
- **Result Integration**: Automated compilation of analysis results
- **Documentation Generation**: Publication-quality research documentation

### Expandable Architecture
- **Modular Design**: Add new analysis methods and research tools easily
- **Template System**: Standardized formats for consistent research output
- **Integration Ready**: Connect with external databases and research platforms
- **Version Control**: Track research evolution and methodology improvements

## Features

### 🤖 Full Autonomy
- Claude runs with `--dangerously-skip-permissions` for complete access
- Can read, write, execute, and modify any files in your project
- No permission prompts or restrictions

### 🔌 Modular MCP Server Support
- Easy installation of any MCP server through `infrastructure/claude-docker/mcp-servers.txt`
- Automatic environment variable handling for MCP servers requiring API keys
- Pre-configured servers optimized for academic research:
  - **Serena**: Advanced coding and text analysis toolkit
  - **Context7**: Up-to-date Islamic studies documentation
  - **Twilio**: SMS notifications for long-running research tasks
- See [infrastructure/claude-docker/MCP_SERVERS.md](infrastructure/claude-docker/MCP_SERVERS.md) for full setup guide

### 📱 SMS Notifications  
- Automatic SMS via Twilio when Claude completes tasks
- Configurable via MCP integration
- Optional - works without if Twilio not configured

### 🐍 Conda Integration
- Has access to your conda envs so do not need to add build instructions to the Dockerfile
- Supports custom conda installation directories (ideal for academic/lab environments where home is quota'd)


### 🔑 Persistence
- Login once, use forever - authentication tokens persist across sessions
- Automatic UID/GID mapping ensures perfect file permissions between host and container
- Loads history from previous chats in a given project.

### 📝 Task Execution Logging  
- Prompt engineered to generate `task_log.md` documenting agent's execution process
- Stores assumptions, insights, and challenges encountered
- Acts as a simple summary to quickly understand what the agent accomplished

### 🐳 Clean Environment
- Each session runs in fresh Docker container
- Only current working directory mounted (along with conda directories specified in `.env`).


## Configuration
During build, the `.env` file from `infrastructure/configs/` is baked into the image:
- Credentials are embedded at `/app/.env` inside the container
- No need to manage .env files in each project
- The image contains everything needed to run
- **Important**: After updating `infrastructure/configs/.env`, you must rebuild the image with `claude-docker --rebuild`

The setup creates `~/.claude-docker/` in your home directory with:
- `claude-home/` - Persistent Claude authentication and settings
- `ssh/` - Directory where claude-dockers private ssh key and known hosts file is stored.

### Multi-Agent Coordination
The `infrastructure/coordination/` system enables communication between parallel Claude instances:
- `inbox/` - Task assignments for Docker instance
- `outbox/` - Results and progress updates  
- `status/` - Real-time coordination status
- `logs/` - Communication history and debugging

### Template Configuration Copy
During installation (`install.sh`), all contents from the project's `.claude/` directory are copied to `~/.claude-docker/claude-home/` as template/base settings. This includes:
- `settings.json` - Default Claude Code settings with MCP configuration
- `CLAUDE.md` - Default instructions and protocols  
- `commands/` - Slash commands (if any)
- Any other configuration files

**To modify these settings:**
- **Recommended**: Directly edit files in `~/.claude-docker/claude-home/`
- **Alternative**: Modify `.claude/` in this repository and re-run `install.sh`

All changes to `~/.claude-docker/claude-home/` persist across container sessions.

Each project gets:
- `.claude/settings.json` - Claude Code settings with MCP
- `.claude/CLAUDE.md` - Project-specific instructions (if you create one)

## Command Line Flags

Claude Docker supports several command-line flags for different use cases:

### Basic Usage
```bash
claude-docker                    # Start Claude in current directory
claude-docker --continue         # Resume previous conversation in this directory
claude-docker --rebuild          # Force rebuild Docker image
claude-docker --rebuild --no-cache  # Rebuild without using Docker cache
```

### Available Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--continue` | Resume the previous conversation in current directory | `claude-docker --continue` |
| `--rebuild` | Force rebuild of the Docker image | `claude-docker --rebuild` |
| `--no-cache` | When rebuilding, don't use Docker cache | `claude-docker --rebuild --no-cache` |
| `--memory` | Set container memory limit | `claude-docker --memory 8g` |
| `--gpus` | Enable GPU access (requires nvidia-docker) | `claude-docker --gpus all` |

### Environment Variables
You can also set defaults in your `.env` file:
```bash
DOCKER_MEMORY_LIMIT=8g          # Default memory limit
DOCKER_GPU_ACCESS=all           # Default GPU access
```

### Examples
```bash
# Resume work with 16GB memory limit
claude-docker --continue --memory 16g

# Rebuild after updating .env file
claude-docker --rebuild

# Use GPU for ML tasks
claude-docker --gpus all
```

### Rebuilding the Image

The Docker image is built only once when you first run `claude-docker`. To force a rebuild:

```bash
# Force rebuild (uses cache)
claude-docker --rebuild

# Force rebuild without cache
claude-docker --rebuild --no-cache
```

Rebuild when you:
- Update your .env file with new credentials
- Update the Claude Docker repository
- Change system packages in .env

### Conda Configuration

For custom conda installations (common in academic/lab environments), add these to your `.env` file:

```bash
# Main conda installation
CONDA_PREFIX=/vol/lab/username/miniconda3

# Additional conda directories (space-separated)
CONDA_EXTRA_DIRS="/vol/lab/username/.conda/envs /vol/lab/username/conda_envs /vol/lab/username/.conda/pkgs /vol/lab/username/conda_pkgs"
```

**How it works:**
- `CONDA_PREFIX`: Mounts your conda installation to the same path in container
- `CONDA_EXTRA_DIRS`: Mounts additional directories and automatically configures conda

**Automatic Detection:**
- Paths containing `*env*` → Added to `CONDA_ENVS_DIRS` (conda environment search)
- Paths containing `*pkg*` → Added to `CONDA_PKGS_DIRS` (package cache search)

**Result:** All your conda environments and packages work exactly as they do on your host system.

### System Package Installation

For scientific computing packages that require system libraries, add them to your `.env` file:

```bash
# Install OpenSlide for medical imaging
SYSTEM_PACKAGES="libopenslide0"

# Install multiple packages (space-separated)
SYSTEM_PACKAGES="libopenslide0 libgdal-dev libproj-dev libopencv-dev"
```

**Note:** Adding system packages requires rebuilding the Docker image (`docker rmi claude-docker:latest`).
## How This Differs from Anthropic's DevContainer

We provide a different approach than [Anthropic's official .devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer), optimized for autonomous task execution:


### Feature Comparison

| Feature | claude-docker | Anthropic's DevContainer |
|---------|--------------|-------------------------|
| **IDE Support** | Any editor/IDE | VSCode-specific |
| **Authentication** | Once per machine, persists forever | Per-devcontainer setup |
| **Conda Environments** | Direct access to all host envs | Manual setup in Dockerfile |
| **Prompt Engineering** | Optimized CLAUDE.md for tasks | Standard behavior |
| **Network Access** | Full access (firewall coming soon) | Configurable firewall |
| **SMS Notifications** | Built-in Twilio MCP | Not available |
| **Permissions** | Auto (--dangerously-skip-permissions) | Auto (--dangerously-skip-permissions) |


**Note**: Network firewall functionality similar to Anthropic's implementation is our next planned feature.

## Next Steps

**Phase 2 - Security Enhancements:**
- Network firewall to whitelist specific domains (similar to Anthropic's DevContainer)
- Shell history persistence between sessions
- Additional security features

## Attribution & Dependencies

### Core Dependencies
- **Claude Code**: Anthropic's official CLI - https://github.com/anthropics/claude-code
- **Twilio MCP Server**: SMS integration by @yiyang.1i - https://github.com/yiyang1i/sms-mcp-server
- **Docker**: Container runtime - https://www.docker.com/

### Inspiration & References
- Anthropic's DevContainer implementation: https://github.com/anthropics/claude-code/tree/main/.devcontainer
- MCP (Model Context Protocol): https://modelcontextprotocol.io/

### Islamic Text Workflow Extensions
- **Academic Research Platform**: Built on claude-docker foundation
- **Multi-Agent Coordination**: Custom file-based communication system
- **Research Templates**: Islamic studies methodology integration
- **Expandable Architecture**: Modular design for research scalability

## 📊 Current Research Output

- **[Academic Analysis Report](research/analysis/academic_analysis_report.md)** - Recent Islamic text analysis insights
- **[Analysis Patterns](research/analysis/analysis_patterns.json)** - Structured research findings
- **[Improvement Suggestions](research/analysis/improvement_suggestions.md)** - Methodology enhancements

## 📖 Documentation Structure

- **[Quick Start Demo](documentation/guides/QUICK_START_DEMO.md)** - Demo tutorials and examples
- **[Coordination System](infrastructure/coordination/README.md)** - Multi-agent setup guide
- **[Claude Docker Setup](infrastructure/claude-docker/MCP_SERVERS.md)** - Container configuration
- **[Demo Projects](archive/demos/)** - Example research workflows

## License

This project is open source. See the LICENSE file for details.

---

**Islamic Text Workflow** - Advancing Islamic studies through AI-powered research platforms built on Claude Docker infrastructure.