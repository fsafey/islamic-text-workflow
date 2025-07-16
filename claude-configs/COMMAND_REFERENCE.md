# Claude Docker Commands Reference

## 🚀 Direct Claude Access Commands

### **`claude2`** - Interactive Development Instance
- **Purpose**: Full Claude Code environment for development and analysis
- **Configuration**: `claude-configs/interactive/CLAUDE.md`
- **Usage**: `claude2` → Starts Claude directly, no menus
- **Features**: 
  - Code editing and analysis
  - Shared conversations with primary Claude
  - All Claude Code tools available
  - Project tracking commands (gr, gs, gt, etc.)

### **`claude-graphiti`** - Knowledge Graph Worker
- **Purpose**: JSON API processor for knowledge graph operations
- **Configuration**: `claude-configs/graphiti-worker/CLAUDE.md`
- **Usage**: `claude-graphiti` → Starts JSON worker mode
- **Features**:
  - Entity extraction from text
  - Knowledge graph building
  - Batch processing capabilities
  - Islamic text specialization

### **`claude-islamic`** - Islamic NLP Specialist
- **Purpose**: Arabic text processing and Islamic scholarship analysis
- **Configuration**: `claude-configs/islamic-nlp/CLAUDE.md`
- **Usage**: `claude-islamic` → Starts specialized NLP mode
- **Features**:
  - Hadith chain analysis
  - Quranic cross-references
  - Arabic language processing
  - Scholarly network mapping

### **`claude-engineering`** - Software Engineering Expert
- **Purpose**: Code analysis, architecture review, development tasks
- **Configuration**: `claude-configs/software-engineering/CLAUDE.md`
- **Usage**: `claude-engineering` → Starts engineering mode
- **Features**:
  - Code quality assessment
  - Architecture analysis
  - Security review
  - Performance optimization

## 🎯 Usage Examples

```bash
# Start second Claude instance for parallel development
claude2

# Analyze Islamic texts with specialized NLP
claude-islamic

# Process code for knowledge graph analysis
claude-engineering

# Build knowledge graphs from text data
claude-graphiti
```

## 🔧 Configuration Management

### Edit Instance Configurations
```bash
# Edit interactive mode configuration
nano claude-configs/interactive/CLAUDE.md

# Edit Islamic NLP configuration  
nano claude-configs/islamic-nlp/CLAUDE.md

# Edit base configuration (affects all modes)
nano claude-configs/base/CLAUDE.md
```

### Reload Aliases
```bash
# After editing configurations, reload aliases
source ~/.zshrc

# Or reload project commands
source tools/scripts/graphiti-commands.sh
```

## 📊 Instance Comparison

| Command | Purpose | Interface | Configuration |
|---------|---------|-----------|---------------|
| `claude2` | Development | Interactive Claude Code | interactive/CLAUDE.md |
| `claude-graphiti` | Knowledge graphs | JSON API | graphiti-worker/CLAUDE.md |
| `claude-islamic` | Islamic NLP | JSON worker | islamic-nlp/CLAUDE.md |
| `claude-engineering` | Code analysis | JSON worker | software-engineering/CLAUDE.md |

## 🚀 Quick Start

1. **Interactive Development**: `claude2` (most common use case)
2. **Text Analysis**: `claude-islamic` for Islamic texts
3. **Code Review**: `claude-engineering` for software projects
4. **Data Processing**: `claude-graphiti` for knowledge graph building

All commands start immediately without menus or configuration prompts!