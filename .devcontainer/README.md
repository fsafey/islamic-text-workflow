# Islamic Text Workflow Dev Container

## 🚀 Minimal Fast-Startup Development Environment

This dev container is optimized for fast startup with on-demand package installation.

### Essential Commands
- `ws` - Go to workspace
- `pkg <package-set>` - Install packages as needed

### Package Installation Options
```bash
pkg claude           # Install Claude Code
pkg dev-tools        # Install vim, nano, git tools
pkg python-dev       # Install pytest, jupyter, black
pkg graphiti         # Install Graphiti dependencies
pkg all              # Install everything
```

### Project Commands (when tools are installed)
- `gr "text"` - Remember in knowledge graph
- `gs "query"` - Search knowledge graph  
- `gt "/path/file"` - Analyze text file
- `gst` - Show system status

### Claude Docker Commands (when available)
- `claude2` - Interactive Claude instance
- Uses existing Claude Docker API at http://localhost:8000

### Development Philosophy
- **Fast Startup**: Minimal base image loads quickly
- **Install on Demand**: Only install what you need, when you need it
- **Persistent Storage**: Installed packages persist across container rebuilds
- **Efficient Development**: No waiting for unnecessary dependencies

### Project Structure
- `/workspace` - Project root
- `/workspace/graphiti-main` - Graphiti framework
- `/workspace/documentation` - Project documentation
- `/workspace/tools/scripts` - Development scripts

### Quick Start
1. Container starts immediately with minimal dependencies
2. Install needed packages: `pkg dev-tools python-dev`
3. Load project commands: `source tools/scripts/graphiti-commands.sh`
4. Begin development with fast, responsive environment

**Philosophy**: Start fast, install what you need, stay productive! 🕌