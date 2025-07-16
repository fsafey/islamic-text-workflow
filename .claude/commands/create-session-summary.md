# /create-session-summary - Create Timestamped Session Summary

Generate a timestamped session summary template with proper chronological formatting.

## Usage
```
/create-session-summary "descriptive-session-title"
```

## Examples
```
/create-session-summary "islamic-manuscript-analysis"
/create-session-summary "neo4j-performance-optimization"
/create-session-summary "claude-instance-coordination"
```

## Implementation
This command creates a timestamped session summary file:

**File Location**: `research/output/YYYY-MM-DD_HHMMSS-session-[title].md`
**Header Format**: `# YYYY-MM-DD_HHMMSS - [Session Title]`

**Template Includes**:
- Timestamp-prefixed title for chronological sorting
- Session type, duration, and knowledge graph entry count
- Structured sections for objectives, discoveries, technical changes
- Knowledge graph insights and session validation
- Proper markdown formatting for documentation standards

**Benefits**:
- Chronological file sorting by timestamp
- Consistent documentation format across all sessions
- Easy temporal reference and search capabilities
- Professional technical documentation standards