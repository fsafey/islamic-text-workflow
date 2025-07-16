# /pstart - Project Session Start

Begin tracking a new development session with automatic project intelligence.

## Usage
```
/pstart "session-name"
```

## Examples
```
/pstart "islamic-text-analysis-optimization"
/pstart "graphiti-docker-integration"
/pstart "hadith-chain-validation"
```

## Implementation
This command:
- Creates a new ProjectSession entity in the knowledge graph
- Records Git context (branch, commit, status)
- Links to previous sessions and decisions
- Initializes session tracking for pdecision, pfeature, pproblem commands