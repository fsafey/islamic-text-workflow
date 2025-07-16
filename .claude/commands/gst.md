# /gst - Graph Status

Check the status of Graphiti knowledge graph system components.

## Usage
```
/gst
```

## Implementation
This command checks and reports:
- Neo4j database connectivity (bolt://localhost:7687)
- Claude Docker API status (http://localhost:8000)
- Graphiti MCP server status
- Knowledge graph statistics
- Memory file status (~/.claude/graphiti_memory.txt)