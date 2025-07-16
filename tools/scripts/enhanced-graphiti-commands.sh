#!/bin/bash
# Enhanced Graphiti Commands with Claude Code Integration
# This replaces the basic graphiti-commands.sh with full Claude Code integration

# Workspace detection
if [ -f "/workspace/CLAUDE.md" ]; then
    WORKSPACE_DIR="/workspace"
else
    WORKSPACE_DIR="$(pwd)"
fi

export WORKSPACE_DIR

# Claude Code Integration Functions
# These functions leverage Claude Code's actual capabilities instead of basic shell commands

# Enhanced text analysis with Claude Code + Graphiti integration
enhanced_analyze_text() {
    if [ -z "$1" ]; then
        echo "Usage: gt 'file.txt' or gt 'direct text'"
        return 1
    fi
    
    local input="$1"
    local temp_claude_script="/tmp/claude_graphiti_analyze.py"
    
    # Create Python script that uses Graphiti with Claude Code
    cat > "$temp_claude_script" << 'EOF'
import asyncio
import sys
import os
from datetime import datetime, timezone

# Add project paths
sys.path.append('/workspace/graphiti-main')
sys.path.append('/workspace')

from graphiti_core import Graphiti
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

async def analyze_with_graphiti(input_text, is_file=False):
    """Analyze text using full Graphiti capabilities"""
    print(f"🧠 Analyzing {'file' if is_file else 'text'} with Graphiti knowledge graph...")
    
    # Configure Claude Docker client
    llm_config = LLMConfig(
        api_key="not-needed",
        model="claude-sonnet-4-0",
        temperature=0.3,
        max_tokens=2000
    )
    
    # Configure embeddings
    gemini_config = GeminiEmbedderConfig(
        api_key=os.getenv('GOOGLE_API_KEY'),
        embedding_model="models/text-embedding-004"
    )
    
    # Initialize Graphiti
    graphiti = Graphiti(
        uri="bolt://localhost:7687",
        user="neo4j", 
        password="password",
        llm_client=ClaudeDockerClient(llm_config),
        embedder=GeminiEmbedder(gemini_config)
    )
    
    # Build indices if needed
    await graphiti.build_indices_and_constraints()
    
    # Read file content if it's a file
    if is_file:
        try:
            with open(input_text, 'r', encoding='utf-8') as f:
                content = f.read()
            file_name = os.path.basename(input_text)
            print(f"📄 Reading file: {file_name}")
        except Exception as e:
            print(f"❌ Error reading file: {e}")
            return
    else:
        content = input_text
        file_name = "Direct Input"
    
    # Add episode to knowledge graph
    try:
        episode = await graphiti.add_episode(
            name=f"Text Analysis: {file_name}",
            episode_body=content,
            source_description=f"Analyzed via gt command: {file_name}",
            episode_type="text"
        )
        print(f"✅ Added to knowledge graph: {episode.name}")
        
        # Search for related content
        search_results = await graphiti.search(
            query=content[:200],  # Use first 200 chars as search query
            num_results=5
        )
        
        if search_results:
            print(f"\n🔍 Found {len(search_results)} related items in knowledge graph:")
            for i, result in enumerate(search_results, 1):
                print(f"  {i}. {result.name} (Score: {result.score:.3f})")
        
        # Extract key entities and relationships
        print(f"\n📊 Knowledge graph updated with new entities and relationships from {file_name}")
        
    except Exception as e:
        print(f"❌ Error processing with Graphiti: {e}")

if __name__ == "__main__":
    input_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    is_file = os.path.isfile(input_arg)
    
    asyncio.run(analyze_with_graphiti(input_arg, is_file))
EOF
    
    # Execute the analysis with Python
    echo "🚀 Starting enhanced Graphiti analysis..."
    if [ -f "$input" ]; then
        echo "📁 File detected: $input"
        python3 "$temp_claude_script" "$input"
    else
        echo "📝 Direct text input"
        python3 "$temp_claude_script" "$input"
    fi
    
    # Clean up
    rm -f "$temp_claude_script"
}

