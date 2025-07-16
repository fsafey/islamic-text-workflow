# Interactive Claude Docker Usage Guide

## 🚀 Quick Start - Second Claude Instance

You now have a **second Claude CLI instance** available through Claude Docker that you can use for parallel work, specialized tasks, or isolation.

### ⚡ Instant Launch

```bash
# Launch interactive Claude Docker (alias added to your shell)
claude2
```

## 🎯 Available Modes

### 1. **Interactive Shell Mode** - Full Claude CLI Access
```bash
claude2
# Select option 1
```

**What you get:**
- Complete Claude CLI environment
- Access to all your project files at `/workspace/islamic-text-workflow`
- Isolated from your main Claude Code session
- Can run `claude "Your prompt here"` commands
- Full bash shell with your project mounted

**Use cases:**
- Parallel development work
- Testing different approaches
- Isolated experimentation
- Long-running analysis tasks

### 2. **Graphiti Worker Mode** - Knowledge Graph Processing
```bash
claude2
# Select option 2
```

**What you get:**
- JSON API processing for knowledge graphs
- Direct Graphiti entity extraction
- Real-time knowledge graph building

**Example usage:**
```json
{"operation":"add_episode","params":{"episode_body":"Your Islamic text here"}}
```

### 3. **Islamic Text Analysis Mode** - NLP Specialization
```bash
claude2
# Select option 3
```

**What you get:**
- Specialized Arabic text processing
- Hadith and Quranic analysis optimization
- Islamic entity extraction (scholars, places, concepts)
- Temporal tracking of Islamic scholarship

### 4. **Software Engineering Mode** - Code Analysis
```bash
claude2
# Select option 4
```

**What you get:**
- Code entity extraction
- Architecture analysis
- API relationship mapping
- Development pattern recognition

## 💡 Practical Examples

### Example 1: Parallel Development
**Main Claude Code session:** Working on feature implementation
**Claude Docker instance:** Testing and experimenting with different approaches

```bash
# Terminal 1 (your current Claude Code session)
# Continue your normal work

# Terminal 2 
claude2  # Select Interactive Shell
# Now you have a second Claude instance for testing
claude "Help me refactor this Islamic text processing function"
```

### Example 2: Knowledge Graph Building
```bash
claude2  # Select Graphiti Worker Mode
# Feed Islamic texts for analysis:
{"operation":"add_episode","params":{"episode_body":"Abu Bakr (RA) was the first Caliph of Islam"}}
```

### Example 3: Research Analysis
```bash
claude2  # Select Islamic Text Analysis Mode
# Specialized for Islamic scholarship
{"operation":"add_episode","params":{"episode_body":"Ibn Sina wrote extensive commentaries on Aristotelian philosophy"}}
```

## 🔧 Technical Details

### Container Features
- **Authentication**: Uses your existing Claude Docker authentication
- **Project Access**: Full read/write access to your Islamic Text Workflow project
- **Isolation**: Separate container instance from API server
- **Networking**: Host network access for database connections
- **Persistence**: Changes to project files are persistent

### Container Specifications
```yaml
# Volumes mounted:
- ~/.claude-docker/claude-home:/home/claude-user/.claude:rw
- ~/.claude-docker/ssh:/home/claude-user/.ssh:rw  
- /Users/farieds/Project/islamic-text-workflow:/workspace/islamic-text-workflow:rw

# Working directory: /workspace/islamic-text-workflow
# Network: Host network (for Neo4j access)
# Name: claude-interactive-{timestamp}
```

## 🎯 Use Cases

### Development Workflows
1. **Main Session**: Feature development and debugging
2. **Claude Docker**: Testing, experimentation, code review

### Research Workflows  
1. **Main Session**: Document writing and coordination
2. **Claude Docker**: Text analysis and knowledge graph building

### Islamic Text Analysis
1. **Main Session**: Academic research and documentation
2. **Claude Docker**: Specialized Arabic NLP and entity extraction

### Team Collaboration
1. **Share containers**: Multiple team members can use the same approach
2. **Consistent environment**: Same Claude Docker setup across machines
3. **Isolated workspaces**: Each container is independent

## 🚀 Advanced Usage

### Background Processing
```bash
# Start a background Graphiti worker
nohup claude2 &  # Select Graphiti mode
# Process texts while continuing other work
```

### Scripted Automation
```bash
# Automate Claude Docker for batch processing
echo '2' | claude2  # Auto-select Graphiti mode
```

### Multiple Instances
```bash
# You can run multiple Claude Docker instances simultaneously
# Each gets a unique container name with timestamp
```

## 🔒 Security & Isolation

**Benefits:**
- **Isolated Processing**: Second instance won't interfere with main work
- **Separate Authentication**: Uses same auth but separate container
- **File Safety**: Project files are mounted, but container is disposable
- **Network Isolation**: Can be configured for different network access

**Considerations:**
- Both instances use the same Claude authentication
- Project files are shared between instances
- Docker containers are ephemeral (restart fresh each time)

## 📊 Monitoring & Logs

### Container Status
```bash
docker ps | grep claude-interactive
docker ps | grep claude-graphiti
```

### Logs
```bash
docker logs claude-interactive-{timestamp}
```

### Resource Usage
```bash
docker stats $(docker ps -q --filter name=claude-)
```

## 🎉 Ready to Use!

Your interactive Claude Docker setup is now complete:

1. **Run `claude2`** in any terminal
2. **Choose your mode** (1-4)
3. **Start working** in your second Claude instance
4. **Exit** when done (container automatically cleans up)

**Perfect for:**
- Parallel Islamic text research
- Knowledge graph experimentation  
- Isolated development testing
- Specialized NLP processing

You now have the power of **multiple Claude instances** working together on your Islamic Text Workflow project! 🚀🕌