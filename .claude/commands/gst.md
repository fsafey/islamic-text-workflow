# /gst - Graph Status

Check the status of Graphiti knowledge graph system components.

## Usage
```
/gst
```

## Implementation
Execute the graph_status function from the integrated Graphiti commands:

```bash
source /workspace/tools/scripts/graphiti-commands.sh && graph_status
```

This command checks and reports:
- Neo4j database connectivity (bolt://localhost:7687)
- Claude Docker API status (http://localhost:8000)
- Graphiti MCP server status
- Knowledge graph statistics and memory file status
- Dynamic workspace path detection
- Full vs simplified mode indication