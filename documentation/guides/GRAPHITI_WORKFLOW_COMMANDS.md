# Graphiti Knowledge Graph Workflow Commands

**📖 Main Reference**: See [CLAUDE.md](../../CLAUDE.md) for complete command overview and development workflows.

## Overview

Graphiti is now integrated into your standard Islamic text workflow with custom shell commands for quick knowledge graph operations.

**Related Documentation:**
- **[CLAUDE.md](../../CLAUDE.md)** - Main command reference and project workflows
- **[Project Tracking Guide](PROJECT_TRACKING_WITH_GRAPHITI.md)** - Development session tracking
- **[Interactive Claude Docker Usage](CLAUDE_DOCKER_INTERACTIVE_USAGE.md)** - Multiple instance usage

## Setup Status ✅

- **MCP Server**: Configured in `~/.claude/mcp_settings.json` 
- **Claude Docker Integration**: Using local Claude instead of OpenAI
- **Claude Docker API**: Running on `http://localhost:8000`
- **Neo4j Database**: Running on `bolt://localhost:7687`
- **Shell Commands**: Loaded in `.zshrc`
- **Memory Storage**: `~/.claude/graphiti_memory.txt`

## Quick Commands

### Basic Operations

```bash
# Store information in knowledge graph
gr "This is important Islamic text information"
graph_remember "Detailed analysis of hadith methodology"

# Search the knowledge graph
gs "Islamic methodology"
graph_search "hadith authentication"

# Check system status
gst
graph_status

# Start interactive session
gstart
graph_start
```

### Text Analysis

```bash
# Analyze Islamic text files
gt "/path/to/islamic_text.txt"
graph_analyze_text "Direct text to analyze"

# Specialized Islamic content
graph_analyze_hadith "Authentic hadith text here"
graph_analyze_quran "Quranic verse text here"
```

### Data Management

```bash
# Export knowledge graph
graph_export

# View all stored memories
cat ~/.claude/graphiti_memory.txt
```

## Integration with Claude Code

Graphiti is configured as an MCP server for Claude Code sessions using **Claude Docker**:

1. **Local Processing**: Uses your Claude Docker containers instead of external APIs
2. **Zero API Costs**: No OpenAI or external LLM API calls
3. **Automatic Loading**: Commands load automatically in new shell sessions
4. **Persistent Memory**: Knowledge stored across sessions
5. **Search Capabilities**: Query historical information
6. **Islamic Text Focus**: Specialized commands for religious texts

### Claude Docker Benefits

- **Privacy**: All processing happens locally
- **Speed**: Direct container communication
- **Cost**: No per-token charges
- **Integration**: Works with your existing Claude Docker setup

## Neo4j Database

- **URL**: `bolt://localhost:7687`
- **User**: `neo4j`
- **Password**: `password`
- **Status**: Managed via Docker container
- **Web Interface**: `http://localhost:7474`

## File Structure

```
~/.claude/
├── mcp_settings.json          # MCP server configuration
├── graphiti_memory.txt        # Local memory storage
└── settings.json              # Claude Code settings

~/Project/islamic-text-workflow/
├── tools/scripts/
│   └── graphiti-commands.sh   # Shell command definitions
├── research/output/           # Exported knowledge graphs
└── documentation/guides/      # This documentation
```

## Usage Examples

### Daily Workflow

```bash
# Start your session
gstart

# Analyze a new Islamic text
gt "research/texts/new_manuscript.txt"

# Remember key insights
gr "This manuscript shows evidence of 9th century Hanafi jurisprudence"

# Search for related information
gs "Hanafi jurisprudence"

# Export findings
graph_export
```

### Research Session

```bash
# Analyze hadith
graph_analyze_hadith "The Prophet (PBUH) said: 'Seek knowledge from the cradle to the grave'"

# Analyze Quranic reference
graph_analyze_quran "And say: My Lord, increase me in knowledge"

# Search connections
gs "knowledge seeking"
```

## Advanced Integration

### With Docker Workflow

The commands integrate with your existing Docker-based Claude workflow:

- Coordination system reads from Graphiti memory
- Batch processing updates knowledge graph
- Academic analysis exports to research output

### With MCP Servers

Graphiti works alongside your other MCP servers:

- **Serena**: Code analysis stored in knowledge graph
- **Context7**: Documentation insights added to graph
- **Twilio**: Notifications for completed analysis

## Troubleshooting

### Claude Docker API Not Running

```bash
cd /Users/farieds/Project/islamic-text-workflow/graphiti-main/claude_docker
./scripts/start_claude_docker_api.sh
```

### Neo4j Not Running

```bash
# Neo4j is started automatically with Claude Docker API
# But if needed separately:
cd /Users/farieds/Project/islamic-text-workflow/graphiti-main/mcp_server  
docker-compose up -d neo4j
```

### Commands Not Loading

```bash
source ~/.zshrc
# or
source "/Users/farieds/Project/islamic-text-workflow/tools/scripts/graphiti-commands.sh"
```

### Memory File Issues

```bash
# Reset memory
rm ~/.claude/graphiti_memory.txt
graph_status
```

## Next Steps

1. **Integrate with Academic Workflow**: Use `gr` commands in your research pipeline
2. **Automate Analysis**: Create scripts that feed analysis results to Graphiti
3. **Expand Entity Types**: Customize the knowledge graph for Islamic scholarship
4. **Connect to Documentation**: Link graph insights to your research outputs

## Command Reference

| Command | Alias | Purpose |
|---------|-------|---------|
| `graph_remember` | `gr` | Store information |
| `graph_search` | `gs` | Search knowledge |
| `graph_analyze_text` | `gt` | Analyze text files |
| `graph_status` | `gst` | Check system status |
| `graph_start` | `gstart` | Start session |
| `graph_export` | - | Export knowledge |
| `graph_analyze_hadith` | - | Hadith analysis |
| `graph_analyze_quran` | - | Quranic analysis |

Your Graphiti integration is now complete and ready for Islamic text workflow! 🚀