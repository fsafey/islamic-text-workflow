#!/usr/bin/env python3
"""
NLP Pipeline Example - Using Graphiti as a worker in text processing pipelines

This example demonstrates how to use Graphiti Worker to:
1. Process text data from other pipeline components
2. Build knowledge graphs from unstructured text
3. Share graph data with downstream workers
4. Handle streaming and batch operations
"""

import json
import sys
import asyncio
from datetime import datetime
from typing import List, Dict, Any


class GraphitiPipelineClient:
    """Client for interacting with Graphiti worker in a pipeline"""
    
    def __init__(self):
        self.request_counter = 0
    
    def create_request(self, operation: str, params: dict) -> dict:
        """Create a properly formatted request"""
        self.request_counter += 1
        return {
            "id": f"req-{self.request_counter}",
            "operation": operation,
            "params": params
        }
    
    def send_request(self, request: dict):
        """Send request to stdout (would be piped to Graphiti worker)"""
        print(json.dumps(request))
        sys.stdout.flush()


async def text_extraction_pipeline():
    """Example: Extract and process text from various sources"""
    
    client = GraphitiPipelineClient()
    
    # Simulate text extracted from different sources
    documents = [
        {
            "source": "news_article_001.txt",
            "content": """
            Tech giant Apple announced its latest quarterly earnings today,
            beating analyst expectations. CEO Tim Cook attributed the success
            to strong iPhone sales in China and growing services revenue.
            The company reported $90 billion in revenue for Q4 2024.
            """,
            "metadata": {"date": "2024-01-15", "source": "TechNews"}
        },
        {
            "source": "research_paper_042.pdf", 
            "content": """
            Researchers at MIT have developed a new quantum computing algorithm
            that could revolutionize cryptography. Dr. Sarah Chen, lead researcher,
            stated that the breakthrough could make current encryption methods
            obsolete within five years. The team published their findings in
            Nature Quantum Computing.
            """,
            "metadata": {"date": "2024-01-10", "source": "MIT Research"}
        },
        {
            "source": "email_thread_123.eml",
            "content": """
            From: John Smith <john@techcorp.com>
            To: Engineering Team
            Subject: New Database Architecture
            
            Team, after reviewing our options, I recommend we migrate to
            PostgreSQL for our main application database. This will provide
            better performance for our analytical queries and reduce costs
            by 40%. Let's discuss in tomorrow's architecture meeting.
            """,
            "metadata": {"date": "2024-01-12", "internal": True}
        }
    ]
    
    # Process each document
    for doc in documents:
        request = client.create_request("add_episode", {
            "name": f"Document: {doc['source']}",
            "episode_body": doc['content'],
            "source_description": json.dumps(doc['metadata']),
            "episode_type": "text",
            "group_id": "document-processing",
            "entity_types": {
                "Person": {
                    "description": "A person mentioned in text",
                    "fields": ["name", "role", "organization"]
                },
                "Organization": {
                    "description": "A company or institution", 
                    "fields": ["name", "type", "location"]
                },
                "Event": {
                    "description": "An event or announcement",
                    "fields": ["name", "date", "participants"]
                },
                "Technology": {
                    "description": "A technology or tool",
                    "fields": ["name", "category", "purpose"]
                }
            }
        })
        
        client.send_request(request)


async def multi_worker_pipeline():
    """Example: Multiple workers processing different aspects"""
    
    client = GraphitiPipelineClient()
    
    # Simulate a pipeline where different workers handle different tasks
    
    # Worker 1: Sentiment Analysis (upstream) sends enriched text
    enriched_text = {
        "content": "The new product launch was extremely successful. Customer feedback has been overwhelmingly positive.",
        "sentiment": "positive",
        "confidence": 0.95,
        "entities_detected": ["new product", "customer feedback"]
    }
    
    # Worker 2: Graphiti processes and adds relationships
    request = client.create_request("add_episode", {
        "name": "Sentiment Analysis Result",
        "episode_body": json.dumps(enriched_text),
        "episode_type": "json",
        "group_id": "sentiment-pipeline",
        "entity_types": {
            "Product": {
                "description": "A product or service",
                "fields": ["name", "launch_date", "sentiment"]
            },
            "Feedback": {
                "description": "Customer feedback",
                "fields": ["sentiment", "confidence", "source"]
            }
        }
    })
    
    client.send_request(request)
    
    # Worker 3: Query the graph for related information
    search_request = client.create_request("search", {
        "query": "positive customer feedback successful launch",
        "num_results": 10,
        "search_type": "NODE_HYBRID_SEARCH_RRF"
    })
    
    client.send_request(search_request)


