# Islamic Text Workflow Dev Container

## 🚀 Quick Start

Your development environment is ready! Here are the key commands:

### Development Commands
- `ws` - Go to workspace
- `islamic-dev` - Show welcome message
- `dev-status` - Check all services status
- `fresh-env` - Reload environment

### Project Commands (from graphiti-commands.sh)
- `gr "text"` - Remember in knowledge graph
- `gs "query"` - Search knowledge graph
- `gt "/path/file"` - Analyze text file
- `gst` - Show system status

### Claude Docker Commands
- `claude2` - Interactive Claude instance
- `claude-graphiti` - Graphiti worker mode
- `claude-islamic` - Islamic NLP mode
- `claude-engineering` - Software engineering mode

### Services Available
- **Neo4j Browser**: http://localhost:7474 (neo4j/islamictext2024)
- **Claude Docker API**: http://localhost:8000
- **Documentation Server**: http://localhost:8080

### Project Structure
- `/workspace` - Project root
- `/workspace/graphiti-main` - Graphiti framework
- `/workspace/claude-configs` - Claude instance configurations
- `/workspace/documentation` - Project documentation
- `/workspace/tools/scripts` - Development scripts

### Testing
- `test-graphiti` - Run Graphiti tests
- `test-knowledge` - Test knowledge graph connection

### Development Workflow
1. Use `claude2` for interactive development
2. Track insights with `gr "insight"`
3. Search knowledge with `gs "query"`
4. Analyze texts with `gt "file.txt"`
5. Check system with `gst`

Happy coding! 🕌
