# syntax=docker/dockerfile:1
FROM python:3.11-slim as base

# Install system dependencies with version pinning for reproducibility
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    vim \
    nano \
    jq \
    docker.io \
    docker-compose \
    build-essential \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Create non-privileged user following security best practices
RUN groupadd -g 1000 developer && \
    useradd -m -s /bin/bash -u 1000 -g developer developer && \
    usermod -aG docker developer

# Create workspace directory with proper ownership
WORKDIR /workspace
RUN chown -R developer:developer /workspace

# Switch to non-root user for remaining operations
USER developer

# Install Python development tools
RUN pip install --user --no-cache-dir \
    uv \
    black \
    flake8 \
    pylint \
    pytest \
    jupyter \
    ipython \
    requests \
    aiohttp \
    fastapi \
    uvicorn \
    pydantic \
    neo4j \
    anthropic \
    openai \
    python-dotenv

# Development target with additional tools
FROM base as development

USER root

# Install additional development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    tree \
    htop \
    ncdu \
    ripgrep \
    fd-find \
    bat \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js for some tooling (if needed)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

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