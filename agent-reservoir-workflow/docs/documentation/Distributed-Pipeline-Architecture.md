# Distributed Islamic Text Processing Pipeline

## 🎯 **Problem Statement**
Current workflow depends on single agent to process all 1500 books sequentially, causing reliability issues. Need distributed system where Make.com orchestrates and local agents act as specialized processing nodes.

## 🏗️ **Architecture Overview**

```
Make.com Orchestrator
    ↓ (Webhook calls)
Local Agent Node 1: Research Specialist
    ↓ (Results back to Make.com)
Local Agent Node 2: Analysis Specialist  
    ↓ (Results back to Make.com)
Local Agent Node 3: SQL Generation Specialist
    ↓ (Results back to Make.com)
Database Update & Completion
```

## 📋 **Pipeline Stages**

### Stage 1: Book Queue Management (Make.com)
- Manage queue of 1500 books
- Distribute books to available agents
- Track processing status
- Handle retries and failures

### Stage 2: Research Node (Local Agent)
- **Input**: Book title, author, UUID
- **Task**: WebSearch research and verification
- **Output**: Research findings, book context
- **Webhook**: `POST /webhook/research-complete`

### Stage 3: Analysis Node (Local Agent)  
- **Input**: Book data + research findings
- **Task**: Hybrid academic analysis (conceptual network + structural flowchart)
- **Output**: Complete hybrid analysis
- **Webhook**: `POST /webhook/analysis-complete`

### Stage 4: SQL Generation Node (Local Agent)
- **Input**: Book data + analysis results
- **Task**: Generate SQL enrichment following criteria
- **Output**: SQL update statements
- **Webhook**: `POST /webhook/sql-complete`

### Stage 5: Database Operations (Make.com)
- Execute SQL updates
- Verify completion
- Update processing logs
- Trigger next book in queue

## 🔄 **Bidirectional Communication**

### Make.com → Local Agent
```bash
# Make.com calls local webhook endpoints
POST http://localhost:3001/agent/research
POST http://localhost:3001/agent/analysis  
POST http://localhost:3001/agent/sql-generation
```

### Local Agent → Make.com
```bash
# Agent calls Make.com webhooks when complete
POST https://hook.us2.make.com/webhook/research-complete
POST https://hook.us2.make.com/webhook/analysis-complete
POST https://hook.us2.make.com/webhook/sql-complete
```

## 🤖 **Specialized Agent Nodes**

### Research Agent Node
```javascript
// Endpoint: POST /agent/research
{
  "task_id": "research-uuid",
  "book_data": {
    "id": "book-uuid",
    "title": "Al-Mar'a fi Nahj Al-Balagha", 
    "author": "Dr. Najwa Saleh Al-Jawad"
  },
  "webhook_url": "https://hook.us2.make.com/webhook/research-complete"
}
```

**Agent Tasks:**
1. WebSearch book title and author
2. Verify book information
3. Gather contextual information
4. Return research findings

**Response:**
```javascript
{
  "task_id": "research-uuid",
  "status": "completed",
  "research_findings": {
    "verified": true,
    "context": "Book context information",
    "related_works": ["work1", "work2"],
    "scholarly_context": "Academic context"
  },
  "processing_time": 180
}
```

### Analysis Agent Node
```javascript
// Endpoint: POST /agent/analysis
{
  "task_id": "analysis-uuid",
  "book_data": {
    "id": "book-uuid",
    "title": "Al-Mar'a fi Nahj Al-Balagha",
    "author": "Dr. Najwa Saleh Al-Jawad"
  },
  "research_findings": {
    // From research stage
  },
  "webhook_url": "https://hook.us2.make.com/webhook/analysis-complete"
}
```

**Agent Tasks:**
1. Create conceptual network analysis
2. Build structural flowchart
3. Generate academic description
4. Save analysis file

**Response:**
```javascript
{
  "task_id": "analysis-uuid", 
  "status": "completed",
  "analysis": {
    "conceptual_network": {
      "central_node": "...",
      "primary_concepts": [...],
      "secondary_concepts": [...],
      "network_description": "..."
    },
    "structural_flowchart": "...",
    "academic_description": "..."
  },
  "file_path": "./academic-analyses/Book-Title-Hybrid-Analysis.md",
  "processing_time": 480
}
```

### SQL Generation Agent Node  
```javascript
// Endpoint: POST /agent/sql-generation
{
  "task_id": "sql-uuid",
  "book_data": {
    "id": "book-uuid",
    "title": "Al-Mar'a fi Nahj Al-Balagha",
    "author": "Dr. Najwa Saleh Al-Jawad"
  },
  "analysis": {
    // From analysis stage
  },
  "webhook_url": "https://hook.us2.make.com/webhook/sql-complete"
}
```

**Agent Tasks:**
1. Apply enrichment criteria
2. Generate title aliases
3. Create comprehensive keywords
4. Build SQL UPDATE statement

