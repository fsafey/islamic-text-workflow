# CLAUDE.md - Islamic Text Workflow Project

This file provides guidance to Claude Code when working with the Islamic Text Workflow project - a comprehensive AI-powered platform for Islamic text research with Graphiti temporal knowledge graphs and multiple Claude Docker instances.

## 🎯 Project Overview

The Islamic Text Workflow is a production-ready research platform that combines:
- **Temporal Knowledge Graphs** (Graphiti framework - 120,854+ lines)
- **Local Claude Docker Processing** (zero external API costs)
- **Islamic Text Analysis Specialization** (Arabic NLP, hadith, Quranic analysis)
- **Multiple Claude Instances** for parallel processing and research coordination
- **Academic Research Workflows** with persistent project intelligence

## 🚀 Quick Start Commands

### Knowledge Graph Operations
```bash
# Remember information in knowledge graph
gr "Islamic text insights or project notes"

# Search knowledge graph
gs "search query for concepts or decisions" 

# Analyze text files
gt "/path/to/islamic_text.txt"

# Check system status
gst  # Shows Neo4j and Claude Docker API status
```

### Project Development Tracking
```bash
# Start work session
pstart "session-name"

# End session with summary
pend "what was accomplished"

# Track decisions
pdecision "technical or architectural choice made"

# Track features
pfeature "feature-name" "status"  # status: planned|in-progress|completed|blocked

# Track problems and solutions
pproblem "issue description" "solution or next steps"

# Track code changes
pcode "file/path" "description of changes"

# Search project history
psearch "query terms"

# Get project overview
poverview
```

### Multiple Claude Instances
```bash
# Launch second Claude Docker instance
claude2

# Available modes:
# 1) Interactive Shell - Full Claude CLI access
# 2) Graphiti Worker - JSON API for knowledge graphs  
# 3) Islamic Text Analysis - Specialized Arabic/Islamic NLP
# 4) Software Engineering - Code analysis and development
```

## 📚 Essential Documentation References

### Core Guides (Read These First)
- **[Project Tracking with Graphiti](documentation/guides/PROJECT_TRACKING_WITH_GRAPHITI.md)** - Main reference for development intelligence
- **[Graphiti Workflow Commands](documentation/guides/GRAPHITI_WORKFLOW_COMMANDS.md)** - Complete knowledge graph command reference
- **[Interactive Claude Docker Usage](documentation/guides/CLAUDE_DOCKER_INTERACTIVE_USAGE.md)** - Multiple instance usage patterns

### Technical Architecture
- **[Graphiti Claude Docker Integration](graphiti-main/claude_docker/README.md)** - Local processing architecture
- **[MCP Server Setup](infrastructure/claude-docker/MCP_SERVERS.md)** - Model Context Protocol configuration
- **[Coordination System](infrastructure/coordination/README.md)** - Multi-agent communication

### Graphiti Framework Details  
- **[Graphiti Core Documentation](graphiti-main/CLAUDE.md)** - Framework development commands
- **[Graphiti Docker Architecture](graphiti-main/claude_docker/ARCHITECTURE.md)** - Container integration details
- **[Graphiti MCP Integration](graphiti-main/claude_docker/MCP_INTEGRATION.md)** - Protocol implementation

## 🧠 Working with Knowledge Graphs

### Automatic Integration
- All development sessions are automatically tracked in Neo4j knowledge graph
- Project decisions, features, and problems are stored with temporal relationships
- Islamic text analysis creates persistent entity and relationship mappings
- Cross-session knowledge retention enables intelligent project insights

### Entity Types Available
- **ProjectSession** - Development work sessions with Git context
- **ProjectDecision** - Technical and architectural choices with rationale
- **ProjectFeature** - Feature development with status tracking
- **ProjectProblem** - Issues and solutions with severity levels
- **CodeChange** - File modifications with descriptions and impact
- **Islamic Text Entities** - Scholars, texts, concepts, places, dates with relationships

### Search Capabilities
- **Semantic Search** - Meaning-based entity discovery
- **Keyword Search** - Fast BM25 text matching
- **Graph Traversal** - Relationship-based exploration
- **Temporal Queries** - Time-based knowledge evolution tracking

## 🕌 Islamic Text Analysis Specialization

### Supported Analysis Types
- **Hadith Chain Analysis** - Sanad (transmission chain) relationship mapping
- **Quranic Cross-References** - Verse relationships and thematic connections
- **Scholarly Attribution** - Author and commentator tracking across time
- **Manuscript Analysis** - Historical Islamic text entity extraction
- **Arabic NLP** - RTL text processing and morphological analysis

