# Project Purpose

## Claude Docker: AI Coding Agent Starter Pack

This project is a complete Docker-based setup for autonomous AI development using Claude Code. It provides:

### Primary Purpose
- **Complete AI coding agent setup** with Claude Code in an isolated Docker container
- **Pre-configured MCP servers** for maximum coding productivity
- **Persistent conversation history** and authentication
- **Remote work notifications** via SMS when tasks complete

### Key Capabilities
1. **Serena MCP** - Advanced coding agent toolkit with project indexing and symbol manipulation
2. **Context7 MCP** - Pulls up-to-date, version-specific documentation and code examples
3. **Twilio MCP** - SMS notifications for long-running tasks
4. **Fully autonomous operation** with `--dangerously-skip-permissions`

### Target Use Case
The project appears to be used for Islamic text analysis and academic research workflows, as evidenced by:
- Islamic text processing demos
- Academic analysis file processing capabilities
- Text workflow enhancement features

### Container Architecture
- Runs Claude Code in Docker with full file system access
- Mounts host project directory as `/workspace`
- Persistent authentication and SSH keys
- Conda environment integration
- GPU support for ML tasks