**Response:**
```javascript
{
  "task_id": "sql-uuid",
  "status": "completed", 
  "sql_data": {
    "title_alias": "Women in Nahj al-Balagha; Al-Mar'a fi Nahj Al-Balagha; ...",
    "keywords": ["Women in Islam", "Nahj al-Balagha", ...],
    "description": "This scholarly work examines..."
  },
  "sql_file": "./sql-updates/Book-Title-enrichment.sql",
  "processing_time": 120
}
```

## 🚀 **Make.com Scenario Architecture**

### Main Orchestrator Scenario
```
Trigger: Schedule (every 5 minutes)
    ↓
Module 1: Get Next Book from Queue
    ↓
Module 2: Call Research Agent (HTTP Request)
    ↓
Module 3: Wait for Research Webhook
    ↓
Module 4: Call Analysis Agent (HTTP Request) 
    ↓
Module 5: Wait for Analysis Webhook
    ↓
Module 6: Call SQL Generation Agent (HTTP Request)
    ↓
Module 7: Wait for SQL Webhook
    ↓
Module 8: Execute Database Update
    ↓
Module 9: Mark Book Complete & Queue Next
```

### Webhook Handler Scenarios

**Research Complete Handler:**
```
Trigger: Webhook (research-complete)
    ↓
Module 1: Update Processing Log
    ↓
Module 2: Trigger Analysis Stage
```

**Analysis Complete Handler:**
```
Trigger: Webhook (analysis-complete)
    ↓  
Module 1: Update Processing Log
    ↓
Module 2: Trigger SQL Generation Stage
```

**SQL Complete Handler:**
```
Trigger: Webhook (sql-complete)
    ↓
Module 1: Execute Database Update
    ↓
Module 2: Mark Book Complete
    ↓
Module 3: Queue Next Book
```

## 📊 **Queue Management**

### Book Processing Queue Table
```sql
CREATE TABLE book_processing_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id),
  status TEXT DEFAULT 'pending', -- pending, research, analysis, sql, completed, failed
  priority INTEGER DEFAULT 0,
  assigned_agent TEXT,
  research_task_id UUID,
  analysis_task_id UUID, 
  sql_task_id UUID,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  error_count INTEGER DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Processing Status Tracking
```sql
CREATE TABLE agent_task_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL,
  task_type TEXT NOT NULL, -- research, analysis, sql
  book_id UUID REFERENCES books(id),
  agent_id TEXT,
  status TEXT, -- started, completed, failed
  input_data JSONB,
  output_data JSONB,
  processing_time INTEGER, -- seconds
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);
```

## 🔧 **Local Agent Webhook Server**

### Express.js Server Setup
```javascript
const express = require('express');
const app = express();
app.use(express.json());

// Research endpoint
app.post('/agent/research', async (req, res) => {
  const { task_id, book_data, webhook_url } = req.body;
  
  // Process asynchronously
  processResearchTask(task_id, book_data, webhook_url);
  
  // Immediate response
  res.json({ 
    status: 'accepted',
    task_id: task_id,
    estimated_time: 180 
  });
});

// Analysis endpoint  
app.post('/agent/analysis', async (req, res) => {
  const { task_id, book_data, research_findings, webhook_url } = req.body;
  
  processAnalysisTask(task_id, book_data, research_findings, webhook_url);
  
  res.json({ 
    status: 'accepted',
    task_id: task_id,
    estimated_time: 480 
  });
});

// SQL generation endpoint
app.post('/agent/sql-generation', async (req, res) => {
  const { task_id, book_data, analysis, webhook_url } = req.body;
  
  processSQLGenerationTask(task_id, book_data, analysis, webhook_url);
  
  res.json({ 
    status: 'accepted', 
    task_id: task_id,
    estimated_time: 120 
  });
});

app.listen(3001, () => {
  console.log('Agent webhook server running on port 3001');
});
```

## 📈 **Scalability Benefits**

### Parallel Processing
- Multiple books processed simultaneously
- Each stage can run independently
- Agent specialization improves quality

### Fault Tolerance
- Individual task failures don't crash entire workflow
- Retry logic for failed tasks
- Queue management handles load balancing

### Resource Optimization
- Agents only loaded when needed
- Specialized context for each task type
- Reduced memory usage per task

## 🎯 **Success Metrics**

### Performance Targets
- **Throughput**: 50+ books per hour
- **Reliability**: 99%+ completion rate
- **Quality**: Consistent analysis standards
- **Scalability**: Handle 1500+ book backlog

### Monitoring Dashboard
- Books in queue by status
- Average processing time per stage
- Agent performance metrics
- Error rates and retry statistics

---

This distributed architecture transforms the monolithic workflow into a scalable, fault-tolerant pipeline that can reliably process your 1500-book collection.