### Islamic Entity Recognition
- **Scholars** - Names, titles, schools of thought, time periods
- **Texts** - Books, manuscripts, treatises with authorship and dating
- **Concepts** - Islamic jurisprudence, theology, philosophy terms
- **Places** - Historical locations with geographic and temporal context
- **Events** - Historical occurrences with participants and consequences

## 🔧 Development Workflow Integration

### Session Management
When starting work:
1. **Begin tracking**: `pstart "descriptive-session-name"`
2. **Work normally** - all commands available (gr, gs, gt, etc.)
3. **Track key activities** - use pdecision, pfeature, pproblem as needed
4. **End with summary**: `pend "summary of accomplishments"`

### Knowledge Persistence
- **Automatic Storage** - All tracked activities stored in Neo4j
- **Cross-Session Access** - Search previous work with psearch
- **Project Intelligence** - poverview shows recent activities and decisions
- **Export Capabilities** - Knowledge graphs exportable to research/output/

### Multiple Instance Coordination
- **Main Claude Code** - Primary development and conversation
- **Claude Docker (claude2)** - Specialized processing and experimentation
- **Graphiti Workers** - Background knowledge graph processing
- **Islamic NLP Mode** - Specialized Arabic text analysis

## 🔍 Search and Discovery Patterns

### Finding Previous Work
```bash
# Search for specific topics
psearch "authentication"
psearch "Islamic methodology" 
psearch "Docker configuration"

# Search knowledge graph
gs "concept relationships"
gs "hadith authentication methods"
gs "project architecture decisions"
```

### Project Intelligence Queries
```bash
# Recent activity overview
poverview

# Check current system status
gst

# Find related Islamic texts
gt "path/to/new_manuscript.txt"  # Analyzes and connects to existing knowledge
```

## 🚀 Advanced Usage Patterns

### Research Workflows
1. **Text Ingestion**: Use gt command for new Islamic texts
2. **Knowledge Building**: Insights automatically stored in graph
3. **Cross-Reference Discovery**: Search finds related concepts across texts
4. **Academic Output**: Export findings to research/output/ directory

### Development Workflows  
1. **Feature Development**: Track with pfeature command
2. **Decision Documentation**: Use pdecision for architectural choices
3. **Problem Resolution**: Log with pproblem command
4. **Code Documentation**: Track changes with pcode command

### Parallel Processing
1. **Main Session**: Continue normal Claude Code work
2. **Second Instance**: Launch `claude2` for specialized tasks
3. **Background Processing**: Long-running analysis in separate containers
4. **Coordination**: Knowledge graph maintains consistency across instances

## 📊 Project Status and Monitoring

### System Health
- **Neo4j Database**: bolt://localhost:7687 (check with `gst`)
- **Claude Docker API**: http://localhost:8000 (automatically managed)
- **MCP Servers**: Configured for Graphiti, Serena, Context7, Twilio
- **Knowledge Graph**: Persistent storage with automatic backup

### Performance Optimization
- **Local Processing**: Zero external API costs
- **Efficient Storage**: Temporal knowledge graphs with incremental updates
- **Parallel Processing**: Multiple Claude instances for scalability
- **Smart Caching**: Repeated analysis operations optimized

## 🔗 Integration Continuity

This project maintains continuity through:
- **Persistent Documentation** - All guides cross-reference each other
- **Conversation References** - Implementation details preserved in README
- **Knowledge Graph Memory** - Project intelligence spans sessions
- **Multiple Access Points** - Commands available across all interfaces

For detailed implementation, troubleshooting, and advanced patterns, refer to the comprehensive conversation history referenced in README.md that covers the complete integration process.

## 💡 Pro Tips

1. **Start each session with `poverview`** - See recent activity and decisions
2. **Use `gr` frequently** - Store insights as you discover them  
3. **Leverage `claude2`** - Second instance for experimentation and specialized tasks
4. **Search before implementing** - Use `psearch` to find previous solutions
5. **Track decisions immediately** - Use `pdecision` for important choices
6. **End sessions with summaries** - Use `pend` for proper session closure

This Islamic Text Workflow project is designed for intelligent, persistent, and collaborative research. The knowledge graph remembers everything, enabling sophisticated analysis and discovery across all your Islamic text research activities.