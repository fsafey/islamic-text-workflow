# Batch Processing Demo Task

## Objective
Create a batch processor that:
1. Processes multiple projects in sequence
2. Runs different tasks on each project
3. Aggregates results
4. Sends completion notification

## Tasks to Automate
- Run tests on all projects
- Update dependencies
- Generate documentation
- Create summary report

## Requirements
- Process projects in parallel where possible
- Handle failures gracefully
- Track progress with status updates
- Send SMS with final summary

## Expected Output
- `batch_results.json` with all results
- Individual project reports
- SMS: "Batch complete: X/Y projects successful"