# Enhanced semantic search with Claude Code integration
enhanced_search() {
    if [ -z "$1" ]; then
        echo "Usage: gs 'search query'"
        return 1
    fi
    
    local query="$1"
    local temp_claude_script="/tmp/claude_graphiti_search.py"
    
    cat > "$temp_claude_script" << 'EOF'
import asyncio
import sys
import os

# Add project paths
sys.path.append('/workspace/graphiti-main')
sys.path.append('/workspace')

from graphiti_core import Graphiti
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

async def search_knowledge_graph(query):
    """Search knowledge graph with semantic capabilities"""
    print(f"🔍 Searching knowledge graph for: '{query}'")
    
    # Configure clients
    llm_config = LLMConfig(
        api_key="not-needed",
        model="claude-sonnet-4-0",
        temperature=0.3,
        max_tokens=2000
    )
    
    gemini_config = GeminiEmbedderConfig(
        api_key=os.getenv('GOOGLE_API_KEY'),
        embedding_model="models/text-embedding-004"
    )
    
    # Initialize Graphiti
    graphiti = Graphiti(
        uri="bolt://localhost:7687",
        user="neo4j",
        password="password", 
        llm_client=ClaudeDockerClient(llm_config),
        embedder=GeminiEmbedder(gemini_config)
    )
    
    try:
        # Perform semantic search
        results = await graphiti.search(
            query=query,
            num_results=10
        )
        
        if results:
            print(f"📊 Found {len(results)} results:")
            print("=" * 60)
            
            for i, result in enumerate(results, 1):
                print(f"{i}. {result.name}")
                print(f"   Score: {result.score:.3f}")
                print(f"   Type: {result.type}")
                if hasattr(result, 'summary') and result.summary:
                    print(f"   Summary: {result.summary[:100]}...")
                print()
        else:
            print("❌ No results found")
            
    except Exception as e:
        print(f"❌ Search error: {e}")

if __name__ == "__main__":
    query = sys.argv[1] if len(sys.argv) > 1 else ""
    asyncio.run(search_knowledge_graph(query))
EOF
    
    echo "🚀 Starting enhanced semantic search..."
    python3 "$temp_claude_script" "$query"
    rm -f "$temp_claude_script"
}

# Enhanced knowledge storage with Claude Code integration
enhanced_remember() {
    if [ -z "$1" ]; then
        echo "Usage: gr 'information to remember'"
        return 1
    fi
    
    local info="$1"
    local temp_claude_script="/tmp/claude_graphiti_remember.py"
    
    cat > "$temp_claude_script" << 'EOF'
import asyncio
import sys
import os
from datetime import datetime, timezone

# Add project paths
sys.path.append('/workspace/graphiti-main')
sys.path.append('/workspace')

from graphiti_core import Graphiti
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

async def remember_in_knowledge_graph(info):
    """Store information in knowledge graph with full processing"""
    print(f"🧠 Storing in knowledge graph: {info[:50]}...")
    
    # Configure clients
    llm_config = LLMConfig(
        api_key="not-needed",
        model="claude-sonnet-4-0",
        temperature=0.3,
        max_tokens=2000
    )
    
    gemini_config = GeminiEmbedderConfig(
        api_key=os.getenv('GOOGLE_API_KEY'),
        embedding_model="models/text-embedding-004"
    )
    
    # Initialize Graphiti
    graphiti = Graphiti(
        uri="bolt://localhost:7687",
        user="neo4j",
        password="password",
        llm_client=ClaudeDockerClient(llm_config),
        embedder=GeminiEmbedder(gemini_config)
    )
    
    # Build indices if needed
    await graphiti.build_indices_and_constraints()
    
    try:
        # Add as episode with timestamp
        episode = await graphiti.add_episode(
            name=f"Manual Entry: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
            episode_body=info,
            source_description="Manual entry via gr command",
            episode_type="manual_entry",
            timestamp=datetime.now(timezone.utc)
        )
        
        print(f"✅ Successfully stored: {episode.name}")
        
        # Check for related content
        related = await graphiti.search(
            query=info,
            num_results=3
        )
        
        if related:
            print(f"🔗 Found {len(related)} related items:")
            for r in related:
                print(f"  - {r.name} (Score: {r.score:.3f})")
        
    except Exception as e:
        print(f"❌ Error storing information: {e}")

if __name__ == "__main__":
    info = sys.argv[1] if len(sys.argv) > 1 else ""
    asyncio.run(remember_in_knowledge_graph(info))
EOF
    
    echo "🚀 Starting enhanced knowledge storage..."
    python3 "$temp_claude_script" "$info"
    rm -f "$temp_claude_script"
}

