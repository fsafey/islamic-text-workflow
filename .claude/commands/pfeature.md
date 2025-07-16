# /pfeature - Project Feature Tracking

Track feature development progress with status updates.

## Usage
```
/pfeature "feature-name" "status"
```

Valid statuses: `planned`, `in-progress`, `completed`, `blocked`

## Examples
```
/pfeature "hadith-chain-analysis" "in-progress"
/pfeature "arabic-entity-extraction" "completed"
/pfeature "scholar-relationship-mapping" "planned"
/pfeature "docker-auto-scaling" "blocked"
```

## Implementation
This command:
- Creates or updates ProjectFeature entity in knowledge graph
- Tracks feature lifecycle and dependencies
- Links to related decisions and problems
- Enables project progress monitoring and reporting