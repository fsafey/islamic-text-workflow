# /claude2 - Launch Second Claude Instance

Launch an additional Claude Docker instance for parallel processing and specialized tasks.

## Usage
```
/claude2
```

## Available Modes
When launched, you can choose from:
1. **Interactive Shell** - Full Claude CLI access for parallel development
2. **Graphiti Worker** - JSON API for knowledge graph operations  
3. **Islamic Text Analysis** - Specialized Arabic/Islamic NLP processing
4. **Software Engineering** - Code analysis and development tasks

## Implementation
This command:
- Executes the interactive Claude Docker launcher script
- Provides mode selection for specialized processing
- Enables multi-agent coordination through shared knowledge graph
- Maintains context continuity across instances