# /pproblem - Project Problem Tracking

Track issues, blockers, and their solutions for project intelligence.

## Usage
```
/pproblem "problem description" "solution or next steps"
```

## Examples
```
/pproblem "Neo4j connection timeout in Docker" "Increased memory allocation and connection pool size"
/pproblem "Arabic text encoding issues" "Switched to UTF-8 with explicit BOM handling"
/pproblem "Claude Docker API rate limiting" "Implemented request queuing and retry logic"
```

## Implementation
This command:
- Creates ProjectProblem entity in knowledge graph
- Records problem context, severity, and solution
- Links to current session and related features
- Enables problem pattern analysis and solution reuse