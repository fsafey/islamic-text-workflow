# Project Navigation Guide

## 🗂️ Quick File Location Reference

### Essential Files
- **Main README**: `README.md` - Project overview and setup
- **Environment Config**: `infrastructure/configs/.env` - API keys and settings  
- **Installation Script**: `tools/scripts/install.sh` - Setup automation
- **Coordination Monitor**: `infrastructure/coordination/monitor.sh` - Multi-agent status

### Research Workflow
- **Analysis Results**: `research/analysis/` - Current research outputs
- **Methodology**: `research/methodology/` - Academic frameworks
- **Templates**: `research/templates/` - Standardized analysis formats
- **Generated Output**: `research/output/` - Final research products

### Infrastructure Management
- **Claude Docker**: `infrastructure/claude-docker/` - Container setup and MCP config
- **Coordination System**: `infrastructure/coordination/` - Multi-agent communication
- **Configuration Files**: `infrastructure/configs/` - Environment and settings

### Tools and Automation
- **Scripts**: `tools/scripts/` - Installation and deployment tools
- **Automation**: `tools/automation/` - Automated research workflows
- **Utilities**: `tools/utilities/` - Helper scripts and tools

### Documentation
- **User Guides**: `documentation/guides/` - Tutorials and quick starts
- **API Docs**: `documentation/api/` - Technical documentation
- **Academic Methodology**: `documentation/academic/` - Research standards

### Archive and History
- **Legacy Files**: `archive/legacy/` - Historical project files
- **Demo Projects**: `archive/demos/` - Example workflows and tutorials
- **Backups**: `archive/backups/` - Backup files and archives

## 🚀 Common Tasks and File Locations

### Setup and Installation
```bash
# Configure environment
cp infrastructure/configs/.env.example infrastructure/configs/.env
# Edit infrastructure/configs/.env

# Install system
./tools/scripts/install.sh

# Start Claude Docker
claude-docker
```

### Research Operations
```bash
# Monitor multi-agent coordination
./infrastructure/coordination/monitor.sh

# Check research results
ls research/analysis/

# View recent academic analysis
cat research/analysis/academic_analysis_report.md
```

### Configuration Updates
```bash
# Update MCP servers
nano infrastructure/claude-docker/mcp-servers.txt

# Modify environment settings
nano infrastructure/configs/.env

# Rebuild after config changes
claude-docker --rebuild
```

### Documentation Access
```bash
# Quick start guide
cat documentation/guides/QUICK_START_DEMO.md

# Coordination system help
cat infrastructure/coordination/README.md

# MCP server configuration
cat infrastructure/claude-docker/MCP_SERVERS.md
```

## 🔍 Finding Specific Content

### Research Content
- **Recent Analysis**: `research/analysis/academic_analysis_report.md`
- **Data Patterns**: `research/analysis/analysis_patterns.json`
- **Methodology Docs**: `research/methodology/` (when created)

### Technical Setup
- **Docker Configuration**: `infrastructure/claude-docker/Dockerfile`
- **MCP Server List**: `infrastructure/claude-docker/mcp-servers.txt`
- **Installation Logic**: `tools/scripts/install.sh`

### Coordination System
- **Task Inbox**: `infrastructure/coordination/inbox/`
- **Results Outbox**: `infrastructure/coordination/outbox/`
- **Status Monitoring**: `infrastructure/coordination/status/`
- **Activity Logs**: `infrastructure/coordination/logs/`

### Demo and Examples
- **Islamic Text Demos**: `archive/demos/islamic-text-demos/`
- **Generic Examples**: `archive/demos/` (web-scraper, code-analyzer, etc.)
- **Demo Instructions**: `archive/demos/DEMO_GUIDE.md`

## 📁 Directory Purpose Summary

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `research/` | Core academic research activities | `analysis/`, `methodology/`, `templates/` |
| `infrastructure/` | Technical platform components | `claude-docker/`, `coordination/`, `configs/` |
| `documentation/` | Project documentation | `guides/`, `api/`, `academic/` |
| `tools/` | Automation and utilities | `scripts/`, `automation/`, `utilities/` |
| `archive/` | Historical and reference materials | `legacy/`, `demos/`, `backups/` |

## 🎯 Project Navigation Tips

1. **Start with README.md** for project overview
2. **Use PROJECT_NAVIGATION.md** (this file) for quick file location
3. **Check `infrastructure/coordination/monitor.sh`** for system status
4. **Browse `research/analysis/`** for recent research outputs
5. **Refer to `documentation/guides/`** for detailed tutorials
6. **Explore `archive/demos/`** for practical examples

This organization supports scalable academic research while maintaining clear separation between research content, technical infrastructure, and supporting materials.