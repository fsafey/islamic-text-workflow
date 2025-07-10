# MCP Server Management for Islamic Text Processing

This document explains how to add and manage MCP (Model Context Protocol) servers in the Islamic Text Processing Claude Docker system.

## Quick Start

To add a new MCP server:

1. Edit `mcp-servers.txt`
2. Add your MCP server installation command
3. Rebuild the Docker image: `islamic-text-claude --agent orchestrator --rebuild`

## File Structure

- `mcp-servers.txt` - List of MCP server installation commands
- `install-mcp-servers.sh` - Script that processes and installs MCP servers
- `.env` - Environment variables (for MCP servers that need API keys)

## Adding MCP Servers

### Simple MCP Servers (No Environment Variables)

⚠️ **IMPORTANT**: Always use `-s user` flag to make MCPs available across all agents!

Add a line like this to `mcp-servers.txt`:
```bash
claude mcp add -s user <name> -- <command> <args>
```

Example:
```bash
claude mcp add -s user filesystem -- npx -y @modelcontextprotocol/server-filesystem
```

**Without `-s user`**: MCP will only be available in the Docker build directory
**With `-s user`**: MCP will be available in any workspace directory

### MCP Servers with Environment Variables

For servers that need API keys or configuration:
```bash
claude mcp add-json <name> -s user '{"command":"...","args":[...],"env":{"KEY":"${ENV_VAR}"}}'
```

Example:
```bash
claude mcp add-json github -s user '{"command":"npx","args":["-y","@modelcontextprotocol/server-github"],"env":{"GITHUB_TOKEN":"${GITHUB_TOKEN}"}}'
```

## Environment Variables

1. Add required variables to `.env`:
```env
GITHUB_TOKEN=your_token_here
ANTHROPIC_API_KEY=your_key_here
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
```

2. Reference them in `mcp-servers.txt` using `${VAR_NAME}` syntax

3. The install script will:
   - Skip servers with missing required env vars
   - Log which variables are missing
   - Continue installing other servers

## Currently Installed MCP Servers

### Core Islamic Text Processing Servers

- **Filesystem** - File access for Islamic text processing
- **Memory** - Inter-agent knowledge sharing for Islamic concepts
- **Browser** - Research capabilities for Islamic sources and validation
- **Context7** - Islamic scholarship documentation and reference lookup

### Optional Integration Servers

- **Twilio** - SMS notifications for long-running Islamic text processing (requires TWILIO_* env vars)
- **GitHub** - Version control for Islamic text processing results (requires GITHUB_TOKEN)

## Islamic Text Processing Specific MCP Servers

### Recommended Additional Servers

```bash
# PostgreSQL for advanced Islamic text database queries
claude mcp add-json postgres -s user '{"command":"npx","args":["-y","@modelcontextprotocol/server-postgres"],"env":{"POSTGRES_URL":"${SUPABASE_URL}"}}'

# Time/date server for Islamic calendar integration
claude mcp add -s user time -- npx -y @modelcontextprotocol/server-time

# Brave search for Islamic scholarship research
claude mcp add-json brave-search -s user '{"command":"npx","args":["-y","@modelcontextprotocol/server-brave-search"],"env":{"BRAVE_API_KEY":"${BRAVE_API_KEY}"}}'
```

### Custom Islamic Text Processing Servers

```bash
# Example: Custom Arabic text analysis server
claude mcp add-json arabic-nlp -s user '{"command":"python","args":["/path/to/arabic-nlp-server.py"],"env":{"ARABIC_MODEL_PATH":"${ARABIC_MODEL_PATH}"}}'

# Example: Islamic authority verification server
claude mcp add-json islamic-authority -s user '{"command":"node","args":["/path/to/islamic-authority-server.js"],"env":{"ISLAMIC_DB_URL":"${ISLAMIC_DB_URL}"}}'
```

## Environment Variables for Islamic Text Processing

### Required for Basic Operation
```env
# Supabase configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-key

# Claude authentication (handled automatically)
# CLAUDE_API_KEY is not needed - uses session-based auth
```

### Optional for Enhanced Features
```env
# SMS notifications for long processes
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
TWILIO_FROM_NUMBER=+1234567890
TWILIO_TO_NUMBER=+0987654321

# GitHub integration for versioning
GITHUB_TOKEN=your_github_token

# Search enhancement
BRAVE_API_KEY=your_brave_api_key

# Custom Islamic text processing
ARABIC_MODEL_PATH=/path/to/arabic/model
ISLAMIC_DB_URL=your_islamic_database_url
```

## Examples of Popular MCP Servers

### General Purpose Servers
```bash
# Filesystem access (already included)
claude mcp add -s user filesystem -- npx -y @modelcontextprotocol/server-filesystem

# Memory/knowledge base (already included)
claude mcp add -s user memory -- npx -y @modelcontextprotocol/server-memory

# Browser automation (already included)
claude mcp add -s user browser -- npx -y @modelcontextprotocol/server-browser

# Sequential thinking for complex Islamic analysis
claude mcp add -s user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
```

### Research and Documentation
```bash
# Context7 for documentation lookup (already included)
claude mcp add -s user context7 -- npx -y @modelcontextprotocol/server-context7

# Puppeteer for advanced web scraping
claude mcp add -s user puppeteer -- npx -y @modelcontextprotocol/server-puppeteer

# YouTube for Islamic lecture research
claude mcp add -s user youtube -- npx -y @modelcontextprotocol/server-youtube
```

### Database and Storage
```bash
# SQLite for local Islamic text databases
claude mcp add -s user sqlite -- npx -y @modelcontextprotocol/server-sqlite

# PostgreSQL for advanced queries (if using separate Islamic text DB)
claude mcp add-json postgres -s user '{"command":"npx","args":["-y","@modelcontextprotocol/server-postgres"],"env":{"POSTGRES_URL":"${ISLAMIC_POSTGRES_URL}"}}'
```

## Troubleshooting

### MCP Server Not Installing
- Check if required environment variables are set in `.env`
- Run `islamic-text-claude --agent orchestrator --rebuild` after changes
- Check Docker build logs for error messages

### Islamic Text Processing Specific Issues
- Ensure Supabase credentials are correct
- Verify book_enrichment_reservoir table exists
- Check agent logs for Islamic text processing errors

### Finding Islamic Text Processing MCP Servers
Look for:
- Arabic/Islamic NLP libraries that provide MCP integration
- Islamic database connectors
- Islamic calendar and date conversion tools
- Hadith and Quran reference systems

### Debugging MCP Installation
The install script logs:
- Which servers are being installed
- Missing environment variables for Islamic text processing
- Success/failure for each installation
- Continues even if one server fails

## Performance Considerations

### Memory Usage
- Each MCP server adds some memory overhead
- Consider memory limits when adding many servers
- Monitor with: `docker stats islamic-text-claude-*`

### Islamic Text Processing Optimization
- Use memory MCP server for caching Islamic concepts
- Limit browser automation to essential research tasks
- Consider batch processing for large Islamic text collections

## Security Notes

### Environment Variables
- Never commit `.env` files with real credentials
- Use separate credentials for Islamic text processing
- Consider using read-only database credentials for research agents

### MCP Server Security
- Only install MCP servers from trusted sources
- Review server code before installation
- Use separate SSH keys for Islamic text processing git operations

---

**Note**: This MCP configuration is optimized for Islamic scholarly text processing. The servers are selected to support academic rigor in Islamic text analysis, bibliographic research, and metadata enrichment.