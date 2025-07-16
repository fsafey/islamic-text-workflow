#!/bin/bash
# Interactive Claude Docker Instance Launcher
# Creates a second Claude CLI instance you can work in directly

set -e

PROJECT_ROOT="/Users/farieds/Project/islamic-text-workflow"

echo "🚀 Launching Interactive Claude Docker Instance"
echo "================================================="

# Check if Claude Docker is authenticated
echo "🔐 Checking Claude Docker authentication..."
if ! docker run --rm \
    -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
    -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
    claude-docker:latest claude --version >/dev/null 2>&1; then
    echo "❌ Claude Docker not authenticated. Please run:"
    echo "   docker run -it --rm -v ~/.claude-docker/claude-home:/home/claude-user/.claude -v ~/.claude-docker/ssh:/home/claude-user/.ssh claude-docker:latest claude auth browser"
    exit 1
fi

echo "✅ Claude Docker is authenticated!"

# Choose the mode
echo ""
echo "🎯 Choose your Claude Docker mode:"
echo "1) Interactive Shell (full Claude CLI access)"
echo "2) Graphiti Worker Mode (JSON API processing)"
echo "3) Islamic Text Analysis Mode (specialized NLP)"
echo "4) Software Engineering Mode (code analysis)"
echo ""
read -p "Select mode (1-4): " mode

case $mode in
    1)
        echo "🖥️  Starting Interactive Claude Shell..."
        docker run -it --rm \
            --name claude-interactive-$(date +%s) \
            -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
            -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
            -v "$PROJECT_ROOT:/workspace/islamic-text-workflow:rw" \
            -w "/workspace/islamic-text-workflow" \
            claude-docker:latest \
            bash -c "echo '🎉 Welcome to Interactive Claude Docker!'; echo 'You can now use Claude CLI commands:'; echo '  claude --help'; echo '  claude \"Your prompt here\"'; echo '  exit  (to leave)'; echo ''; echo 'Project directory: /workspace/islamic-text-workflow'; echo 'Your files are mounted and accessible.'; echo ''; bash"
        ;;
    2)
        echo "🧠 Starting Graphiti Worker Mode..."
        echo "📝 This mode processes JSON requests for knowledge graph operations"
        echo "💡 Send JSON like: {\"operation\":\"add_episode\",\"params\":{\"episode_body\":\"Your text here\"}}"
        echo ""
        docker run -it --rm \
            --name claude-graphiti-worker-$(date +%s) \
            -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
            -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
            -v "$PROJECT_ROOT:/workspace/islamic-text-workflow:rw" \
            -w "/workspace/islamic-text-workflow" \
            --network="host" \
            claude-docker:latest \
            python graphiti-main/claude_docker/workers/claude_docker_worker_stdio.py --mode software_engineering
        ;;
    3)
        echo "📚 Starting Islamic Text Analysis Mode..."
        echo "🕌 Specialized for Arabic text, hadith, and Quranic analysis"
        docker run -it --rm \
            --name claude-islamic-nlp-$(date +%s) \
            -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
            -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
            -v "$PROJECT_ROOT:/workspace/islamic-text-workflow:rw" \
            -w "/workspace/islamic-text-workflow" \
            --network="host" \
            claude-docker:latest \
            python graphiti-main/claude_docker/workers/claude_docker_worker_stdio.py --mode nlp_pipeline
        ;;
    4)
        echo "💻 Starting Software Engineering Mode..."
        echo "🔧 Optimized for code analysis and development tasks"
        docker run -it --rm \
            --name claude-software-eng-$(date +%s) \
            -v "$HOME/.claude-docker/claude-home:/home/claude-user/.claude:rw" \
            -v "$HOME/.claude-docker/ssh:/home/claude-user/.ssh:rw" \
            -v "$PROJECT_ROOT:/workspace/islamic-text-workflow:rw" \
            -w "/workspace/islamic-text-workflow" \
            --network="host" \
            claude-docker:latest \
            python graphiti-main/claude_docker/workers/claude_docker_worker_stdio.py --mode software_engineering
        ;;
    *)
        echo "❌ Invalid selection. Exiting."
        exit 1
        ;;
esac

echo ""
echo "👋 Claude Docker session ended."
echo "💡 Run this script again anytime to start a new session!"