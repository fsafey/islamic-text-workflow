# Make.com Distributed Pipeline Scenarios

## 🎯 **Pipeline Overview**

```
Make.com Orchestrator → Local Research Agent → Make.com → Local Analysis Agent → Make.com → Local SQL Agent → Make.com → Database Update
```

## 📋 **Required Make.com Scenarios**

### 1. Main Orchestrator Scenario
### 2. Research Complete Webhook Handler
### 3. Analysis Complete Webhook Handler  
### 4. SQL Complete Webhook Handler
### 5. Queue Management Scenario

---

## 🚀 **Scenario 1: Main Orchestrator**

**Name**: `Islamic-Text-Pipeline-Orchestrator`
**Trigger**: Schedule (every 2 minutes)

### Modules:

**Module 1: Get Next Book from Queue**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?status=eq.pending&order=priority.desc,created_at.asc&limit=1`
- Headers:
  - `Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
  - `Content-Type: application/json`

**Module 2: Check if Book Available**
- Type: Filter
- Condition: `{{1.length}} > 0`

**Module 3: Get Book Details**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/books?id=eq.{{1.0.book_id}}`
- Headers:
  - `Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

**Module 4: Mark Book as Research Stage**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?id=eq.{{1.0.id}}`
- Body:
```json
{
  "status": "research",
  "research_task_id": "{{newUUID()}}",
  "started_at": "{{formatDate(now; "ISO")}}"
}
```

**Module 5: Call Research Agent**
- Type: HTTP Request
- Method: POST
- URL: `http://localhost:3001/agent/research`
- Body:
```json
{
  "task_id": "{{4.research_task_id}}",
  "book_data": {
    "id": "{{3.0.id}}",
    "title": "{{3.0.title}}",
    "author": "{{3.0.author_name}}"
  },
  "webhook_url": "https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/research-complete"
}
```

**Module 6: Log Research Task Started**
- Type: HTTP Request
- Method: POST
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/agent_task_logs`
- Body:
```json
{
  "task_id": "{{4.research_task_id}}",
  "task_type": "research",
  "book_id": "{{3.0.id}}",
  "agent_id": "local-research-agent",
  "status": "started",
  "input_data": {{5}},
  "created_at": "{{formatDate(now; "ISO")}}"
}
```

---

## 📞 **Scenario 2: Research Complete Webhook Handler**

**Name**: `Research-Complete-Handler`
**Trigger**: Webhook
**Webhook URL**: `https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/research-complete`

### Modules:

**Module 1: Parse Research Results**
- Type: Custom Function
- Code:
```javascript
const data = input;
return {
  task_id: data.task_id,
  status: data.status,
  research_findings: data.research_findings,
  processing_time: data.processing_time
};
```

**Module 2: Update Task Log**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/agent_task_logs?task_id=eq.{{1.task_id}}`
- Body:
```json
{
  "status": "{{1.status}}",
  "output_data": {{1.research_findings}},
  "processing_time": "{{1.processing_time}}",
  "completed_at": "{{formatDate(now; "ISO")}}"
}
```

**Module 3: Get Queue Record**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?research_task_id=eq.{{1.task_id}}`

**Module 4: Check Research Success**
- Type: Filter
- Condition: `{{1.status}} = "completed"`

**Module 5: Generate Analysis Task ID**
- Type: Custom Function
- Code:
```javascript
return {
  analysis_task_id: require('crypto').randomUUID()
};
```

**Module 6: Update Queue to Analysis Stage**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?id=eq.{{3.0.id}}`
- Body:
```json
{
  "status": "analysis",
  "analysis_task_id": "{{5.analysis_task_id}}"
}
```

**Module 7: Get Book Details for Analysis**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/books?id=eq.{{3.0.book_id}}`

**Module 8: Call Analysis Agent**
- Type: HTTP Request
- Method: POST
- URL: `http://localhost:3001/agent/analysis`
- Body:
```json
{
  "task_id": "{{5.analysis_task_id}}",
  "book_data": {
    "id": "{{7.0.id}}",
    "title": "{{7.0.title}}",
    "author": "{{7.0.author_name}}"
  },
  "research_findings": {{1.research_findings}},
  "webhook_url": "https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/analysis-complete"
}
```

---

## 🧠 **Scenario 3: Analysis Complete Webhook Handler**

**Name**: `Analysis-Complete-Handler`
**Trigger**: Webhook
**Webhook URL**: `https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/analysis-complete`

### Modules:

**Module 1: Parse Analysis Results**
- Type: Custom Function
- Code:
```javascript
const data = input;
return {
  task_id: data.task_id,
  status: data.status,
  analysis: data.analysis,
  file_path: data.file_path,
  processing_time: data.processing_time
};
```

**Module 2: Update Task Log**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/agent_task_logs?task_id=eq.{{1.task_id}}`
- Body:
```json
{
  "status": "{{1.status}}",
  "output_data": {{1.analysis}},
  "processing_time": "{{1.processing_time}}",
  "completed_at": "{{formatDate(now; "ISO")}}"
}
```

**Module 3: Get Queue Record**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?analysis_task_id=eq.{{1.task_id}}`

**Module 4: Check Analysis Success**
- Type: Filter
- Condition: `{{1.status}} = "completed"`

**Module 5: Generate SQL Task ID**
- Type: Custom Function
- Code:
```javascript
return {
  sql_task_id: require('crypto').randomUUID()
};
```

**Module 6: Update Queue to SQL Stage**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?id=eq.{{3.0.id}}`
- Body:
```json
{
  "status": "sql",
  "sql_task_id": "{{5.sql_task_id}}"
}
```

**Module 7: Get Book Details for SQL**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/books?id=eq.{{3.0.book_id}}`

