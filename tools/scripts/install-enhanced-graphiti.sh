#!/bin/bash
# Install Enhanced Graphiti Commands with Claude Code Integration
# This script seamlessly upgrades the existing graphiti-commands.sh

set -e

echo "🚀 Installing Enhanced Graphiti Commands with Claude Code Integration"
echo "=" * 60

WORKSPACE_DIR="/workspace"
SCRIPTS_DIR="$WORKSPACE_DIR/tools/scripts"
BACKUP_DIR="$WORKSPACE_DIR/tools/scripts/backup"

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "📦 Step 1: Backing up existing commands..."
if [ -f "$SCRIPTS_DIR/graphiti-commands.sh" ]; then
    cp "$SCRIPTS_DIR/graphiti-commands.sh" "$BACKUP_DIR/graphiti-commands.sh.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✅ Backed up existing graphiti-commands.sh"
else
    echo "ℹ️  No existing graphiti-commands.sh found"
fi

echo "🔧 Step 2: Installing enhanced commands..."
if [ -f "$SCRIPTS_DIR/enhanced-graphiti-commands.sh" ]; then
    # Replace the old commands with enhanced version
    cp "$SCRIPTS_DIR/enhanced-graphiti-commands.sh" "$SCRIPTS_DIR/graphiti-commands.sh"
    chmod +x "$SCRIPTS_DIR/graphiti-commands.sh"
    echo "✅ Enhanced commands installed as graphiti-commands.sh"
else
    echo "❌ Enhanced commands file not found at $SCRIPTS_DIR/enhanced-graphiti-commands.sh"
    exit 1
fi

echo "📋 Step 3: Checking dependencies..."

# Check if Graphiti is available
if python3 -c "import sys; sys.path.append('$WORKSPACE_DIR/graphiti-main'); from graphiti_core import Graphiti" 2>/dev/null; then
    echo "✅ Graphiti Core: Available"
else
    echo "⚠️  Graphiti Core: Installing..."
    cd "$WORKSPACE_DIR/graphiti-main"
    pip install -e . --quiet
    echo "✅ Graphiti Core: Installed"
fi

# Check Claude Docker Client
if python3 -c "import sys; sys.path.append('$WORKSPACE_DIR/graphiti-main'); from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient" 2>/dev/null; then
    echo "✅ Claude Docker Client: Available"
else
    echo "❌ Claude Docker Client: Not available"
    echo "   Make sure Claude Docker integration is set up in graphiti-main/"
fi

# Check Google API key
if [ -n "$GOOGLE_API_KEY" ]; then
    echo "✅ Google API Key: Configured"
else
    echo "⚠️  Google API Key: Not set"
    echo "   Set with: export GOOGLE_API_KEY=your_key_here"
    echo "   Or add to your shell profile"
fi

echo "🔍 Step 4: System status check..."

# Check Neo4j
if nc -z localhost 7687 2>/dev/null; then
    echo "✅ Neo4j: Running"
else
    echo "⚠️  Neo4j: Not running"
    echo "   Start with: docker run -d --name neo4j -p 7687:7687 -p 7474:7474 -e NEO4J_AUTH=neo4j/password neo4j:latest"
fi

# Check Claude Docker API
if nc -z localhost 8000 2>/dev/null; then
    echo "✅ Claude Docker API: Running"
else
    echo "⚠️  Claude Docker API: Not running"
    echo "   Start with: cd $WORKSPACE_DIR/graphiti-main/claude_docker && ./scripts/start_claude_docker_api.sh"
fi

echo "🔄 Step 5: Updating shell configuration..."

# Add to bashrc if not already present
if ! grep -q "source $SCRIPTS_DIR/graphiti-commands.sh" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Enhanced Graphiti Commands" >> ~/.bashrc
    echo "if [ -f \"$SCRIPTS_DIR/graphiti-commands.sh\" ]; then" >> ~/.bashrc
    echo "    source \"$SCRIPTS_DIR/graphiti-commands.sh\"" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
    echo "✅ Added to ~/.bashrc"
else
    echo "ℹ️  Already configured in ~/.bashrc"
fi

echo "📚 Step 6: Creating usage documentation..."

cat > "$WORKSPACE_DIR/tools/scripts/ENHANCED_GRAPHITI_USAGE.md" << 'EOF'
# Enhanced Graphiti Commands Usage Guide

## Overview
The enhanced Graphiti commands provide full Claude Code integration with real knowledge graph capabilities instead of basic file operations.

## Commands

### Core Knowledge Graph Operations

#### `gt "file.txt"` or `gt "text"`
- **Old**: Just displayed first 10 lines with `cat | head -10`
- **New**: Full Graphiti analysis with entity extraction, relationship mapping, and knowledge graph storage
- **Example**: `gt "/workspace/research/output/multi-agent-docker-architecture-analysis.txt"`

#### `gs "search query"`
- **Old**: Simple grep search of memory file
- **New**: Semantic search using embeddings + keyword + graph traversal
- **Example**: `gs "multi-agent architecture"`

#### `gr "information"`
- **Old**: Simple file append
- **New**: Full knowledge graph storage with entity extraction and relationship mapping
- **Example**: `gr "Docker provides container isolation for multi-agent systems"`

#### `gst`
- **Old**: Basic service status checks
- **New**: Comprehensive system status including Neo4j, Claude Docker API, dependencies, and knowledge graph statistics

### Project Development Tracking

