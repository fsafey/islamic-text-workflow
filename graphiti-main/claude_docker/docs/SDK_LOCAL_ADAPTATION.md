# Adapting Claude Code SDK for Local Claude Docker

## Key Insight

The Claude Code SDK's architecture can be adapted to use our local Claude Docker containers instead of external APIs, giving us the best of both worlds: SDK's clean interface + local-only operation.

## How SDK Could Improve Our System

### 1. **Cleaner Subprocess Management**

Current Claude Docker approach:
```python
# Manual subprocess handling
process = await asyncio.create_subprocess_exec(
    *claude_cmd,
    stdin=asyncio.subprocess.PIPE,
    stdout=asyncio.subprocess.PIPE,
    stderr=asyncio.subprocess.PIPE
)
stdout, stderr = await process.communicate(input=prompt.encode())
```

With SDK adaptation:
```python
# SDK handles subprocess lifecycle
async for message in claude_local_query(
    prompt=prompt,
    backend="claude-docker"  # Use our local backend
):
    yield message
```

### 2. **Built-in Message Protocol**

The SDK provides a standardized message format that we could leverage:

```python
# SDK's message structure
class SDKMessage:
    type: Literal["text", "tool_use", "tool_result", "error"]
    content: str
    tool_name: Optional[str]
    tool_input: Optional[dict]
    
# This is cleaner than our current JSON parsing
```

### 3. **Enhanced Tool System**

Current tool handling:
```python
# Manual tool parsing and execution
if tools:
    tool_result = json.loads(response_text)
    return {"tool_result": tool_result}
```

SDK-style tool handling:
```python
# Automatic tool orchestration
options = LocalClaudeOptions(
    allowed_tools=["Read", "Write", "Bash"],
    tool_handler=GraphitiToolHandler(),  # Custom handler
    permission_mode="auto"
)
```

### 4. **Better Streaming Support**

The SDK's streaming architecture could improve our bulk operations:

```python
# Current: Manual streaming
for chunk in process_bulk(items):
    yield json.dumps({"progress": chunk})

# SDK-style: Built-in streaming protocol
async for event in stream_episodes(episodes):
    if event.type == "progress":
        yield event
    elif event.type == "result":
        handle_result(event)
```

## Implementation Strategy

### Step 1: Create Local Backend Adapter

```python
# claude_docker/sdk_adapter.py
from claude_code_sdk.core import BaseBackend, QueryOptions

class ClaudeDockerBackend(BaseBackend):
    """Adapter to use Claude Docker with SDK interface"""
    
    def __init__(self, docker_config):
        self.runner_path = "/workspace/claude_docker_runner.sh"
        self.config = docker_config
    
    async def query(self, prompt: str, options: QueryOptions):
        # Launch Claude Docker subprocess
        process = await self._start_claude_docker(options)
        
        # Use SDK's message protocol
        async for message in self._stream_messages(process, prompt):
            yield self._adapt_to_sdk_message(message)
```

### Step 2: Modify SDK's Provider Detection

```python
# Extend SDK to recognize local backend
class LocalClaudeProvider:
    @staticmethod
    def is_available():
        return os.path.exists("/workspace/claude_docker_runner.sh")
    
    @staticmethod
    def create_backend():
        return ClaudeDockerBackend(load_docker_config())
```

### Step 3: Integrate with Graphiti Worker

```python
# Enhanced worker using SDK interface
class GraphitiWorkerSDK:
    def __init__(self):
        # Use SDK with local backend
        self.claude = ClaudeSDK(
            provider="claude-docker",
            backend=ClaudeDockerBackend()
        )
    
    async def process_request(self, request):
        # Leverage SDK's features
        options = QueryOptions(
            system_prompt=self._get_system_prompt(request),
            tools=self._get_tools(request),
            streaming=request.get('streaming', False)
        )
        
        async for message in self.claude.query(
            prompt=request['prompt'],
            options=options
        ):
            yield self._process_sdk_message(message)
```

## Benefits of This Approach

### 1. **Standardized Interface**
- Consistent message format across all operations
- Better error handling with typed exceptions
- Cleaner code with less manual parsing

### 2. **Tool Orchestration**
- SDK's tool system can manage complex workflows
- Automatic retry and error handling for tools
- Better integration with MCP servers

### 3. **Improved Debugging**
- SDK provides better logging and tracing
- Standardized error messages
- Performance metrics built-in

### 4. **Future Compatibility**
- When Anthropic adds features to SDK, we get them automatically
- Community tools built for SDK will work with our local system
- Easier to switch between local and cloud if needed

### 5. **Better Worker Pattern**
- SDK's streaming fits perfectly with worker pattern
- Message queuing becomes simpler
- Progress tracking is standardized

## Migration Path

### Phase 1: Proof of Concept
1. Create minimal ClaudeDockerBackend
2. Test with simple queries
3. Verify message format compatibility

### Phase 2: Feature Parity
1. Implement tool support
2. Add streaming capabilities
3. Integrate with Graphiti worker

### Phase 3: Enhanced Features
1. Add SDK-specific optimizations
2. Implement advanced tool orchestration
3. Create unified configuration system

## Example: Unified Configuration

```yaml
# claude_docker/config/sdk_unified.yaml
claude:
  # Provider selection
  provider: local  # local | anthropic | bedrock | vertex
  
  # Local provider config
  local:
    backend: claude_docker
    runner: /workspace/claude_docker_runner.sh
    workers: 3
    
  # SDK features (work with any provider)
  features:
    streaming: true
    tools:
      enabled: true
      handlers:
        - graphiti_tools
        - mcp_servers
    message_format: sdk_v2
    
  # Graphiti integration
  graphiti:
    use_sdk_client: true
    sdk_options:
      auto_retry: true
      max_retries: 3
      timeout: 120
```

## Code Example: Complete Integration

```python
# Using SDK interface with local Claude Docker
from claude_code_sdk import ClaudeSDK
from claude_docker.backends import LocalBackend

# Initialize with local backend
sdk = ClaudeSDK(backend=LocalBackend())

# Use exactly like cloud SDK
async def process_with_graphiti():
    options = {
        "system_prompt": "You are processing knowledge graph data",
        "tools": ["add_episode", "search_nodes"],
        "streaming": True
    }
    
    async for message in sdk.query(
        "Extract entities from this text...",
        options=options
    ):
        if message.type == "tool_use":
            result = await handle_graphiti_tool(message)
            await sdk.send_tool_result(result)
        else:
            print(message.content)
```

## Conclusion

Adapting the Claude Code SDK to use our local Claude Docker backend would:
1. Provide a cleaner, more maintainable codebase
2. Enable advanced features like better tool orchestration
3. Maintain complete local-only operation
4. Future-proof our system for SDK enhancements
5. Make our system compatible with SDK ecosystem

This is definitely worth pursuing as it combines the best of both worlds!