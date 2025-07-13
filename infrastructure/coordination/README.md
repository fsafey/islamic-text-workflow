# Claude Coordination System

This directory enables communication between multiple Claude instances running in parallel.

## Directory Structure

- `inbox/` - Tasks for Docker instance to process
- `outbox/` - Results and updates from Docker instance  
- `status/` - Current status files and progress updates
- `logs/` - Coordination logs and communication history
- `archive/` - Completed tasks and historical records

## How It Works

### Main Instance (This conversation)
1. Creates task files in `inbox/`
2. Monitors `outbox/` for results
3. Reads `status/` for progress updates
4. Coordinates overall workflow

### Docker Instance (`claude-docker`)
1. Checks `inbox/` for new tasks
2. Processes tasks autonomously
3. Writes results to `outbox/`
4. Updates `status/` with progress
5. Logs activities to `logs/`

## Usage Examples

### Assign Task to Docker Instance
```bash
# Main instance creates task
echo "Analyze academic files using task1" > .claude-coordination/inbox/analyze-academic-files.md

# Docker instance processes and responds
# Results appear in outbox/
```

### Check Docker Instance Status
```bash
# Read current status
cat .claude-coordination/status/current-status.txt

# Check latest results
ls .claude-coordination/outbox/
```

### Coordination Workflow
1. Main instance plans and coordinates
2. Docker instance executes heavy tasks
3. Both instances stay synchronized via file system
4. Results flow back for integration