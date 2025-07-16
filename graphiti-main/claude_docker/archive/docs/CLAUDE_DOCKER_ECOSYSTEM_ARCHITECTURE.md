# Claude Docker Ecosystem: Architecture & Extensibility

## 🏗️ Core Architecture

The Claude Docker ecosystem is designed as a **modular, extensible platform** for AI-powered workflows:

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Docker Container                   │
├─────────────────────────────────────────────────────────────┤
│                         Claude CLI                           │
│                    (Entry Point & Router)                    │
│                            ↓                                 │
├─────────────────────────────────────────────────────────────┤
│                       Claude Engine                          │
│                  (Core NLP & Reasoning)                      │
│                            ↓                                 │
├─────────────────────────────────────────────────────────────┤
│                    MCP (Model Context Protocol)              │
│                     Tool Integration Layer                   │
│    ┌─────────┬──────────┬──────────┬──────────────────┐    │
│    │ Serena  │ Context7 │  Twilio  │   Custom Tools   │    │
│    │  (Code) │  (Web)   │  (SMS)   │   (Your Tools)   │    │
│    └─────────┴──────────┴──────────┴──────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 How Claude Docker Orchestration Works

### 1. **Configuration Layer** (`CLAUDE.md`)

The CLAUDE.md file acts as Claude's "personality" and capabilities configuration:

```markdown
## CAPABILITIES
- Text Analysis
- Code Generation
- Tool Use
- Custom Workflows

## OPERATION MODES
- Entity Extraction Mode
- Code Assistant Mode
- Research Mode
- Custom Modes (extensible)
```

### 2. **MCP (Model Context Protocol) System**

MCP is the extensibility framework that allows Claude to use external tools:

#### MCP Configuration (`.mcp.json`):
```json
{
  "servers": {
    "serena": {
      "type": "stdio",
      "command": "uvx",
      "args": ["--from", "git+https://github.com/oraios/serena", "serena"],
      "description": "Code indexing and search"
    },
    "context7": {
      "type": "stdio",
      "command": "uvx",
      "args": ["context7"],
      "description": "Web resource access"
    },
    "custom-tool": {
      "type": "stdio",
      "command": "python",
      "args": ["/path/to/your/tool.py"],
      "description": "Your custom tool"
    }
  }
}
```

### 3. **Agent Communication Protocol**

Each MCP server communicates via JSON-RPC over stdio:

```python
# Example MCP Server Implementation
class CustomMCPServer:
    def __init__(self):
        self.tools = {
            "analyze_hadith": self.analyze_hadith,
            "search_tafsir": self.search_tafsir
        }
    
    async def handle_request(self, request):
        method = request["method"]
        params = request.get("params", {})
        
        if method in self.tools:
            result = await self.tools[method](**params)
            return {"result": result}
        
    async def analyze_hadith(self, text, chain=None):
        # Custom hadith analysis logic
        return {
            "authenticity": "sahih",
            "narrators": [...],
            "related_hadiths": [...]
        }
```

## 🚀 Extensibility Mechanisms

### 1. **Adding New MCP Tools**

Create a new MCP server for specialized functionality:

```python
# islamic_scholar_mcp.py
import sys
import json
import asyncio

class IslamicScholarMCP:
    """MCP server for Islamic scholarly analysis"""
    
    def __init__(self):
        self.tools = [
            {
                "name": "analyze_isnad",
                "description": "Analyze hadith chain of narration",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "hadith_text": {"type": "string"},
                        "narrator_chain": {"type": "array"}
                    }
                }
            },
            {
                "name": "cross_reference_tafsir",
                "description": "Cross-reference Quranic interpretations",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "verse": {"type": "string"},
                        "tafsir_sources": {"type": "array"}
                    }
                }
            }
        ]
    
    async def run(self):
        # MCP server main loop
        async for line in self.read_stdin():
            request = json.loads(line)
            response = await self.handle_request(request)
            print(json.dumps(response))
            sys.stdout.flush()
```

### 2. **Registering the Tool**

Add to `.mcp.json`:
```json
{
  "servers": {
    "islamic-scholar": {
      "type": "stdio",
      "command": "python",
      "args": ["/workspace/mcp_servers/islamic_scholar_mcp.py"],
      "description": "Islamic scholarly analysis tools"
    }
  }
}
```

### 3. **Using in Claude**

Claude automatically discovers and can use the tool:
```
Human: Analyze the isnad of the hadith about seeking knowledge

Claude: I'll analyze the isnad of that hadith using the Islamic scholar tools.

[Claude automatically calls the analyze_isnad tool via MCP]
```