# Claude Instance Configurations

This directory contains instance-specific CLAUDE.md configurations for different Docker modes, enabling specialized behavior while maintaining consistency.

## 🏗️ Architecture

### Configuration Hierarchy
```
claude-configs/
├── base.md                    # Base configuration (shared instructions)
├── interactive.md             # Interactive shell mode specialization
├── graphiti-worker.md         # Graphiti worker mode specialization  
├── islamic-nlp.md             # Islamic NLP mode specialization
├── software-engineering.md    # Software engineering mode specialization
└── README.md                  # This file
```

### Inheritance Model
Each specialized configuration:
1. **References** the base configuration for common instructions
2. **Extends** with mode-specific capabilities and guidelines
3. **Overrides** base settings when necessary for specialization

## 🎯 Instance Types

### 1. Interactive Shell (`interactive.md`)
- **Purpose**: Full Claude Code environment for development
- **Features**: Code editing, analysis, knowledge graph integration
- **Use Cases**: Parallel development, testing, experimentation
- **Conversation**: Shared with primary Claude session

### 2. Graphiti Worker (`graphiti-worker.md`) 
- **Purpose**: JSON API processor for knowledge graphs
- **Features**: Entity extraction, relationship mapping, batch processing
- **Use Cases**: Text analysis pipelines, automated knowledge building
- **Interface**: stdin/stdout JSON protocol

### 3. Islamic NLP (`islamic-nlp.md`)
- **Purpose**: Specialized Arabic text and Islamic scholarship analysis
- **Features**: Hadith analysis, Quranic studies, Arabic NLP
- **Use Cases**: Academic research, manuscript analysis, scholarly networks
- **Expertise**: Islamic texts, Arabic language, historical contexts

### 4. Software Engineering (`software-engineering.md`)
- **Purpose**: Code analysis and development task automation
- **Features**: Architecture review, code quality, security analysis
- **Use Cases**: Code review, refactoring, technical documentation
- **Expertise**: Multiple languages, frameworks, best practices

## 🔧 Dynamic Configuration System

### How It Works
```bash
# Script automatically selects appropriate CLAUDE.md based on mode
case $mode in
    1) CLAUDE_CONFIG="interactive.md" ;;
    2) CLAUDE_CONFIG="graphiti-worker.md" ;;
    3) CLAUDE_CONFIG="islamic-nlp.md" ;;
    4) CLAUDE_CONFIG="software-engineering.md" ;;
esac

# Mount the specific configuration into container
-v "$PROJECT_ROOT/claude-configs/$CLAUDE_CONFIG:/home/claude-user/.claude/CLAUDE.md:ro"
```

### Fallback Strategy
- **Primary**: Use instance-specific configuration file
- **Fallback**: Use `base.md` if specific configuration doesn't exist
- **Error Handling**: Graceful degradation to base functionality

## ✨ Benefits

### ✅ **Instance Specialization**
- Each mode gets tailored instructions and capabilities
- Specialized entity types and processing workflows
- Mode-appropriate tools and integrations

### ✅ **Consistency**
- Base configuration ensures common functionality
- Shared project context and commands
- Unified approach to knowledge graph integration

### ✅ **Maintainability** 
- Version controlled configurations
- Easy to update and modify
- Clear separation of concerns

### ✅ **Flexibility**
- Easy to add new modes by creating new configurations
- Override base settings for specific requirements
- Mix and match capabilities as needed

## 🚀 Usage Examples

### Creating a New Instance Type
1. Create new configuration file: `claude-configs/my-mode.md`
2. Reference base configuration: `📖 **Base Configuration**: See [base.md](base.md)`
3. Add specialized instructions for your use case
4. Update script to use new configuration

### Updating Configurations
```bash
# Edit base configuration (affects all instances)
nano claude-configs/base.md

# Edit specific instance configuration  
nano claude-configs/interactive.md

# Changes take effect on next container start
claude2  # Select your mode
```

### Testing Configurations
```bash
# Test if configuration files exist
ls -la claude-configs/

# View mounted configuration in container
docker exec -it <container-name> cat /home/claude-user/.claude/CLAUDE.md
```

## 🎯 Best Practices

### Configuration Design
- **Inherit from base**: Always reference base.md for common instructions
- **Be specific**: Include detailed, actionable instructions for the mode
- **Document clearly**: Explain capabilities and use cases
- **Maintain consistency**: Follow established patterns and naming

### Updating Process
- **Test changes**: Verify configurations work as expected
- **Document updates**: Note significant changes and rationale
- **Version control**: Track all configuration changes in git
- **Coordinate changes**: Ensure updates don't break existing workflows

This system provides the most elegant and reliable solution for instance-specific Claude configurations while maintaining adaptability and ease of management.