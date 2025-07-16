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
gr "project insights or technical notes"

# Search knowledge graph
gs "search query for concepts or decisions" 

# Analyze text files
gt "/path/to/document.txt"

# Check system status
gst  # Shows Neo4j and Claude Docker API status
```

### Slash Commands (Available in Claude Code)
```bash
# Core Graphiti Operations
/gr "information to remember"     # Store in knowledge graph
/gs "search query"                # Search knowledge graph
/gt "file.txt"                    # Analyze text content
/gst                             # Check system status

# Project Management
/pstart "session-name"           # Start new development session
/poverview                       # Get project overview
/psearch "query"                 # Search project intelligence
/pend "summary"                  # End session with summary

# Multi-Instance & Modes
/claude2                         # Launch second Claude instance
/graphiti-mode                   # Switch to Graphiti operations mode
/dev-mode                        # Switch to development mode
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

## 🤖 Automatic Knowledge Graph Tracking Protocol

### Session Lifecycle Automation
- **CONVERSATION START**: Auto-execute session tracking with project context detection
- **ON FIRST USER MESSAGE**: Auto-run `source tools/scripts/graphiti-commands.sh && graph_remember "SESSION START: auto-session-$(date +%Y%m%d_%H%M%S) - Context: [development/islamic-research/graphiti-ops] - Request: [brief description]"`
- **CONTINUOUS OPERATION**: Auto-track all significant activities based on detected context

### Context-Aware Development Tracking
- **WHEN configuring systems**: Auto-track infrastructure setup and integration decisions
- **WHEN setting up Claude instances**: Auto-log multi-agent coordination choices
- **WHEN solving technical problems**: Auto-store general solution patterns
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "DEVELOPMENT: [context] - [technical choice/solution] - [rationale]"`

### Context-Aware Islamic Research Tracking (Islamic Instance Mode)
- **WHEN processing Arabic texts**: Auto-execute text analysis and entity extraction
- **WHEN discovering scholars/concepts**: Auto-store in knowledge graph with temporal context
- **WHEN finding text relationships**: Auto-record cross-references and manuscript connections
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "ISLAMIC TEXT DISCOVERY: [entity/relationship/insight found]"`

### Universal Decision Tracking
- **BEFORE choosing approaches**: Auto-record methodology decisions with context
- **WHEN selecting technical solutions**: Auto-log choices and alternatives considered
- **AFTER validating outcomes**: Auto-store results and lessons learned
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "DECISION: [context] - [choice] - [rationale]"`

### Code and Configuration Tracking
- **ON Edit/MultiEdit/Write**: Auto-track changes with contextual description
- **WHEN modifying Docker/Graphiti configs**: Auto-log infrastructure changes
- **WHEN updating slash commands**: Auto-record interface improvements
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "CODE CHANGE: [file] - [modification description] - [purpose/context]"`

### Universal Problem Resolution
- **WHEN tools fail or errors occur**: Auto-log problems and solutions by context
- **WHEN configuration issues arise**: Auto-store infrastructure fixes
- **WHEN integration challenges emerge**: Auto-record coordination solutions
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "PROBLEM SOLVED: [context] - [issue] - [solution applied]"`

### Knowledge Discovery Automation
- **WHEN explaining complex concepts**: Auto-store insights and methodological discoveries
- **WHEN finding architectural patterns**: Auto-remember system design insights
- **WHEN discovering optimization opportunities**: Auto-record performance improvements
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "INSIGHT: [domain] - [discovery/explanation] - [impact]"`

### Session Conclusion
- **END OF SESSION**: Auto-summarize accomplishments with timestamp-prefixed documentation
- **SESSION SUMMARY FORMAT**: `# YYYY-MM-DD_HHMMSS - [Session Title]`
- **KNOWLEDGE GRAPH FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "SESSION END: [context] - [accomplishments] - [outcomes/next steps]"`
- **FILE NAMING**: `research/output/YYYY-MM-DD_HHMMSS-session-[descriptive-title].md`

## 🔄 Slash Commands Integration

### Core Knowledge Graph Commands
- **`/gr "text"`** - Store information in Graphiti knowledge graph with timestamp
- **`/gs "query"`** - Search knowledge graph for concepts, decisions, and insights
- **`/gt "file.txt"`** - Analyze text content and extract entities/relationships
- **`/gst`** - Check system status of Neo4j, Claude Docker API, and Graphiti services

### Project Intelligence Commands
- **`/pstart "session-name"`** - Begin new development session with project tracking
- **`/poverview`** - Get comprehensive project overview and recent activity
- **`/psearch "query"`** - Search across all project sessions, decisions, and features
- **`/pend "summary"`** - End current session with accomplishment summary

### Multi-Instance & Specialized Modes
- **`/claude2`** - Launch second Claude instance for parallel processing
- **`/graphiti-mode`** - Switch to specialized Graphiti operations tracking
- **`/dev-mode`** - Switch to general development tracking mode

### Usage Patterns
```bash
# Start a new development session
/pstart "graphiti-api-optimization"

# Switch to specialized mode
/graphiti-mode

# Store insights as you work
/gr "OPTIMIZATION: Query performance improved 40% with indexed relationships"

# Search for previous work
/gs "performance optimization"

# Analyze documentation
/gt "docs/architecture.md"

# Check system health
/gst

# Get project overview
/poverview
```

## 💡 Pro Tips

1. **Start each session with `/poverview`** - See recent project activity and decisions
2. **Use slash commands for quick operations** - More efficient than bash commands
3. **Leverage `/claude2`** - Launch specialized instances for parallel processing
4. **Search before implementing** - Use `/psearch` to find previous solutions
5. **Trust the automation** - Knowledge graph captures insights as you work
6. **Review with `/gs`** - Search accumulated knowledge across all contexts

This project integrates **Graphiti v0.17.4** with **Claude Code slash commands** for intelligent, persistent, and collaborative development with context-aware automatic knowledge capture.