# Claude Docker Authentication Guide

This guide explains how to authenticate Claude Docker, which is required before using the Graphiti Claude Docker integration.

## What is Claude Docker?

Claude Docker is a containerized version of Claude that runs locally on your machine. It requires authentication with Anthropic to function.

## Prerequisites

1. **Docker installed and running**
   ```bash
   docker --version  # Should show Docker version 20.10+
   ```

2. **Claude Docker image built**
   - This is typically done in the parent Islamic Text Workflow project
   - The image should be tagged as `claude-docker:latest`

## Authentication Process

### Step 1: Create Authentication Directory

```bash
# Create directory for Claude credentials
mkdir -p ~/.claude-docker/claude-home
mkdir -p ~/.claude-docker/ssh
```

### Step 2: Run Authentication

```bash
# Run the authentication command
docker run -it --rm \
  -v ~/.claude-docker/claude-home:/home/claude-user/.claude \
  -v ~/.claude-docker/ssh:/home/claude-user/.ssh \
  claude-docker:latest \
  claude auth browser
```

This will:
1. Open a browser window for Anthropic authentication
2. Save credentials to `~/.claude-docker/`
3. These credentials will be reused by the Claude Docker API

### Step 3: Verify Authentication

```bash
# Test that authentication worked
docker run --rm \
  -v ~/.claude-docker/claude-home:/home/claude-user/.claude:ro \
  -v ~/.claude-docker/ssh:/home/claude-user/.ssh:ro \
  claude-docker:latest \
  claude --version
```

You should see Claude's version information if authentication succeeded.

## Building Claude Docker Image

If you don't have the Claude Docker image, you'll need to build it:

### Option 1: From Islamic Text Workflow Project

If you have the full Islamic Text Workflow project:

```bash
cd /path/to/islamic-text-workflow
./build_claude_docker.sh
```

### Option 2: Standalone Build

Create a minimal Dockerfile:

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Create claude user
RUN useradd -m -s /bin/bash claude-user

# Switch to claude user
USER claude-user
WORKDIR /home/claude-user

# Install Claude CLI (replace with actual installation method)
# Note: You'll need the actual Claude CLI binary or installation script
COPY --chown=claude-user:claude-user claude /usr/local/bin/claude
RUN chmod +x /usr/local/bin/claude

ENTRYPOINT ["claude"]
```

**Important**: The actual Claude CLI binary must be obtained from Anthropic. The above is a template.

## Credential Storage

After authentication, your credentials are stored in:
- `~/.claude-docker/claude-home/` - Claude configuration
- `~/.claude-docker/ssh/` - SSH keys if needed

These directories are mounted read-only when running Claude Docker API.

## Security Considerations

1. **Protect credential directory**:
   ```bash
   chmod 700 ~/.claude-docker
   chmod -R 600 ~/.claude-docker/*
   ```

2. **Never commit credentials**: Add to `.gitignore`:
   ```
   .claude-docker/
   ~/.claude-docker/
   ```

3. **Credential expiration**: Credentials may expire and need re-authentication periodically

## Troubleshooting

### "Claude Docker not authenticated"

1. Check if credential files exist:
   ```bash
   ls -la ~/.claude-docker/claude-home/
   ```

2. Re-run authentication:
   ```bash
   docker run -it --rm \
     -v ~/.claude-docker/claude-home:/home/claude-user/.claude \
     -v ~/.claude-docker/ssh:/home/claude-user/.ssh \
     claude-docker:latest \
     claude auth browser
   ```

### "Permission denied" errors

Fix permissions:
```bash
sudo chown -R $USER:$USER ~/.claude-docker
chmod -R 700 ~/.claude-docker
```

### "Cannot find claude-docker:latest"

Build the image first (see Building Claude Docker Image section).

## Integration with Graphiti

Once authenticated, the Claude Docker API server will automatically use these credentials:

```yaml
# In docker-compose.yml
volumes:
  - ~/.claude-docker:/Users/$USER/.claude-docker:ro
```

The API server mounts credentials read-only for security.

## Next Steps

After successful authentication:
1. Start the Claude Docker API: `./scripts/start_claude_docker_api.sh`
2. Run tests: `python tests/comprehensive_test_suite.py`
3. Try examples: `python examples/quickstart_claude_docker_islamic.py`