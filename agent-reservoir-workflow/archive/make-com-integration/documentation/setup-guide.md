# Complete Setup Guide - Make.com + Local Agent Pipeline

## 🎯 **Overview**

This guide walks you through setting up the distributed Islamic text processing pipeline that combines Make.com cloud orchestration with local specialized agents.

## ✅ **Prerequisites Checklist**

- [x] **Make.com Account** with MCP access
- [x] **MCP Token**: `da4d2186-449b-422b-85df-08701bb6d8eb` 
- [x] **Supabase Database** access configured
- [x] **Node.js** installed (v18+ recommended)
- [x] **Local Agent Server** ready
- [x] **Queue Tables** created (361 books queued)

## 🚀 **Step-by-Step Setup**

### Phase 1: Database & Local Agent ✅ COMPLETED

**Database Tables Created:**
- ✅ `book_processing_queue` - 361 books ready
- ✅ `agent_task_logs` - Task tracking
- ✅ `webhook_execution_logs` - Webhook monitoring

**Local Agent Server Running:**
- ✅ Port 3001 - Health check passed
- ✅ Research endpoint tested
- ✅ Analysis endpoint ready  
- ✅ SQL generation endpoint ready

### Phase 2: Make.com Scenarios 🔄 IN PROGRESS

#### 2.1 Create Main Orchestrator Scenario

1. **Go to Make.com Dashboard**: https://us2.make.com/scenarios
2. **Create New Scenario**: Click "Create new scenario"
3. **Add Schedule Trigger**:
   - Interval: Every 2 minutes
   - Time zone: Your local timezone

4. **Add HTTP Module - Get Next Book**:
   ```
   Module: HTTP > Make a request
   Method: GET
   URL: https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?status=eq.pending&order=priority.desc,created_at.asc&limit=1
   Headers:
     Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ2Nzc1NCwiZXhwIjoyMDYyMDQzNzU0fQ.PHNLmAb0-jzy0CGl3ThVdgXZkAGTBWLxC5O-RDgp_yQ
     Content-Type: application/json
   ```

5. **Add Router - Check Book Available**:
   ```
   Module: Flow Control > Router
   Filter: {{length(1.array)}} > 0
   ```

6. **Add HTTP Module - Get Book Details**:
   ```
   Module: HTTP > Make a request  
   Method: GET
   URL: https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/books?id=eq.{{1.array.0.book_id}}
   Headers: Same as step 4
   ```

7. **Add HTTP Module - Call Research Agent**:
   ```
   Module: HTTP > Make a request
   Method: POST
   URL: http://localhost:3001/agent/research
   Headers:
     Content-Type: application/json
   Body (JSON):
   {
     "task_id": "{{formatDate(now; "X")}}-research-{{1.array.0.book_id}}",
     "book_data": {
       "id": "{{3.array.0.id}}",
       "title": "{{3.array.0.title}}",
       "author": "{{3.array.0.author_name}}"
     },
     "webhook_url": "https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb"
   }
   ```

8. **Add HTTP Module - Update Queue Status**:
   ```
   Module: HTTP > Make a request
   Method: PATCH
   URL: https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?id=eq.{{1.array.0.id}}
   Headers: Same as step 4
   Body (JSON):
   {
     "status": "research",
     "started_at": "{{formatDate(now; "ISO")}}"
   }
   ```

9. **Save and Activate**: Name it "Islamic-Text-Orchestrator"

#### 2.2 Create Research Complete Webhook Handler

1. **Create New Scenario**: "Research-Complete-Handler"
2. **Add Webhook Trigger**:
   ```
   Module: Webhooks > Instant trigger
   Webhook URL: https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb
   Response:
     Status: 200
     Body: "Research received for {{body.task_id}}"
   ```

3. **Add JSON Parser**:
   ```
   Module: JSON > Parse JSON
   JSON string: {{body}}
   ```

4. **Add HTTP Module - Update to Analysis Stage**:
   ```
   Module: HTTP > Make a request
   Method: PATCH
   URL: https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?research_task_id=eq.{{1.task_id}}
   Body (JSON):
   {
     "status": "analysis",
     "analysis_task_id": "{{formatDate(now; "X")}}-analysis"
   }
   ```

5. **Add HTTP Module - Get Book for Analysis**:
   ```
   Module: HTTP > Make a request
   Method: GET
   URL: https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?research_task_id=eq.{{1.task_id}}
   ```

6. **Add HTTP Module - Get Book Details**:
   ```
   Module: HTTP > Make a request
   Method: GET
   URL: https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/books?id=eq.{{4.array.0.book_id}}
   ```

7. **Add HTTP Module - Call Analysis Agent**:
   ```
   Module: HTTP > Make a request
   Method: POST
   URL: http://localhost:3001/agent/analysis
   Body (JSON):
   {
     "task_id": "{{3.analysis_task_id}}",
     "book_data": {
       "id": "{{5.array.0.id}}",
       "title": "{{5.array.0.title}}",
       "author": "{{5.array.0.author_name}}"
     },
     "research_findings": {{1.research_findings}},
     "webhook_url": "https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/analysis"
   }
   ```

