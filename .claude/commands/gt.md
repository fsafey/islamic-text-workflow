# /gt - Graph Text Analysis

Analyze any text content and store entities/relationships in the knowledge graph.

## Usage
```
/gt "path/to/text_file.txt"
/gt "direct text to analyze"
```

## Examples
```
/gt "documents/project_notes.md"
/gt "research/meeting_transcript.txt"
/gt "This is a sample text for entity extraction and analysis"
```

## Implementation
Execute the graph_analyze_text function from the integrated Graphiti commands:

```bash
source /workspace/tools/scripts/graphiti-commands.sh && graph_analyze_text "path/to/text_file.txt"
```

This command performs general text analysis including:
- Entity identification and extraction
- Concept extraction and relationship mapping
- Date and location recognition
- Person and organization identification
- Knowledge graph storage with entity linking
- Works with both files and direct text input
- Adaptable to various text types and domains