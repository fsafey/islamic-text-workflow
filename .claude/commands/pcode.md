# /pcode - Project Code Change Tracking

Track code modifications with descriptions and impact analysis.

## Usage
```
/pcode "file/path" "description of changes"
```

## Examples
```
/pcode "graphiti_mcp_server.py" "Added temporal relationship indexing for Islamic entities"
/pcode "docker-compose.yml" "Increased Neo4j memory allocation for large knowledge graphs"
/pcode "islamic_nlp/entities.py" "Implemented hadith chain validation algorithm"
```

## Implementation
This command:
- Creates CodeChange entity in knowledge graph
- Records file path, change description, and Git context
- Links to current session and related features/decisions
- Enables code change history and impact tracking