async def streaming_bulk_pipeline():
    """Example: Process large datasets with streaming"""
    
    client = GraphitiPipelineClient()
    
    # Simulate processing a large corpus (e.g., Wikipedia articles)
    articles = []
    for i in range(100):  # Simulate 100 articles
        articles.append({
            "name": f"Article_{i}",
            "episode_body": f"This is the content of article {i}. It contains information about various topics...",
            "source_description": f"Wikipedia article ID: {i}",
            "group_id": "wikipedia-import"
        })
    
    # Send bulk request with streaming
    bulk_request = client.create_request("add_episode_bulk", {
        "episodes": articles,
        "batch_size": 10  # Process 10 at a time
    })
    
    client.send_request(bulk_request)
    
    # The worker will stream progress updates:
    # {"id": "req-x", "status": "progress", "progress": {"processed": 10, "total": 100}}
    # {"id": "req-x", "status": "progress", "progress": {"processed": 20, "total": 100}}
    # ...


async def knowledge_graph_queries():
    """Example: Query the knowledge graph built by pipeline"""
    
    client = GraphitiPipelineClient()
    
    # Various query patterns for downstream workers
    queries = [
        # Entity search
        {
            "operation": "search",
            "params": {
                "query": "Tim Cook Apple CEO",
                "num_results": 5
            }
        },
        
        # Technology relationships
        {
            "operation": "search",
            "params": {
                "query": "quantum computing cryptography",
                "search_type": "EDGE_HYBRID_SEARCH_RRF",
                "num_results": 10
            }
        },
        
        # Time-based queries
        {
            "operation": "retrieve_episodes",
            "params": {
                "group_ids": ["document-processing"],
                "last_n": 5
            }
        },
        
        # Get specific entity
        {
            "operation": "get_entity",
            "params": {
                "entity_name": "Apple"
            }
        },
        
        # Get relationships
        {
            "operation": "get_edges_by_entity",
            "params": {
                "entity_id": "entity-uuid-here"  # Would be actual UUID
            }
        }
    ]
    
    for query in queries:
        request = client.create_request(query["operation"], query["params"])
        client.send_request(request)


async def coordinated_pipeline():
    """Example: Coordinated multi-stage pipeline"""
    
    client = GraphitiPipelineClient()
    
    # Stage 1: Document ingestion
    print("# Stage 1: Document Ingestion", file=sys.stderr)
    
    doc_request = client.create_request("add_episode", {
        "name": "Contract Analysis",
        "episode_body": """
        CONTRACT AGREEMENT
        
        This agreement is between TechCorp Inc. (Client) and DataSoft Solutions (Vendor)
        for the development of a customer analytics platform. The project will be
        completed in three phases over 6 months, with a total budget of $500,000.
        
        Phase 1: Data pipeline development (2 months) - $150,000
        Phase 2: Analytics engine (2 months) - $200,000  
        Phase 3: Dashboard and reporting (2 months) - $150,000
        
        Project lead: Sarah Johnson (TechCorp)
        Technical lead: Michael Chen (DataSoft)
        """,
        "episode_type": "text",
        "group_id": "contract-analysis",
        "entity_types": {
            "Organization": {
                "description": "Company or organization",
                "fields": ["name", "role", "type"]
            },
            "Person": {
                "description": "Individual person",
                "fields": ["name", "role", "organization"]
            },
            "Project": {
                "description": "Project or deliverable",
                "fields": ["name", "duration", "budget", "phases"]
            },
            "Contract": {
                "description": "Legal agreement",
                "fields": ["parties", "value", "duration"]
            }
        },
        "edge_types": {
            "CONTRACTS_WITH": {
                "description": "Organization contracts with another",
                "source_types": ["Organization"],
                "target_types": ["Organization"]
            },
            "LEADS": {
                "description": "Person leads project",
                "source_types": ["Person"],
                "target_types": ["Project"]
            },
            "WORKS_FOR": {
                "description": "Person works for organization",
                "source_types": ["Person"],
                "target_types": ["Organization"]
            }
        }
    })
    
    client.send_request(doc_request)
    
    # Stage 2: Relationship analysis
    print("# Stage 2: Relationship Analysis", file=sys.stderr)
    
    relationship_query = client.create_request("search", {
        "query": "contract parties relationships",
        "search_type": "EDGE_HYBRID_SEARCH_RRF",
        "num_results": 20
    })
    
    client.send_request(relationship_query)
    
    # Stage 3: Community detection
    print("# Stage 3: Community Detection", file=sys.stderr)
    
    community_request = client.create_request("build_communities", {})
    client.send_request(community_request)
    
    # Stage 4: Summary generation (would go to another worker)
    print("# Stage 4: Sending to summary generator...", file=sys.stderr)


