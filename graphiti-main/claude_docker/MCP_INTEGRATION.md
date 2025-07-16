# Graphiti MCP Server with Claude Docker Integration

This document explains how to use the Graphiti MCP (Model Context Protocol) server with Claude Docker for persistent memory and knowledge graph capabilities.

## Overview

The Graphiti MCP server provides Claude with the ability to:
- Store and retrieve persistent memories across sessions
- Build knowledge graphs from conversations and documents
- Search for relevant information using semantic and graph-based queries
- Track temporal changes in knowledge over time

## Architecture

```
Claude Docker Container
       ↓
MCP Server (stdio)
       ↓
Graphiti Claude Docker Client
       ↓
Neo4j Graph Database
```

## Setup

### 1. Prerequisites

- Neo4j running (included in docker-compose files)
- Google API key for embeddings (set in .env)
- Claude Docker authenticated

### 2. Installation

The Graphiti MCP server is automatically installed when you rebuild the Claude Docker image:

```bash
cd infrastructure/claude-docker
docker-compose build --no-cache
```

### 3. Configuration

The MCP server is configured in `infrastructure/claude-docker/mcp-servers.txt`:

```bash
claude mcp add-json graphiti -s user "{...}"
```

## Usage

### Available MCP Tools

Once installed, Claude has access to these Graphiti tools:

#### 1. `graphiti.add_episode`
Store information in the knowledge graph:
```
add_episode(
    name="Meeting Notes",
    episode_body="Discussed the new architecture design...",
    source="message"
)
```

#### 2. `graphiti.search_nodes`
Search for entities and concepts:
```
search_nodes(
    query="architecture design patterns",
    num_results=10,
    entity_types=["Concept", "Decision"]
)
```

#### 3. `graphiti.search_facts`
Search for relationships and facts:
```
search_facts(
    query="design decisions made in Q1",
    num_results=20
)
```

#### 4. `graphiti.get_episodes`
Retrieve recent episodes:
```
get_episodes(
    last_n=5,
    group_id="project-alpha"
)
```

#### 5. `graphiti.clear_graph`
Clear all data (use with caution):
```
clear_graph()
```

#### 6. `graphiti.get_status`
Check system status:
```
get_status()
```

## Example Workflows

### 1. Software Development Memory

```python
# Store code review decisions
add_episode(
    name="Code Review - Auth Module",
    episode_body="Decided to use JWT tokens instead of sessions for stateless auth",
    source="message"
)

# Later, search for auth decisions
search_nodes(query="authentication decisions JWT")
```

### 2. Project Documentation

```python
# Store requirements
add_episode(
    name="Requirements - User Management",
    episode_body="System must support SSO integration with Azure AD",
    source="message"
)

# Search across all requirements
search_facts(query="SSO integration requirements")
```

### 3. Knowledge Building

```python
# Add technical knowledge
add_episode(
    name="Docker Best Practices",
    episode_body="Always use specific version tags in production, never 'latest'",
    source="message"
)

# Query accumulated knowledge
search_nodes(query="Docker production best practices")
```

## Custom Entity Types

The Claude Docker version includes predefined entity types:

- **Requirement**: Project requirements and specifications
- **Preference**: User preferences and settings
- **Procedure**: Step-by-step processes and workflows

These are automatically extracted when `--use-custom-entities` flag is enabled.

## Performance Considerations

1. **Concurrency**: Set to 5 concurrent operations to balance speed and reliability
2. **Embeddings**: Uses Gemini for fast, accurate semantic search
3. **Graph Size**: Neo4j can handle millions of nodes/edges efficiently

## Troubleshooting

### MCP Server Not Available

1. Check if Neo4j is running:
```bash
docker ps | grep neo4j
```

2. Verify MCP installation:
```bash
docker exec -it claude-docker claude mcp list
```

3. Check logs:
```bash
docker logs claude-docker
```

### Connection Issues

1. Ensure Neo4j is accessible:
   - Default: `bolt://localhost:7687`
   - Credentials: `neo4j` / `password`

2. Verify Google API key is set:
```bash
grep GOOGLE_API_KEY infrastructure/configs/.env
```

### Performance Issues

1. Reduce concurrency if seeing timeouts:
   - Edit `SEMAPHORE_LIMIT` in mcp-servers.txt

2. Clear old data periodically:
   - Use `clear_graph()` tool

## Integration with Graphiti Worker

The MCP server complements the Graphiti worker pattern:

- **MCP Server**: Interactive memory for Claude sessions
- **Worker Pattern**: Batch processing and pipeline integration

Both use the same underlying Graphiti + Claude Docker infrastructure.

## Security Notes

- All data stays local (no external API calls except embeddings)
- Neo4j data persists in Docker volumes
- Group IDs can namespace different projects

## Next Steps

1. Start using memory tools in your Claude sessions
2. Build domain-specific knowledge graphs
3. Query accumulated knowledge across sessions
4. Export graph data for analysis