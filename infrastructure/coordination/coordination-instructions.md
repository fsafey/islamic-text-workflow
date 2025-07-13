# Claude Coordination Instructions

## For Docker Instance

When you start, check for coordination tasks:

```bash
# Check for new tasks
ls infrastructure/coordination/inbox/

# Read task instructions
cat infrastructure/coordination/inbox/task-academic-analysis.md

# Update status
echo "Docker instance started - processing academic analysis task" > infrastructure/coordination/status/docker-progress.txt
echo "$(date): Task started" >> infrastructure/coordination/logs/academic-analysis.log

# Process the task following the instructions in the task file

# When complete, write results
echo "Academic analysis completed successfully" > infrastructure/coordination/outbox/academic-analysis-results.md

# Update final status
echo "Task completed - awaiting new instructions" > infrastructure/coordination/status/docker-progress.txt
```

## For Main Instance

Monitor and coordinate:

```bash
# Check Docker instance progress  
cat infrastructure/coordination/status/docker-progress.txt

# Check for results
ls infrastructure/coordination/outbox/

# Read completed work
cat infrastructure/coordination/outbox/academic-analysis-results.md

# Assign new tasks
echo "Next task instructions..." > infrastructure/coordination/inbox/next-task.md
```

## Coordination Protocol

### Task Assignment
1. Main instance creates task file in `inbox/`
2. Docker instance checks inbox and processes
3. Progress updates written to `status/`
4. Results delivered to `outbox/`
5. Completed tasks moved to `archive/`

### Status Updates
- Docker instance updates status every 10 minutes
- Main instance monitors for progress
- Issues logged to `logs/` directory
- JSON status file updated regularly

### File Naming Convention
- Tasks: `task-[priority]-[description].md`
- Status: `docker-progress.txt`, `main-coordination.txt`
- Results: `[task-name]-results.md`
- Logs: `[task-name].log`

This system allows seamless coordination between parallel Claude instances!