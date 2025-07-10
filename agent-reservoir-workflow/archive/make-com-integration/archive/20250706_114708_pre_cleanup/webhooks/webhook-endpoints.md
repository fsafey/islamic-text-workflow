# Webhook Endpoints Configuration

## 🎯 **Webhook Architecture**

```
Local Agent → Make.com Webhook → Make.com Scenario → Database → Next Stage
```

## 📍 **Webhook URLs**

### Make.com Webhook Endpoints (US2 Zone)
```
Base MCP Token: da4d2186-449b-422b-85df-08701bb6d8eb
Zone: us2.make.com
```

#### Primary Webhooks
- **Research Complete**: `https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb`
- **Analysis Complete**: `https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/analysis`
- **SQL Complete**: `https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/sql`

#### Alternative Format (if using separate scenarios)
- **Research**: `https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/research-complete`
- **Analysis**: `https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/analysis-complete`
- **SQL**: `https://hook.us2.make.com/da4d2186-449b-85df-08701bb6d8eb/sql-complete`

### Local Agent Endpoints
```
Base URL: http://localhost:3001
```

#### Agent Endpoints
- **Research Agent**: `POST http://localhost:3001/agent/research`
- **Analysis Agent**: `POST http://localhost:3001/agent/analysis`
- **SQL Agent**: `POST http://localhost:3001/agent/sql-generation`
- **Health Check**: `GET http://localhost:3001/health`
- **Task Status**: `GET http://localhost:3001/agent/status/{task_id}`

## 📋 **Webhook Payload Structures**

### Research Complete Payload
```json
{
  "task_id": "1672934400-research-book-uuid",
  "status": "completed",
  "book_data": {
    "id": "5231a689-93f7-49f2-879b-4e916af61eca",
    "title": "Al-Mar'a fi Nahj Al-Balagha",
    "author": "Dr. Najwa Saleh Al-Jawad"
  },
  "research_findings": {
    "verified": true,
    "context": "Research context for the book",
    "related_works": ["Related work 1", "Related work 2"],
    "scholarly_context": "Academic context for the author",
    "research_quality": "high",
    "sources_found": 3
  },
  "processing_time": 180,
  "timestamp": "2025-07-04T12:00:00Z"
}
```

### Analysis Complete Payload
```json
{
  "task_id": "1672934500-analysis-book-uuid",
  "status": "completed",
  "book_data": {
    "id": "5231a689-93f7-49f2-879b-4e916af61eca",
    "title": "Al-Mar'a fi Nahj Al-Balagha",
    "author": "Dr. Najwa Saleh Al-Jawad"
  },
  "analysis": {
    "conceptual_network": {
      "central_node": "Feminist reinterpretation of women's status",
      "primary_concepts": [
        {
          "concept": "genre_classification",
          "value": "Contemporary Islamic feminist scholarship"
        },
        {
          "concept": "methodological_foundation", 
          "value": "Hermeneutical analysis using feminist frameworks"
        }
      ],
      "network_description": "This work represents contemporary Islamic feminist scholarship..."
    },
    "structural_flowchart": "Detailed structural analysis...",
    "academic_description": "Scholarly description of the work..."
  },
  "file_path": "./academic-analyses/Al-Mar_a-fi-Nahj-Al-Balagha-Hybrid-Analysis.md",
  "processing_time": 480,
  "timestamp": "2025-07-04T12:08:00Z"
}
```

### SQL Complete Payload
```json
{
  "task_id": "1672934800-sql-book-uuid",
  "status": "completed",
  "book_data": {
    "id": "5231a689-93f7-49f2-879b-4e916af61eca",
    "title": "Al-Mar'a fi Nahj Al-Balagha",
    "author": "Dr. Najwa Saleh Al-Jawad"
  },
  "sql_data": {
    "title_alias": "Women in Nahj al-Balagha; Al-Mar'a fi Nahj Al-Balagha; Al Maraa fi Nahj Al Balagha",
    "keywords": [
      "Women in Islam",
      "Nahj al-Balagha", 
      "Imam Ali ibn Abi Talib",
      "Islamic feminism",
      "Gender studies"
    ],
    "description": "This scholarly work examines the status and rights of women in Islam..."
  },
  "sql_file": "./sql-updates/Al-Mar_a-fi-Nahj-Al-Balagha-enrichment.sql",
  "processing_time": 120,
  "timestamp": "2025-07-04T12:10:00Z"
}
```

