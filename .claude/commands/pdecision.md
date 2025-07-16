# /pdecision - Project Decision Tracking

Track important technical and architectural decisions with rationale.

## Usage
```
/pdecision "decision description and rationale"
```

## Examples
```
/pdecision "Using Neo4j for knowledge graph due to temporal relationship support"
/pdecision "Chose Docker over local installation for better isolation and reproducibility"
/pdecision "Implementing Arabic NLP with spaCy due to RTL text handling capabilities"
```

## Implementation
This command:
- Creates a ProjectDecision entity in the knowledge graph
- Links to current session and Git context
- Stores decision rationale and alternatives considered
- Enables future decision searches and impact analysis