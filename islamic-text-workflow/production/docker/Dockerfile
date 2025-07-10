# ABOUTME: Docker image for Islamic Text Processing Agents with Claude Code
# ABOUTME: Based on claude-docker-model for reliable authentication and agent execution
# ABOUTME: Provides autonomous Islamic text processing environment with MCP server support

FROM node:20-slim

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3 \
    build-essential \
    sudo \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Install additional system packages if specified
ARG SYSTEM_PACKAGES=""
RUN if [ -n "$SYSTEM_PACKAGES" ]; then \
    echo "Installing additional system packages: $SYSTEM_PACKAGES" && \
    apt-get update && \
    apt-get install -y $SYSTEM_PACKAGES && \
    rm -rf /var/lib/apt/lists/*; \
else \
    echo "No additional system packages specified"; \
fi

# Create a non-root user with matching host UID/GID (claude-docker-model pattern)
ARG USER_UID=1000
ARG USER_GID=1000
RUN if getent group $USER_GID > /dev/null 2>&1; then \
        GROUP_NAME=$(getent group $USER_GID | cut -d: -f1); \
    else \
        groupadd -g $USER_GID claude-user && GROUP_NAME=claude-user; \
    fi && \
    if getent passwd $USER_UID > /dev/null 2>&1; then \
        usermod -l claude-user -d /home/claude-user -m $(getent passwd $USER_UID | cut -d: -f1) && \
        groupmod -n claude-user $GROUP_NAME 2>/dev/null || true; \
    else \
        useradd -m -s /bin/bash -u $USER_UID -g $GROUP_NAME claude-user; \
    fi && \
    echo "claude-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create app directory
WORKDIR /app

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Ensure npm global bin is in PATH
ENV PATH="/usr/local/bin:${PATH}"

# Create directories for configuration
RUN mkdir -p /app/.claude /home/claude-user/.claude

# Copy startup script
COPY scripts/startup.sh /app/
RUN chmod +x /app/startup.sh

# Copy .claude directory for runtime use
COPY .claude /app/.claude

# Copy .env file during build to bake credentials into the image (claude-docker-model pattern)
# This enables one-time setup - no need for .env in project directories
COPY .env /app/.env

# Copy CLAUDE.md template directly to final location (claude-docker-model pattern)
COPY .claude/CLAUDE.md /home/claude-user/.claude/CLAUDE.md

# Copy Claude authentication files from host (claude-docker-model pattern)
# Note: These must exist - host must have authenticated Claude Code first
COPY .claude.json /tmp/.claude.json

# Copy MCP server configuration files (as root)
COPY mcp-servers.txt /app/
COPY install-mcp-servers.sh /app/
RUN chmod +x /app/install-mcp-servers.sh

# Copy application files for Islamic text processing
COPY docker-claude-agent.js /app/
COPY orchestrator.js /app/
COPY lib/ /app/lib/
COPY claude-configs/ /app/claude-configs/
COPY package*.json /app/

# Install application dependencies
WORKDIR /app
RUN npm install --omit=dev --no-audit --no-fund \
    && npm cache clean --force

# Move auth files to proper location before switching user
RUN cp /tmp/.claude.json /home/claude-user/.claude.json && \
    rm -f /tmp/.claude.json

# Set proper ownership for everything
RUN chown -R claude-user /app /home/claude-user

# Switch to non-root user
USER claude-user

# Set HOME immediately after switching user
ENV HOME=/home/claude-user

# Install uv (Astral) for MCP server management (claude-docker-model pattern)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add claude-user's local bin to PATH
ENV PATH="/home/claude-user/.local/bin:${PATH}"

# Install MCP servers from configuration file
RUN /app/install-mcp-servers.sh

# Configure git user during build using host git config passed as build args (claude-docker-model pattern)
ARG GIT_USER_NAME=""
ARG GIT_USER_EMAIL=""
RUN if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then \
        echo "Configuring git user from host: $GIT_USER_NAME <$GIT_USER_EMAIL>" && \
        git config --global user.name "$GIT_USER_NAME" && \
        git config --global user.email "$GIT_USER_EMAIL" && \
        echo "Git configuration complete"; \
    else \
        echo "Warning: No git user configured on host system"; \
        echo "Run 'git config --global user.name \"Your Name\"' and 'git config --global user.email \"you@example.com\"' on host first"; \
    fi

# Set working directory to mounted volume
WORKDIR /workspace

# Environment variables will be passed from host
ENV NODE_ENV=production

# Start with Islamic text processing startup script
ENTRYPOINT ["/app/startup.sh"]