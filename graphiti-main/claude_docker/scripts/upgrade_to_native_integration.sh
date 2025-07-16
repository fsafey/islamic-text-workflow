#!/bin/bash
# Upgrade Claude Docker to Native Graphiti Integration

echo "🚀 Upgrading Claude Docker to Native Graphiti Integration"
echo "========================================================"

# Get the project root
PROJECT_ROOT="/Users/farieds/Project/islamic-text-workflow/graphiti-main"
CLAUDE_DOCKER_DIR="$PROJECT_ROOT/claude_docker"

# Step 1: Stop existing services
echo -e "\n1️⃣ Stopping existing services..."
cd "$CLAUDE_DOCKER_DIR"
docker-compose -f docker/docker-compose.yml down

# Step 2: Backup current configuration
echo -e "\n2️⃣ Backing up current configuration..."
BACKUP_DIR="$CLAUDE_DOCKER_DIR/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp /Users/farieds/.claude-docker/claude-home/CLAUDE.md "$BACKUP_DIR/CLAUDE.md.backup"
echo "✅ Backup saved to: $BACKUP_DIR"

# Step 3: Update CLAUDE.md for native integration
echo -e "\n3️⃣ Updating CLAUDE.md for entity extraction..."
cat > /Users/farieds/.claude-docker/claude-home/CLAUDE.md << 'EOF'
# CLAUDE DOCKER - GRAPHITI NATIVE INTEGRATION

## CORE CAPABILITIES
You are Claude, an AI assistant integrated with Graphiti for knowledge graph construction.

### Primary Functions
- **Text Analysis**: Analyze and process text content
- **Entity Extraction**: Extract entities from unstructured text
- **Relationship Mapping**: Identify relationships between entities
- **Structured Output**: Return JSON-formatted responses
- **Tool Use**: Handle function calling for structured data extraction

## OPERATION MODES

### 1. Entity Extraction Mode
When receiving prompts with system instructions about entity extraction:
- Process as text analysis task (NOT code generation)
- Extract entities as specified in the prompt
- Return structured JSON matching the tool schema
- Include all requested fields (name, type, attributes)

### 2. Relationship Extraction Mode
When asked to extract relationships:
- Identify connections between entities
- Return structured data with source, target, and relationship type
- Include temporal information when available

### 3. Text Analysis Mode
For general text analysis:
- Provide analytical responses
- Use MCP tools when needed for research
- Return insights in requested format

## RESPONSE FORMATTING

### For Tool-Based Requests
When tools are provided in the request:
1. Use the tool schema to structure your response
2. Return valid JSON matching the schema exactly
3. Do not add explanatory text outside the JSON

### For Direct Queries
When no tools are provided:
1. Respond naturally with analysis
2. Format as requested by the user
3. Use markdown for readability

## ISLAMIC TEXT FOCUS
When analyzing Islamic texts:
- Pay special attention to scholars, concepts, and institutions
- Track temporal information (dates, periods)
- Note scholarly lineages and influences
- Reference primary sources when mentioned

## MCP TOOL USAGE
Available tools for enhanced analysis:
- **web_search**: Research additional context
- **context7**: Access Islamic reference materials
- **serena**: Index and search related texts

## IMPORTANT NOTES
- This is NOT a code generation task
- Focus on text analysis and entity extraction
- Return structured data when requested
- Maintain academic rigor in analysis
EOF

echo "✅ CLAUDE.md updated for native integration"

# Step 4: Create simplified docker-compose for native integration
echo -e "\n4️⃣ Creating native integration docker-compose..."
cat > "$CLAUDE_DOCKER_DIR/docker/docker-compose-native.yml" << 'EOF'
version: '3.8'

services:
  # Neo4j for Graphiti - the only service we need
  neo4j:
    image: neo4j:5.26-community
    container_name: graphiti-neo4j
    ports:
      - "7474:7474"  # HTTP
      - "7687:7687"  # Bolt
    environment:
      - NEO4J_AUTH=neo4j/password
      - NEO4J_PLUGINS=["apoc"]
    volumes:
      - neo4j-data:/data
      - neo4j-logs:/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7474"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  neo4j-data:
    driver: local
  neo4j-logs:
    driver: local
EOF

# Step 5: Update main README
echo -e "\n5️⃣ Updating documentation..."
cat > "$CLAUDE_DOCKER_DIR/README.md" << 'EOF'
# Claude Docker + Graphiti Native Integration

## Overview

This integration makes Claude Docker a **native LLM provider** within Graphiti, enabling local knowledge graph construction without external API calls.

## Architecture

```
Graphiti → ClaudeDockerClient → Claude Docker Container → Knowledge Graph
```

No API bridge needed - Claude Docker is integrated directly into Graphiti's infrastructure.

## Quick Start

### 1. Start Neo4j
```bash
docker-compose -f docker/docker-compose-native.yml up -d
```

### 2. Use Native Integration
```python
from graphiti_core import Graphiti
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig

# Configure Claude Docker
llm_config = LLMConfig(
    api_key="not-needed",
    model="claude-sonnet-4-0"
)

# Use natively in Graphiti
graphiti = Graphiti(
    uri="bolt://localhost:7687",
    user="neo4j",
    password="password",
    llm_client=ClaudeDockerClient(llm_config),
    embedder=GeminiEmbedder(gemini_config)
)
```

