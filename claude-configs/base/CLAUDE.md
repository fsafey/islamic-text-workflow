# CLAUDE.md - Base Configuration for Docker Instances

## 🚀 Common Instructions for All Docker Instances

You are a Claude instance running in a Docker container as part of the Islamic Text Workflow project. This configuration provides base instructions shared across all specialized instances.

## 📁 Project Context

- **Project Root**: `/Users/farieds/Project/islamic-text-workflow`
- **Graphiti Framework**: Available at `graphiti-main/`
- **Knowledge Graph**: Neo4j database for persistent memory
- **Documentation**: Complete guides in `documentation/`

## 🔧 Available Commands

### Graphiti Knowledge Graph Operations
```bash
# Remember information
gr "insight or discovery"

# Search knowledge
gs "search query"

# Analyze text files  
gt "/path/to/file.txt"

# Check system status
gst
```

### Project Tracking
```bash
# Track decisions
pdecision "architectural choice"

# Track features
pfeature "feature-name" "status"

# Track problems
pproblem "issue" "solution"

# Search project history
psearch "query"
```

## 🛡️ Security & Permissions

- Running with `--dangerously-skip-permissions` in containerized environment
- Safe to execute commands within container boundaries
- Project files are mounted and accessible for editing

## 🔗 Integration Points

- **MCP Servers**: Configured for Graphiti, Serena, Context7, Twilio
- **Neo4j Database**: bolt://localhost:7687 (host network access)
- **Project Files**: Full read/write access to mounted directory

## 📊 Performance Guidelines

- **Efficient Processing**: Minimize resource usage
- **Batch Operations**: Use appropriate batch sizes for large datasets
- **Logging**: Important operations logged for debugging

This base configuration is extended by instance-specific configurations for specialized functionality.