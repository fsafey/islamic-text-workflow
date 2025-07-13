# Code Style and Conventions

## General Coding Principles (from CLAUDE.md)
- **SIMPLICITY IS LAW**: Maximize readability while minimizing functions and conditional logic
- **NO ERROR HANDLING**: Scripts must fail loudly and immediately
- **NO FALLBACKS OR ALTERNATIVE PATHS**
- **RELATIVE PATHS ONLY**: Never use absolute paths in code
- **SURGICAL EDITS**: Change the absolute minimum amount of code necessary

## Task Management
- **EARLY TERMINATION** is always preferable to flawed implementation
- **NEVER SIMPLIFY THE GOAL**: Do not modify, reduce, or simplify tasks
- **COMMIT FREQUENTLY** after completing major steps
- **ALWAYS PUSH** to remote after each commit

## Python/Conda Execution Protocol
- **MANDATORY CONDA BINARY**: Always use `$CONDA_PREFIX/bin/conda`
- **SCRIPT EXECUTION FORMAT**:
  ```bash
  ${CONDA_EXE:-conda} run --live-stream -n ENV_NAME python -u script.py
  ```
- **USE `dotenv`** to load .env files when required

## Git Commit Standards
- **Subject**: Imperative mood, capitalized, under 50 chars, no period
- **Format**: `feat(thing): Add new thing`
- **Body**: Explain what and why, not how. Wrap at 72 chars
- **Include example usage** for new scripts

## Documentation Requirements
- **`task_log.md`**: Update proactively at every step
- Must include: assumptions, challenges, solutions, discoveries, missing packages
- **COMMIT WHEN NECESSARY**: If task_log.md contains significant information