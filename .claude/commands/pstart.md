# /pstart - Project Session Start

Begin tracking a new development session with automatic project intelligence.

## Usage
```
/pstart "session-name"
```

## Examples
```
/pstart "database-optimization-sprint"
/pstart "graphiti-docker-integration"
/pstart "api-security-review"
/pstart "performance-analysis"
```

## Implementation
Execute the graph_create_session_summary function from the integrated Graphiti commands:

```bash
source /workspace/tools/scripts/graphiti-commands.sh && graph_create_session_summary "session-name"
```

This command:
- Creates a new ProjectSession entity in the knowledge graph
- Records Git context (branch, commit, status)
- Links to previous sessions and decisions
- Initializes session tracking for pdecision, pfeature, pproblem commands
- Creates timestamped session files in research/output/