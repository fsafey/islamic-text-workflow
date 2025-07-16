# Streamlined Dockerfile for Claude Docker API with stdio workers
FROM python:3.11-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    docker.io \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn \
    pydantic \
    aiofiles

# The scripts will be mounted at runtime
ENV PYTHONUNBUFFERED=1

# Create logs directory
RUN mkdir -p /app/logs

# Run the enhanced stdio API server with logging
CMD ["python", "claude_docker_api_stdio_with_logging.py"]