### 3. Run Examples
```bash
cd examples
python native_graphiti_integration.py
```

## Key Features

- **Native Integration**: First-class LLM provider in Graphiti
- **Local Processing**: All LLM operations run locally
- **Full Graphiti Support**: Entity extraction, deduplication, relationships
- **Islamic Text Focus**: Optimized for Islamic scholarly texts

## Documentation

- [Native Integration Guide](docs/NATIVE_INTEGRATION_GUIDE.md)
- [Implementation Comparison](docs/IMPLEMENTATION_COMPARISON.md)
- [Upgrade Guide](docs/UPGRADE_GUIDE.md)

## Legacy API Bridge

The API bridge approach is deprecated. For legacy support, see `docs/API_BRIDGE_LEGACY.md`.
EOF

# Step 6: Create upgrade guide
cat > "$CLAUDE_DOCKER_DIR/docs/UPGRADE_GUIDE.md" << 'EOF'
# Upgrade Guide: API Bridge → Native Integration

## What Changed?

### Before (API Bridge)
- Claude Docker ran as a separate API server
- Required docker-compose with API service
- Complex request/response translation

### After (Native Integration)
- Claude Docker is a native Graphiti LLM client
- Only Neo4j needs docker-compose
- Direct integration with Graphiti's infrastructure

## Migration Steps

### 1. Stop Old Services
```bash
docker-compose -f docker/docker-compose.yml down
```

### 2. Update Your Code

**Old way:**
```python
# Using API bridge
llm_config = LLMConfig(
    api_key="local",
    base_url="http://localhost:8000",  # API bridge
    model="claude-sonnet-4-0"
)
graphiti = Graphiti(
    llm_client=AnthropicClient(llm_config),  # Pretending to be Anthropic
    ...
)
```

**New way:**
```python
# Using native integration
from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient

llm_config = LLMConfig(
    api_key="not-needed",
    model="claude-sonnet-4-0"
)
graphiti = Graphiti(
    llm_client=ClaudeDockerClient(llm_config),  # Native!
    ...
)
```

### 3. Start Neo4j Only
```bash
docker-compose -f docker/docker-compose-native.yml up -d
```

### 4. Update CLAUDE.md
The new CLAUDE.md is configured for entity extraction, not code generation.

## Benefits

1. **Simpler**: No API translation layer
2. **Faster**: Direct execution
3. **More Reliable**: Fewer moving parts
4. **Better Integration**: Full Graphiti feature support

## Rollback

To rollback to API bridge:
1. Restore CLAUDE.md from backup
2. Use original docker-compose.yml
3. Change code back to AnthropicClient
EOF

# Step 7: Create test script
echo -e "\n6️⃣ Creating test script..."
cat > "$CLAUDE_DOCKER_DIR/test_native_integration.py" << 'EOF'
#!/usr/bin/env python3
"""Quick test of native integration"""

import asyncio
import sys
sys.path.append('/Users/farieds/Project/islamic-text-workflow/graphiti-main')

from graphiti_core.llm_client.claude_docker_client import ClaudeDockerClient
from graphiti_core.llm_client.config import LLMConfig
from graphiti_core.prompts.models import Message


async def test_claude_docker():
    print("🧪 Testing Native Claude Docker Integration")
    print("=" * 50)
    
    # Configure client
    config = LLMConfig(
        api_key="not-needed",
        model="claude-sonnet-4-0"
    )
    
    client = ClaudeDockerClient(config)
    
    # Test simple message
    messages = [
        Message(role="system", content="You are an AI that extracts entities from text."),
        Message(role="user", content="Extract entities from: The Prophet Muhammad taught in Medina.")
    ]
    
    print("\n📤 Sending test message...")
    try:
        response = await client._generate_response(messages)
        print(f"\n📥 Response: {response}")
        print("\n✅ Native integration is working!")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    asyncio.run(test_claude_docker())
EOF

chmod +x "$CLAUDE_DOCKER_DIR/test_native_integration.py"

# Step 8: Start Neo4j
echo -e "\n7️⃣ Starting Neo4j..."
docker-compose -f "$CLAUDE_DOCKER_DIR/docker/docker-compose-native.yml" up -d

# Step 9: Summary
echo -e "\n✅ Upgrade Complete!"
echo "===================="
echo ""
echo "Next steps:"
echo "1. Test native integration: python $CLAUDE_DOCKER_DIR/test_native_integration.py"
echo "2. Run examples: python $CLAUDE_DOCKER_DIR/examples/native_graphiti_integration.py"
echo "3. Check Neo4j: http://localhost:7474 (neo4j/password)"
echo ""
echo "Documentation updated:"
echo "- $CLAUDE_DOCKER_DIR/README.md"
echo "- $CLAUDE_DOCKER_DIR/docs/UPGRADE_GUIDE.md"
echo "- $CLAUDE_DOCKER_DIR/docs/NATIVE_INTEGRATION_GUIDE.md"
echo ""
echo "🎉 Claude Docker is now a native Graphiti LLM provider!"