# Suggested Commands

## Installation & Setup
```bash
# Initial setup
cp .env.example .env
nano .env  # Add API keys
./scripts/install.sh

# Rebuild image after env changes
claude-docker --rebuild
claude-docker --rebuild --no-cache  # Without cache
```

## Basic Usage
```bash
# Start Claude in current project
claude-docker

# Resume previous conversation
claude-docker --continue

# With custom memory/GPU
claude-docker --memory 16g --gpus all
```

## SSH Setup (for Git operations)
```bash
# Create SSH keys for Claude Docker
mkdir -p ~/.claude-docker/ssh
ssh-keygen -t rsa -b 4096 -f ~/.claude-docker/ssh/id_rsa -N ''
cat ~/.claude-docker/ssh/id_rsa.pub  # Add to GitHub
ssh -T git@github.com -i ~/.claude-docker/ssh/id_rsa  # Test
```

## Development Commands
```bash
# Git operations (in container)
git status
git add .
git commit -m "feat: description"
git push

# Conda environment usage (in container)
conda env list
conda activate env_name
python script.py
```

## Docker Management
```bash
# Remove image to force rebuild
docker rmi claude-docker:latest

# Check running containers
docker ps

# View logs
docker logs container_id
```

## Project Configuration
```bash
# Edit global Claude settings
nano ~/.claude-docker/claude-home/settings.json
nano ~/.claude-docker/claude-home/CLAUDE.md

# Project-specific Claude settings
nano .claude/CLAUDE.md
```