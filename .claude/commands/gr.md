# /gr - Graph Remember

Store information in the Graphiti knowledge graph for future reference.

## Usage
```
/gr "information to remember"
```

## Examples
```
/gr "SESSION START: analyzing project architecture patterns"
/gr "DISCOVERY: Found three main optimization strategies for database performance"
/gr "DECISION: Using Neo4j for temporal relationship tracking"
/gr "INSIGHT: Code review revealed important security considerations"
```

## Implementation
Execute the graph_remember function from the integrated Graphiti commands:

```bash
source /workspace/tools/scripts/graphiti-commands.sh && graph_remember "information to remember"
```

This command:
- Stores the provided text in the knowledge graph with timestamp
- Works with both full Graphiti (Neo4j) and simplified file-based storage
- Integrates with session tracking and project intelligence
- Uses dynamic workspace path detection for dev container compatibility