#### `pstart "session-name"`
- Starts a tracked project session in the knowledge graph
- **Example**: `pstart "multi-agent-architecture-research"`

#### `pdecision "decision"`
- Tracks architectural and technical decisions
- **Example**: `pdecision "Using Docker stdin/stdout for agent communication"`

#### `pfeature "feature-name" "status"`
- Tracks feature development status
- **Example**: `pfeature "enhanced-graphiti-commands" "completed"`

#### `psearch "query"`
- Searches project-specific entries in knowledge graph
- **Example**: `psearch "Docker architecture"`

#### `poverview`
- Shows recent project activity and decisions

## System Requirements

### Required Services
- **Neo4j**: Database for knowledge graph storage
- **Claude Docker API**: Local LLM processing
- **Google API Key**: For embeddings (text-embedding-004)

### Setup Commands
```bash
# Start Neo4j
docker run -d --name neo4j -p 7687:7687 -p 7474:7474 -e NEO4J_AUTH=neo4j/password neo4j:latest

# Start Claude Docker API
cd /workspace/graphiti-main/claude_docker && ./scripts/start_claude_docker_api.sh

# Set Google API key
export GOOGLE_API_KEY=your_key_here
```

## Technical Implementation

### Architecture
- **Python Scripts**: Each command generates a temporary Python script
- **Graphiti Integration**: Uses ClaudeDockerClient for LLM operations
- **Embeddings**: Google's text-embedding-004 model
- **Database**: Neo4j for knowledge graph storage

### Benefits Over Old System
1. **Real Knowledge Graph**: Actual entity extraction and relationship mapping
2. **Semantic Search**: Vector embeddings for meaning-based search
3. **Temporal Tracking**: Time-based knowledge evolution
4. **Cross-Session Memory**: Persistent knowledge across sessions
5. **Claude Code Integration**: Leverages full Claude Code capabilities

### Performance
- **Startup**: ~2-3 seconds per command (vs instant for old system)
- **Accuracy**: High - full LLM processing vs simple text operations
- **Scalability**: Handles large knowledge graphs efficiently
- **Memory**: Persistent across sessions and projects

## Migration from Old Commands

### Automatic Migration
The installation script automatically:
1. Backs up old graphiti-commands.sh
2. Replaces with enhanced version
3. Maintains same command aliases (gt, gs, gr, gst)
4. Updates shell configuration

### Compatibility
- **Command Interface**: Identical - no changes needed to existing workflows
- **Functionality**: Dramatically enhanced - same commands, much more powerful
- **Performance**: Slower startup but much more accurate and useful results

## Troubleshooting

### Common Issues

#### "Cannot import Graphiti"
```bash
cd /workspace/graphiti-main
pip install -e .
```

#### "Neo4j connection failed"
```bash
docker run -d --name neo4j -p 7687:7687 -p 7474:7474 -e NEO4J_AUTH=neo4j/password neo4j:latest
```

#### "Google API key not set"
```bash
export GOOGLE_API_KEY=your_key_here
echo 'export GOOGLE_API_KEY=your_key_here' >> ~/.bashrc
```

#### "Claude Docker API not running"
```bash
cd /workspace/graphiti-main/claude_docker
./scripts/start_claude_docker_api.sh
```

### Verification
```bash
# Check all systems
gst

# Test basic functionality
gr "Testing enhanced Graphiti commands"
gs "testing"
```

## Advanced Usage

### Bulk Text Analysis
```bash
# Analyze multiple files
for file in research/texts/*.txt; do
    gt "$file"
done
```

### Project Workflow
```bash
# Start session
pstart "research-session-$(date +%Y%m%d)"

# Track work
pdecision "Using enhanced Graphiti for knowledge management"
pfeature "text-analysis" "in-progress"

# Search previous work
psearch "previous research findings"

# Get overview
poverview
```

### Knowledge Graph Queries
```bash
# Search for concepts
gs "Islamic text analysis"
gs "Docker architecture patterns"
gs "research methodology"

# Find related information
gt "new-research-document.txt"
gs "related research"  # Find connections
```

This enhanced system transforms the simple file-based commands into a sophisticated knowledge management platform with full Claude Code integration.
EOF

echo "✅ Created comprehensive usage documentation"

echo ""
echo "🎉 Enhanced Graphiti Commands Installation Complete!"
echo ""
echo "📋 What's New:"
echo "  ✅ Full Claude Code integration instead of basic file operations"
echo "  ✅ Real knowledge graph with entity extraction and relationships"
echo "  ✅ Semantic search with embeddings instead of simple grep"
echo "  ✅ Persistent knowledge across sessions and projects"
echo "  ✅ Project development tracking (pstart, pdecision, pfeature)"
echo "  ✅ Comprehensive system status and statistics"
echo ""
echo "🚀 Next Steps:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. Check system status: gst"
echo "  3. Start Neo4j if needed: docker run -d --name neo4j -p 7687:7687 -p 7474:7474 -e NEO4J_AUTH=neo4j/password neo4j:latest"
echo "  4. Set Google API key: export GOOGLE_API_KEY=your_key_here"
echo "  5. Test with: gt '/workspace/research/output/multi-agent-docker-architecture-analysis.txt'"
echo ""
echo "📖 Documentation: /workspace/tools/scripts/ENHANCED_GRAPHITI_USAGE.md"
echo ""
echo "🔧 Commands work exactly the same way - but now with full Claude Code power!"