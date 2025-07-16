# /gs - Graph Search

Search the Graphiti knowledge graph for relevant information.

## Usage
```
/gs "search query"
```

## Examples
```
/gs "database optimization"
/gs "Docker configuration issues"
/gs "API integration methods"
/gs "previous session decisions"
/gs "architecture patterns"
```

## Implementation
Execute the graph_search function from the integrated Graphiti commands:

```bash
source /workspace/tools/scripts/graphiti-commands.sh && graph_search "search query"
```

This command:
- Performs semantic and keyword search across the knowledge graph
- Searches through stored sessions, decisions, and project intelligence
- Works with both full Graphiti (Neo4j) and simplified file-based storage
- Returns ranked results with context and timestamps