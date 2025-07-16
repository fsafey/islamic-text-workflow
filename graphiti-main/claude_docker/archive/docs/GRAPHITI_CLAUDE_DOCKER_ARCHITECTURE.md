# Graphiti Claude Docker Architecture

## Overview

The Graphiti Claude Docker system is a modular knowledge graph framework that combines:
- **Graphiti Core**: Temporal knowledge graph engine with entity extraction
- **Claude Docker**: Local Claude LLM infrastructure for private, scalable processing
- **Neo4j/FalkorDB**: Graph database backends for storage and traversal
- **Hybrid Search**: Semantic embeddings + BM25 keyword search + graph relationships

## Core Architecture Components

### 1. Infrastructure Layer

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Compose Stack                      │
├─────────────────────┬────────────────┬──────────────────────┤
│   Claude Workers    │   API Bridge   │    Graph Database    │
│  (3x Parallel)      │  (Port 8000)   │   (Neo4j/FalkorDB)   │
└─────────────────────┴────────────────┴──────────────────────┘
```

**Components:**
- **Claude Workers**: Multiple parallel Claude containers for scalability
- **API Bridge**: Anthropic-compatible REST API exposing local Claude
- **Graph Database**: Neo4j (default) or FalkorDB for graph storage
- **Coordination**: File-based task distribution system

### 2. Core Modules

#### A. LLM Client Module (`graphiti_core.llm_client`)
```python
# Base configuration for any LLM provider
class LLMConfig:
    api_key: str
    base_url: str  # Key for local Claude: "http://localhost:8000"
    model: str
    temperature: float = 0.5

# Anthropic client configured for local Claude
class AnthropicClient(LLMClient):
    # Automatically routes to local API when base_url is set
```

#### B. Embedder Module (`graphiti_core.embedder`)
```python
# Modular embedder interface
class EmbedderConfig:
    api_key: str
    embedding_model: str

# Available embedders:
# - OpenAIEmbedder (default)
# - GeminiEmbedder (recommended for Claude Docker)
# - VoyageEmbedder
# - Custom implementations
```

#### C. Graph Driver Module (`graphiti_core.driver`)
```python
# Abstract interface for graph databases
class GraphDriver:
    async def execute_query()
    async def create_indices()
    async def upsert_nodes()
    async def upsert_edges()

# Implementations:
# - Neo4jDriver (recommended)
# - FalkorDriver
# - Custom drivers
```

#### D. Search Module (`graphiti_core.search`)
```python
# Configurable search strategies
class SearchConfig:
    search_type: SearchType  # node, edge, combined
    retrieval_method: RetrievalMethod  # keyword, semantic, hybrid
    reranker: Reranker  # rrf, graph_distance, custom
    limit: int
```

### 3. Data Model

#### Episodes (Input Units)
```python
class Episode:
    name: str
    episode_body: str | dict  # Text or JSON
    source: EpisodeType  # text, json, message
    source_description: str
    reference_time: datetime  # Temporal anchor
```

#### Graph Elements
```python
# Entities extracted from episodes
class Node:
    uuid: str
    name: str
    labels: list[str]  # Entity types
    summary: str
    created_at: datetime
    attributes: dict  # Custom properties

# Relationships between entities
class Edge:
    uuid: str
    source_node_uuid: str
    target_node_uuid: str
    relation_type: str
    fact: str  # Natural language description
    valid_at: datetime
    invalid_at: datetime | None  # Bi-temporal support
```

## Modular Design Patterns

### 1. Provider Abstraction Pattern

All external dependencies use abstract interfaces:

```python
# LLM Provider Interface
class LLMClient(ABC):
    @abstractmethod
    async def generate_response(prompt: str) -> str: ...

# Embedder Interface
class Embedder(ABC):
    @abstractmethod
    async def embed(text: str) -> list[float]: ...

# Graph Driver Interface  
class GraphDriver(ABC):
    @abstractmethod
    async def execute_query(query: str) -> list[dict]: ...
```

### 2. Configuration Injection Pattern

Each module accepts configuration objects:

```python
# Initialize with custom providers
graphiti = Graphiti(
    uri="bolt://localhost:7687",
    user="neo4j",
    password="password",
    llm_client=AnthropicClient(llm_config),  # Inject LLM
    embedder=GeminiEmbedder(embedder_config),  # Inject embedder
    driver=Neo4jDriver(driver_config)  # Inject graph driver
)
```

### 3. Entity/Edge Extension Pattern

Custom domain models via Pydantic:

```python
# Define domain-specific entities
class ScholarNode(BaseNode):
    birth_year: int
    death_year: int
    school_of_thought: str
    major_works: list[str]

# Define domain-specific relationships
class TeacherStudentEdge(BaseEdge):
    institution: str
    years: tuple[int, int]
    subjects: list[str]
