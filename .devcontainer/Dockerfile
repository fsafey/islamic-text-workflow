FROM python:3.11-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    vim \
    postgresql-client \
    nodejs \
    npm \
    docker.io \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | sh

# Install Python dependencies
RUN pip install --upgrade pip \
    && pip install \
        anthropic \
        requests \
        psycopg2-binary \
        python-dotenv \
        pydantic \
        fastapi \
        uvicorn \
        neo4j \
        graphiti-core

# Create workspace directory
WORKDIR /workspace

# Create vscode user
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid vscode --shell /bin/bash --create-home vscode \
    && chown -R vscode:vscode /workspace

USER vscode