## 🔧 **Make.com Webhook Configuration**

### Webhook Module Settings
```javascript
// In Make.com webhook trigger
{
  "respond": {
    "status": 200,
    "body": "{{status}} - {{task_id}} received",
    "headers": {
      "Content-Type": "application/json"
    }
  },
  "output": {
    "task_id": "{{body.task_id}}",
    "status": "{{body.status}}",
    "book_data": "{{body.book_data}}",
    "processing_time": "{{body.processing_time}}",
    "timestamp": "{{body.timestamp}}"
  }
}
```

### Variable Access in Modules
```javascript
// Access webhook data in subsequent modules
{{1.task_id}}                    // Task identifier
{{1.book_data.id}}              // Book UUID
{{1.book_data.title}}           // Book title
{{1.research_findings.verified}} // Research verification status
{{1.analysis.conceptual_network}} // Analysis results
{{1.sql_data.keywords}}         // Generated keywords array
```

## 🧪 **Testing Webhook Endpoints**

### Test Research Webhook
```bash
curl -X POST https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb \
  -H "Content-Type: application/json" \
  -d '{
    "task_id": "test-research-123",
    "status": "completed",
    "book_data": {"id": "test-id", "title": "Test Book", "author": "Test Author"},
    "research_findings": {"verified": true, "sources_found": 2},
    "processing_time": 120
  }'
```

### Test Analysis Webhook
```bash
curl -X POST https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/analysis \
  -H "Content-Type: application/json" \
  -d '{
    "task_id": "test-analysis-123",
    "status": "completed",
    "book_data": {"id": "test-id", "title": "Test Book", "author": "Test Author"},
    "analysis": {"conceptual_network": {"central_node": "Test concept"}},
    "processing_time": 300
  }'
```

### Test Local Agent Endpoints
```bash
# Test research agent
curl -X POST http://localhost:3001/agent/research \
  -H "Content-Type: application/json" \
  -d '{
    "task_id": "test-123",
    "book_data": {"id": "test", "title": "Test Book", "author": "Test Author"},
    "webhook_url": "https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb"
  }'

# Check agent health
curl -X GET http://localhost:3001/health
```

## 📊 **Webhook Monitoring**

### Make.com Dashboard
- **Executions**: View webhook trigger executions
- **Logs**: Check for webhook failures
- **Data**: Inspect received payload data

### Local Agent Monitoring
```bash
# Check active tasks
curl -X GET http://localhost:3001/health

# Check specific task status
curl -X GET http://localhost:3001/agent/status/task-123
```

### Database Monitoring
```sql
-- Check recent webhook executions
SELECT * FROM webhook_execution_logs 
ORDER BY created_at DESC 
LIMIT 10;

-- Check task completion rates
SELECT 
    webhook_type,
    COUNT(*) as total_calls,
    AVG(execution_time) as avg_response_time
FROM webhook_execution_logs 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY webhook_type;
```

## 🚨 **Error Handling**

### Webhook Retry Logic
- **Automatic Retries**: 3 attempts with exponential backoff
- **Timeout**: 30 seconds per attempt
- **Error Logging**: All failures logged to database

### Common Issues
1. **Connection Refused**: Local agent server not running
2. **Timeout**: Network issues or slow processing
3. **404 Not Found**: Incorrect webhook URL
4. **500 Server Error**: Make.com scenario configuration error

### Recovery Procedures
```bash
# Restart local agent server
node /Users/farieds/imam-lib-masha-allah/islamic-text-workflow/agent-webhook-server.js

# Check Make.com scenario status
# Visit: https://us2.make.com/scenarios

# Reset failed tasks in database
SELECT reset_failed_books();
```

## 🔐 **Security Considerations**

### Webhook Security
- **HTTPS Only**: All webhook URLs use HTTPS
- **Token-based**: Make.com token authentication
- **Local Network**: Local agent only accepts localhost connections

### Data Protection
- **No Secrets**: No API keys in webhook payloads
- **Minimal Data**: Only necessary book information transmitted
- **Audit Trail**: All webhook calls logged for security review