```

### 4. Search Strategy Pattern

Pluggable search configurations:

```python
# Pre-built recipes
from graphiti_core.search.search_config_recipes import (
    NODE_HYBRID_SEARCH_RRF,
    EDGE_SEMANTIC_SEARCH,
    COMBINED_GRAPH_SEARCH
)

# Custom search configuration
custom_config = SearchConfig(
    search_type=SearchType.node,
    retrieval_method=RetrievalMethod.hybrid,
    reranker=Reranker.graph_distance,
    limit=10,
    center_node_uuid="..."  # For contextual reranking
)
```

## Use Case Adaptation Framework

### 1. Base Configuration Template

```python
# config/base_config.py
class GraphitiConfig:
    # Infrastructure
    neo4j_uri: str = "bolt://localhost:7687"
    neo4j_user: str = "neo4j"
    neo4j_password: str = "password"
    
    # LLM Configuration
    llm_provider: str = "anthropic"  # or "openai", "gemini"
    llm_base_url: str = "http://localhost:8000"  # For Claude Docker
    llm_model: str = "claude-sonnet-4-0"
    
    # Embedder Configuration
    embedder_provider: str = "gemini"  # or "openai", "voyage"
    embedding_model: str = "models/text-embedding-004"
    
    # Domain Configuration
    custom_entities: list[type] = []
    custom_edges: list[type] = []
    extraction_prompts: dict[str, str] = {}
```

### 2. Domain Variant Structure

```
variant_name/
├── config/
│   └── domain_config.py      # Domain-specific configuration
├── models/
│   ├── entities.py          # Custom entity definitions
│   └── relationships.py     # Custom edge definitions
├── prompts/
│   ├── extraction.py        # Domain-specific extraction prompts
│   └── summarization.py     # Custom summarization logic
├── processors/
│   └── domain_processor.py  # Custom processing logic
├── examples/
│   └── example_usage.py     # Usage examples
└── README.md               # Variant documentation
```

### 3. Variant Creation Process

1. **Define Domain Models**
2. **Configure Prompts**
3. **Set Processing Rules**
4. **Create Examples**
5. **Document Usage**

## Environment Configuration

### Required Environment Variables

```bash
# Graph Database
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password

# Claude Docker (when using local Claude)
CLAUDE_DOCKER_URL=http://localhost:8000

# Embeddings Provider
GOOGLE_API_KEY=your_key  # For Gemini embeddings
# OR
OPENAI_API_KEY=your_key  # For OpenAI embeddings

# Optional
USE_PARALLEL_RUNTIME=false  # Neo4j enterprise feature
```

### Docker Compose Configuration

```yaml
services:
  claude-api:
    build: ./claude-api
    ports:
      - "8000:8000"
    volumes:
      - coordination:/app/coordination
    environment:
      - WORKERS=3
      
  neo4j:
    image: neo4j:5.26-community
    ports:
      - "7474:7474"
      - "7687:7687"
    environment:
      - NEO4J_AUTH=neo4j/password
    volumes:
      - neo4j_data:/data
```

## Performance Optimization

### 1. Parallel Processing
- Multiple Claude workers for concurrent LLM calls
- Batch episode processing
- Async/await throughout the codebase

### 2. Caching Strategies
- Embedding cache for repeated texts
- LLM response cache for identical prompts
- Graph query result cache

### 3. Index Optimization
- Vector indices for semantic search
- Full-text indices for keyword search
- Graph indices for relationship traversal

## Security Considerations

### 1. Local Processing
- All LLM processing stays within your infrastructure
- No external API calls (except embeddings if needed)
- Complete data privacy

### 2. Access Control
- Database authentication required
- API authentication for production deployments
- Role-based access for different use cases

### 3. Data Isolation
- Separate graph databases per use case
- Namespace isolation within databases
- Temporal versioning for audit trails

## Monitoring & Debugging

### 1. Logging Configuration
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

### 2. Performance Metrics
- LLM response times
- Embedding generation speed
- Graph query performance
- Search result quality

### 3. Debug Tools
- Neo4j Browser for graph visualization
- API request/response logging
- Coordination system status files

## Next Steps

1. **Choose a Use Case**: Select from examples or define custom domain
2. **Configure Environment**: Set up Docker containers and environment variables
3. **Implement Domain Models**: Create custom entities and relationships
4. **Run Examples**: Test with sample data
5. **Scale as Needed**: Add more workers, optimize indices

For specific use case implementations, see:
- [Islamic Text Analysis](./variants/islamic_text/README.md)
- [Podcast Processing](./variants/podcast/README.md)
- [E-commerce Knowledge Graph](./variants/ecommerce/README.md)
- [Literary Text Analysis](./variants/literary/README.md)