**Module 8: Call SQL Generation Agent**
- Type: HTTP Request
- Method: POST
- URL: `http://localhost:3001/agent/sql-generation`
- Body:
```json
{
  "task_id": "{{5.sql_task_id}}",
  "book_data": {
    "id": "{{7.0.id}}",
    "title": "{{7.0.title}}",
    "author": "{{7.0.author_name}}"
  },
  "analysis": {{1.analysis}},
  "webhook_url": "https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/sql-complete"
}
```

---

## 💾 **Scenario 4: SQL Complete Webhook Handler**

**Name**: `SQL-Complete-Handler`
**Trigger**: Webhook
**Webhook URL**: `https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/sql-complete`

### Modules:

**Module 1: Parse SQL Results**
- Type: Custom Function
- Code:
```javascript
const data = input;
return {
  task_id: data.task_id,
  status: data.status,
  sql_data: data.sql_data,
  sql_file: data.sql_file,
  processing_time: data.processing_time
};
```

**Module 2: Update Task Log**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/agent_task_logs?task_id=eq.{{1.task_id}}`
- Body:
```json
{
  "status": "{{1.status}}",
  "output_data": {{1.sql_data}},
  "processing_time": "{{1.processing_time}}",
  "completed_at": "{{formatDate(now; "ISO")}}"
}
```

**Module 3: Get Queue Record**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?sql_task_id=eq.{{1.task_id}}`

**Module 4: Check SQL Success**
- Type: Filter
- Condition: `{{1.status}} = "completed"`

**Module 5: Execute Database Update**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/books?id=eq.{{3.0.book_id}}`
- Body:
```json
{
  "title_alias": "{{1.sql_data.title_alias}}",
  "keywords": "{{1.sql_data.keywords}}",
  "description": "{{1.sql_data.description}}",
  "updated_at": "{{formatDate(now; "ISO")}}"
}
```

**Module 6: Mark Book as Completed**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?id=eq.{{3.0.id}}`
- Body:
```json
{
  "status": "completed",
  "completed_at": "{{formatDate(now; "ISO")}}"
}
```

**Module 7: Send Completion Notification**
- Type: Email
- To: `admin@islamiclibrary.com`
- Subject: `Book Processing Complete: {{3.0.book_id}}`
- Body:
```
Book processing completed successfully!

Book ID: {{3.0.book_id}}
Total Processing Time: {{add(add({{research_time}}, {{analysis_time}}), {{1.processing_time}})}} seconds
Completion Time: {{formatDate(now; "YYYY-MM-DD HH:mm:ss")}}

Pipeline completed successfully through distributed agents.
```

---

## 📊 **Scenario 5: Queue Management**

**Name**: `Queue-Manager`
**Trigger**: Schedule (every 10 minutes)

### Modules:

**Module 1: Check Stuck Tasks**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?status=in.(research,analysis,sql)&started_at=lt.{{formatDate(addMinutes(now; -30); "ISO")}}`

**Module 2: Reset Stuck Tasks**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?id=in.({{join(1.*.id; ",")}})`
- Body:
```json
{
  "status": "pending",
  "error_count": "error_count + 1",
  "last_error": "Task timeout - reset to pending"
}
```

**Module 3: Get Failed Tasks**
- Type: HTTP Request
- Method: GET
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?status=eq.failed&error_count=lt.3`

**Module 4: Retry Failed Tasks**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?id=in.({{join(3.*.id; ",")}})`
- Body:
```json
{
  "status": "pending",
  "started_at": null
}
```

**Module 5: Archive Permanently Failed Tasks**
- Type: HTTP Request
- Method: PATCH
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?status=eq.failed&error_count=gte.3`
- Body:
```json
{
  "status": "archived",
  "archived_at": "{{formatDate(now; "ISO")}}"
}
```

---

## 🚀 **Setup Instructions**

### 1. Create Database Tables
```sql
-- Run these in Supabase SQL Editor
CREATE TABLE book_processing_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id),
  status TEXT DEFAULT 'pending',
  priority INTEGER DEFAULT 0,
  research_task_id UUID,
  analysis_task_id UUID,
  sql_task_id UUID,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  error_count INTEGER DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE agent_task_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL,
  task_type TEXT NOT NULL,
  book_id UUID REFERENCES books(id),
  agent_id TEXT,
  status TEXT,
  input_data JSONB,
  output_data JSONB,
  processing_time INTEGER,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);
```

### 2. Populate Queue
```sql
-- Add all unprocessed books to queue
INSERT INTO book_processing_queue (book_id, priority)
SELECT id, 0 FROM books 
WHERE (title_alias IS NULL OR keywords IS NULL OR description IS NULL)
AND title IS NOT NULL AND author_name IS NOT NULL;
```

### 3. Start Local Agent Server
```bash
cd /Users/farieds/imam-lib-masha-allah/islamic-text-workflow
npm install express axios uuid
node agent-webhook-server.js
```

### 4. Create Make.com Scenarios
- Create each scenario in Make.com dashboard
- Use the module configurations above
- Set webhook URLs correctly
- Test with single book first

### 5. Monitor Progress
```sql
-- Check queue status
SELECT status, COUNT(*) FROM book_processing_queue GROUP BY status;

-- Check recent task performance
SELECT task_type, AVG(processing_time) as avg_time, COUNT(*) as total
FROM agent_task_logs 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY task_type;
```

This distributed architecture will reliably process your 1500+ books through specialized agent nodes!