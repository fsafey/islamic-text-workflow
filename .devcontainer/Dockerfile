# syntax=docker/dockerfile:1
FROM python:3.11-slim AS base

# Install only essential system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    bash \
    sudo \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-privileged user with sudo access
RUN groupadd -g 1000 developer && \
    useradd -m -s /bin/bash -u 1000 -g developer developer && \
    echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create workspace directory with proper ownership
WORKDIR /workspace
RUN chown -R developer:developer /workspace

USER developer

# Install only essential Python tools
RUN pip install --user --no-cache-dir \
    python-dotenv

# Development target
FROM base AS development

USER root

# Add package installer script for on-demand installation
COPY .devcontainer/install-packages.sh /usr/local/bin/install-packages.sh
RUN chmod +x /usr/local/bin/install-packages.sh

USER developer

# Setup bash configuration for development
RUN echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc && \
    echo 'export PYTHONPATH=/workspace:/workspace/graphiti-main' >> ~/.bashrc && \
    echo 'export ISLAMIC_TEXT_WORKFLOW=/workspace' >> ~/.bashrc && \
    echo 'alias ll="ls -alF"' >> ~/.bashrc && \
    echo 'alias la="ls -A"' >> ~/.bashrc && \
    echo 'alias l="ls -CF"' >> ~/.bashrc && \
    echo 'alias ..="cd .."' >> ~/.bashrc && \
    echo 'alias ...="cd ../.."' >> ~/.bashrc

# Create directories for persistent data
RUN mkdir -p /home/developer/.local/share && \
    mkdir -p /home/developer/.cache && \
    mkdir -p /home/developer/.vscode-server && \
    mkdir -p /home/developer/.claude-docker

# Set up Git configuration template
RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false && \
    git config --global core.autocrlf input

# Add healthcheck for container monitoring
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python3 --version || exit 1

# Set default command for interactive development
CMD ["sleep", "infinity"]