8. **Save and Activate**

#### 2.3 Create Analysis Complete Webhook Handler

1. **Create New Scenario**: "Analysis-Complete-Handler"
2. **Add Webhook Trigger**:
   ```
   Webhook URL: https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/analysis
   ```

3. **Follow similar pattern as Research Handler but**:
   - Update queue to "sql" status
   - Call SQL generation agent
   - Use webhook URL: `.../sql`

#### 2.4 Create SQL Complete Webhook Handler

1. **Create New Scenario**: "SQL-Complete-Handler"  
2. **Add Webhook Trigger**:
   ```
   Webhook URL: https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/sql
   ```

3. **Add Database Update Module**:
   ```
   Module: HTTP > Make a request
   Method: PATCH
   URL: https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/books?id=eq.{{book_id}}
   Body (JSON):
   {
     "title_alias": "{{1.sql_data.title_alias}}",
     "keywords": {{1.sql_data.keywords}},
     "description": "{{1.sql_data.description}}",
     "updated_at": "{{formatDate(now; "ISO")}}"
   }
   ```

4. **Add Complete Status Update**:
   ```
   Module: HTTP > Make a request
   Method: PATCH
   URL: https://aayvvcpxafzhcjqewwja.supabase.co/rest/v1/book_processing_queue?sql_task_id=eq.{{1.task_id}}
   Body (JSON):
   {
     "status": "completed",
     "completed_at": "{{formatDate(now; "ISO")}}"
   }
   ```

5. **Save and Activate**

### Phase 3: Testing 🧪

#### 3.1 Test Individual Webhooks

```bash
# Test research webhook
curl -X POST https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb \
  -H "Content-Type: application/json" \
  -d @../testing/test-book-data.json
```

#### 3.2 Test End-to-End Pipeline

1. **Verify Queue**: Check book queue has pending items
2. **Start Orchestrator**: Activate the main scenario
3. **Monitor Progress**: Watch Make.com execution logs
4. **Check Database**: Verify book updates

#### 3.3 Monitoring Commands

```bash
# Check queue status
PGPASSWORD="sXm0id2x7pEjggUd" psql -h aws-0-us-east-2.pooler.supabase.com -p 5432 -U postgres.aayvvcpxafzhcjqewwja -d postgres -c "SELECT status, COUNT(*) FROM book_processing_queue GROUP BY status;"

# Check agent health
curl -X GET http://localhost:3001/health

# View recent task logs
PGPASSWORD="sXm0id2x7pEjggUd" psql -h aws-0-us-east-2.pooler.supabase.com -p 5432 -U postgres.aayvvcpxafzhcjqewwja -d postgres -c "SELECT task_type, status, COUNT(*) FROM agent_task_logs WHERE created_at > NOW() - INTERVAL '1 hour' GROUP BY task_type, status;"
```

## 🎯 **Success Criteria**

### Single Book Test ✅
- [x] Local agent processes research request
- [ ] Make.com receives webhook
- [ ] Analysis stage triggered
- [ ] SQL generation completed
- [ ] Database updated successfully

### Full Pipeline Test
- [ ] Multiple books processed simultaneously
- [ ] Error handling works correctly
- [ ] Queue management functions properly
- [ ] Performance targets met (50+ books/hour)

## 📊 **Current Status**

### ✅ **Completed**
- Database tables created
- Local agent server running  
- 361 books queued for processing
- Research agent tested successfully

### 🔄 **In Progress**
- Make.com scenario creation
- Webhook handler setup
- End-to-end testing

### ⏳ **Next Steps**
1. Create the 4 Make.com scenarios above
2. Test webhook connectivity
3. Run single book end-to-end test
4. Scale to full queue processing

## 🚨 **Troubleshooting**

### Common Issues

**Local Agent Connection Refused**
```bash
# Restart agent server
node /Users/farieds/imam-lib-masha-allah/islamic-text-workflow/agent-webhook-server.js
```

**Make.com Webhook Not Receiving**
- Check webhook URL is correct
- Verify scenario is activated
- Check Make.com execution logs

**Database Connection Issues**
```bash
# Test database connection
PGPASSWORD="sXm0id2x7pEjggUd" psql -h aws-0-us-east-2.pooler.supabase.com -p 5432 -U postgres.aayvvcpxafzhcjqewwja -d postgres -c "SELECT NOW();"
```

### Support Resources
- **Make.com Docs**: Use `mcp__make__` tools for API reference
- **Context7 Docs**: Use `mcp__context7__` for library documentation
- **Local Logs**: Check agent server console output
- **Database Monitoring**: Use the created views and functions

---

**🎯 Goal**: Successfully process 361 queued Islamic texts through the distributed pipeline, then scale to handle the full 1500+ book collection efficiently and reliably.