# Enhanced system status with comprehensive checks
enhanced_status() {
    echo "🔍 Enhanced Graphiti System Status"
    echo "=" * 40
    
    # Check Neo4j
    if nc -z localhost 7687 2>/dev/null; then
        echo "✅ Neo4j: Running (bolt://localhost:7687)"
    else
        echo "❌ Neo4j: Not running"
        echo "   Start with: docker run -d --name neo4j -p 7687:7687 -p 7474:7474 neo4j:latest"
    fi
    
    # Check Claude Docker API
    if nc -z localhost 8000 2>/dev/null; then
        echo "✅ Claude Docker API: Running (http://localhost:8000)"
    else
        echo "❌ Claude Docker API: Not running"
        echo "   Start with: cd ${WORKSPACE_DIR}/graphiti-main/claude_docker && ./scripts/start_claude_docker_api.sh"
    fi
    
    # Check Google API key for embeddings
    if [ -n "$GOOGLE_API_KEY" ]; then
        echo "✅ Google API Key: Configured"
    else
        echo "❌ Google API Key: Not set"
        echo "   Set with: export GOOGLE_API_KEY=your_key_here"
    fi
    
    # Check Python dependencies
    if python3 -c "import sys; sys.path.append('/workspace/graphiti-main'); from graphiti_core import Graphiti" 2>/dev/null; then
        echo "✅ Graphiti Core: Available"
    else
        echo "❌ Graphiti Core: Not available"
        echo "   Install with: cd ${WORKSPACE_DIR}/graphiti-main && pip install -e ."
    fi
    
    # Check knowledge graph stats
    echo ""
    echo "📊 Knowledge Graph Statistics:"
    
    local temp_stats_script="/tmp/claude_graphiti_stats.py"
    cat > "$temp_stats_script" << 'EOF'
import asyncio
import sys
import os

sys.path.append('/workspace/graphiti-main')

try:
    from graphiti_core import Graphiti
    from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
    from graphiti_core.llm_client.config import LLMConfig
    from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig
    
    async def get_stats():
        try:
            llm_config = LLMConfig(api_key="not-needed", model="claude-sonnet-4-0")
            gemini_config = GeminiEmbedderConfig(
                api_key=os.getenv('GOOGLE_API_KEY'),
                embedding_model="models/text-embedding-004"
            )
            
            graphiti = Graphiti(
                uri="bolt://localhost:7687",
                user="neo4j",
                password="password",
                llm_client=ClaudeDockerClient(llm_config),
                embedder=GeminiEmbedder(gemini_config)
            )
            
            # Get recent episodes
            episodes = await graphiti.get_episodes(limit=5)
            print(f"   Recent episodes: {len(episodes)}")
            
            for episode in episodes:
                print(f"   - {episode.name}")
                
        except Exception as e:
            print(f"   Error getting stats: {e}")
    
    asyncio.run(get_stats())
    
except ImportError as e:
    print(f"   Cannot load Graphiti: {e}")
EOF
    
    python3 "$temp_stats_script"
    rm -f "$temp_stats_script"
}

# Project development tracking functions
project_start() {
    if [ -z "$1" ]; then
        echo "Usage: pstart 'session-name'"
        return 1
    fi
    
    local session_name="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    enhanced_remember "PROJECT SESSION START: ${session_name} - Started at ${timestamp} - Context: $(git branch --show-current 2>/dev/null || echo 'no-git') - Working directory: $(pwd)"
    
    echo "🚀 Started project session: ${session_name}"
    echo "📊 Session tracked in knowledge graph"
}

project_decision() {
    if [ -z "$1" ]; then
        echo "Usage: pdecision 'decision made'"
        return 1
    fi
    
    enhanced_remember "PROJECT DECISION: $1 - Context: $(git branch --show-current 2>/dev/null || echo 'no-git') - Timestamp: $(date)"
    echo "✅ Decision tracked in knowledge graph"
}

project_feature() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: pfeature 'feature-name' 'status'"
        echo "Status: planned|in-progress|completed|blocked"
        return 1
    fi
    
    enhanced_remember "PROJECT FEATURE: $1 - Status: $2 - Context: $(git branch --show-current 2>/dev/null || echo 'no-git') - Timestamp: $(date)"
    echo "📋 Feature status tracked in knowledge graph"
}

project_search() {
    if [ -z "$1" ]; then
        echo "Usage: psearch 'query terms'"
        return 1
    fi
    
    enhanced_search "PROJECT: $1"
}

project_overview() {
    echo "🔍 Project Overview from Knowledge Graph"
    echo "=" * 40
    
    enhanced_search "PROJECT SESSION"
    echo ""
    enhanced_search "PROJECT DECISION"  
    echo ""
    enhanced_search "PROJECT FEATURE"
}

# Enhanced aliases that use the new functions
alias gt='enhanced_analyze_text'
alias gs='enhanced_search'
alias gr='enhanced_remember'
alias gst='enhanced_status'

# Project tracking aliases
alias pstart='project_start'
alias pdecision='project_decision'
alias pfeature='project_feature'
alias psearch='project_search'
alias poverview='project_overview'

# Claude Docker instances - clean, direct access
alias claude2="${WORKSPACE_DIR}/tools/scripts/interactive-claude-docker.sh"

echo "🧠 Enhanced Graphiti commands loaded with full Claude Code integration!"
echo "🔍 Use 'gst' to check system status and verify all components are running"