async def dynamic_entity_pipeline():
    """Example: Pipeline with dynamic entity types from upstream"""
    
    client = GraphitiPipelineClient()
    
    # Upstream worker detected custom entity types
    upstream_config = {
        "detected_entities": {
            "Medication": {
                "description": "A medical drug or treatment",
                "fields": ["name", "dosage", "manufacturer"]
            },
            "Symptom": {
                "description": "A medical symptom",
                "fields": ["name", "severity", "duration"]
            },
            "Diagnosis": {
                "description": "A medical diagnosis",
                "fields": ["name", "icd_code", "date"]
            }
        },
        "detected_relationships": {
            "TREATS": {
                "source": "Medication",
                "target": "Symptom"
            },
            "INDICATES": {
                "source": "Symptom",
                "target": "Diagnosis"
            }
        }
    }
    
    # Process medical text with dynamic types
    medical_text = """
    Patient presented with severe headache and nausea. 
    Prescribed Ibuprofen 400mg for pain relief.
    Initial diagnosis suggests migraine (ICD-10: G43.909).
    """
    
    request = client.create_request("add_episode", {
        "name": "Medical Record Analysis",
        "episode_body": medical_text,
        "entity_types": upstream_config["detected_entities"],
        "edge_types": upstream_config["detected_relationships"],
        "group_id": "medical-records"
    })
    
    client.send_request(request)


def main():
    """Run the NLP pipeline examples"""
    
    print("=== Graphiti NLP Pipeline Examples ===", file=sys.stderr)
    print("# Note: Output is JSON requests that would be piped to Graphiti worker", file=sys.stderr)
    print("", file=sys.stderr)
    
    # Run examples
    examples = [
        ("Text Extraction Pipeline", text_extraction_pipeline),
        ("Multi-Worker Pipeline", multi_worker_pipeline),
        ("Streaming Bulk Pipeline", streaming_bulk_pipeline),
        ("Knowledge Graph Queries", knowledge_graph_queries),
        ("Coordinated Pipeline", coordinated_pipeline),
        ("Dynamic Entity Pipeline", dynamic_entity_pipeline)
    ]
    
    for name, example_func in examples:
        print(f"\n# === {name} ===", file=sys.stderr)
        asyncio.run(example_func())
    
    print("\n=== Examples Complete ===", file=sys.stderr)
    print("\nTo run in an actual pipeline:", file=sys.stderr)
    print("1. Start the NLP pipeline stack:", file=sys.stderr)
    print("   docker-compose -f docker/docker-compose-nlp-pipeline.yml up", file=sys.stderr)
    print("2. Pipe to Graphiti worker:", file=sys.stderr)
    print("   python nlp_pipeline_example.py | docker exec -i graphiti-nlp-worker-1 python /app/workers/graphiti_worker.py", file=sys.stderr)
    print("3. Or use in a full pipeline:", file=sys.stderr)
    print("   text-extractor | python nlp_pipeline_example.py | graphiti-worker | result-processor", file=sys.stderr)


if __name__ == "__main__":
    main()