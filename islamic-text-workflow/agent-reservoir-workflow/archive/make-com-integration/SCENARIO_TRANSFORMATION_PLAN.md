# Scenario Transformation Plan: Google Sheets to Supabase Queue-Based Processing

## **Project Overview**

**Target Scenario**: "Importing books Claude Test" (ID: 2354620)  
**Transformation Goal**: Replace Google Sheets-based book sourcing with Supabase `book_processing_queue` integration  
**Architecture**: Multi-stage Islamic text processing pipeline with queue-driven workflow management

---

## **Overall Goals**

### **Primary Objectives**
1. **Eliminate Google Sheets dependency** - Replace with direct Supabase database integration
2. **Implement queue-driven processing** - Use `book_processing_queue` for centralized task management
3. **Maintain existing agent architecture** - Preserve Stage 1 (Hybrid Analysis) and Stage 2 (Enrichment) agents
4. **Add comprehensive status tracking** - Queue-based progress monitoring and error handling
5. **Enable scalable batch processing** - Process multiple books through coordinated pipeline

### **Success Metrics**
- ✅ **Data Source Migration**: 100% replacement of Google Sheets modules with Supabase queries
- ✅ **Queue Integration**: All processing stages update queue status appropriately
- ✅ **Agent Compatibility**: Existing Claude agents work with new data flow
- ✅ **Error Resilience**: Failed processing items properly tracked and recoverable
- ✅ **Throughput Improvement**: Faster processing through direct database access

---

## **Reference Documents & Tools**

### **Core Documentation**
- **Workflow Specification**: `/islamic-text-workflow/documentation/Islamic-Text-Processing-Workflow.md`
- **Stage 1 Template**: `/islamic-text-workflow/make-com-integration/archive/.../stage1-hybrid-analysis-scenario.json`
- **Stage 2 Template**: `/islamic-text-workflow/make-com-integration/archive/.../stage2-enrichment-execution-scenario.json`
- **Database Schema**: `book_processing_queue` table structure and relationships

### **Technical Assets**
- **Make.com Platform**: Scenario ID 2354620 (active modification target)
- **Supabase Database**: Direct REST API integration for queue management
- **Claude Agent Endpoints**: Existing `/claude/hybrid-analysis` and `/claude/enrichment-execution`
- **Processing Pipeline**: Academic analysis → Database enrichment → Quality validation

### **Key Configuration References**
```bash
# Supabase Connection (from CLAUDE.md)
URL: {{config.supabase.url}}/rest/v1/
Authorization: Bearer {{config.supabase.serviceKey}}
ApiKey: {{config.supabase.serviceKey}}

# Claude Agent Endpoints
POST {{config.claudeDesktop.publicUrl}}/claude/hybrid-analysis
POST {{config.claudeDesktop.publicUrl}}/claude/enrichment-execution
```

---

## **Current vs Target Architecture**

### **Current State Analysis (Scenario 2354620)**
```json
{
  "source_module": "google-sheets (multiple instances)",
  "data_flow": "Sheets → Processing → Results",
  "limitations": [
    "External dependency on Google Sheets",
    "Manual data entry requirements", 
    "Limited queue management",
    "No centralized status tracking"
  ]
}
```

### **Target State Design**
```json
{
  "source_module": "supabase:book_processing_queue",
  "data_flow": "Queue → Stage 1 → Stage 2 → Completion",
  "advantages": [
    "Direct database integration",
    "Automated queue management",
    "Comprehensive status tracking",
    "Error recovery capabilities",
    "Scalable batch processing"
  ]
}
```

---

## **Module Transformation Strategy**

### **Phase 1: Data Source Replacement**

#### **Google Sheets Module → Supabase HTTP Module**

**Current Module Pattern** (from existing scenarios):
```json
{
  "module": "google-sheets:getValues",
  "purpose": "Read book data for processing"
}
```

**Target Module Pattern**:
```json
{
  "module": "http:ActionSendData",
  "method": "GET",
  "url": "{{config.supabase.url}}/rest/v1/book_processing_queue",
  "purpose": "Query queue for books ready for processing"
}
```

#### **Queue Query Specifications**

**Stage 1 (Hybrid Analysis) - Queue Source**:
```sql
-- Get books ready for analysis (status: pending)
SELECT bpq.*, b.title, b.author_name, b.id as book_uuid
FROM book_processing_queue bpq 
JOIN books b ON bpq.book_id = b.id 
WHERE bpq.status = 'pending' 
ORDER BY bpq.priority DESC, bpq.created_at
LIMIT 3
```

**Stage 2 (Enrichment) - Queue Source**:
```sql
-- Get books with completed analysis (status: analysis)
SELECT bpq.*, b.title, b.author_name, bar.*
FROM book_processing_queue bpq 
JOIN books b ON bpq.book_id = b.id 
JOIN book_analysis_results bar ON bar.book_id = bpq.book_id
WHERE bpq.status = 'analysis'
AND bar.stage_status = 'completed'
AND bar.analysis_quality_score >= 7
ORDER BY bpq.priority DESC, bpq.updated_at
LIMIT 3
```

### **Phase 2: Queue Status Management**

#### **Status Update Integration**
Add queue status updates after each processing stage:

**Stage 1 Completion**:
```json
{
  "module": "http:ActionSendData",
  "method": "PATCH",
  "url": "{{config.supabase.url}}/rest/v1/book_processing_queue",
  "body": {
    "status": "analysis",
    "analysis_task_id": "{{stage1_task_id}}",
    "updated_at": "{{now}}"
  },
  "where": "id=eq.{{queue_item_id}}"
}
```

**Stage 2 Completion**:
```json
{
  "module": "http:ActionSendData", 
  "method": "PATCH",
  "url": "{{config.supabase.url}}/rest/v1/book_processing_queue",
  "body": {
    "status": "completed",
    "sql_task_id": "{{stage2_task_id}}",
    "completed_at": "{{now}}"
  },
  "where": "id=eq.{{queue_item_id}}"
}
```

#### **Error Handling Integration**
```json
{
  "error_handler": {
    "module": "http:ActionSendData",
    "method": "PATCH", 
    "url": "{{config.supabase.url}}/rest/v1/book_processing_queue",
    "body": {
      "status": "failed",
      "error_count": "{{error_count + 1}}",
      "last_error": "{{error_message}}",
      "updated_at": "{{now}}"
    }
  }
}
```

---

## **Detailed Module Conversion Plan**

### **Module 1: Data Source Conversion**

#### **Before (Google Sheets)**
```json
{
  "id": 1,
  "module": "google-sheets:ActionSearchRows",
  "parameters": {
    "spreadsheetId": "...",
    "range": "Books!A:C",
    "filter": "Status = 'Pending'"
  }
}
```

#### **After (Supabase Queue)**
```json
{
  "id": 1,
  "module": "http:ActionSendData",
  "version": 3,
  "parameters": {
    "method": "GET",
    "url": "{{config.supabase.url}}/rest/v1/book_processing_queue",
    "headers": [
      {
        "name": "Authorization",
        "value": "Bearer {{config.supabase.serviceKey}}"
      },
      {
        "name": "apikey", 
        "value": "{{config.supabase.serviceKey}}"
      }
    ],
    "qs": [
      {
        "name": "select",
        "value": "id,book_id,status,priority,books(id,title,author_name)"
      },
      {
        "name": "status",
        "value": "eq.pending"
      },
      {
        "name": "order",
        "value": "priority.desc,created_at"
      },
      {
        "name": "limit",
        "value": "3"
      }
    ]
  }
}
```

### **Module 2: Queue Status Updates**

#### **New Module: Start Processing**
```json
{
  "id": 1.5,
  "module": "http:ActionSendData",
  "version": 3,
  "parameters": {
    "method": "PATCH",
    "url": "{{config.supabase.url}}/rest/v1/book_processing_queue",
    "headers": [
      {
        "name": "Authorization",
        "value": "Bearer {{config.supabase.serviceKey}}"
      },
      {
        "name": "Content-Type",
        "value": "application/json"
      }
    ],
    "qs": [
      {
        "name": "id",
        "value": "eq.{{3.id}}"
      }
    ],
    "body": {
      "status": "research",
      "started_at": "{{now}}"
    }
  }
}
```

### **Module 3: Agent Integration (Preserved)**
```json
{
  "id": 4,
  "module": "http:ActionSendData",
  "version": 3,
  "mapper": {
    "body": "{\"book_id\": \"{{3.books.id}}\", \"queue_item_id\": \"{{3.id}}\", \"title\": \"{{3.books.title}}\", \"author\": \"{{3.books.author_name}}\", \"stage\": \"hybrid_analysis\", ...}"
  },
  "parameters": {
    "method": "POST",
    "url": "{{config.claudeDesktop.publicUrl}}/claude/hybrid-analysis"
  }
}
```

---

## **Implementation Phases**

### **Phase 1: Foundation Setup** (Week 1)
- [ ] **Backup current scenario** 2354620 configuration
- [ ] **Test Supabase connectivity** from Make.com environment
- [ ] **Validate queue queries** with sample data
- [ ] **Create development branch** of scenario for testing

### **Phase 2: Module Replacement** (Week 1-2)
- [ ] **Replace Google Sheets source** with Supabase queue query
- [ ] **Add queue status management** modules
- [ ] **Integrate error handling** for queue updates
- [ ] **Test data flow** with single book processing

### **Phase 3: Agent Integration** (Week 2)
- [ ] **Update agent payloads** to include queue context
- [ ] **Test Stage 1 agent** with queue-sourced data
- [ ] **Test Stage 2 agent** with analysis handoff
- [ ] **Validate end-to-end flow** with quality gates

### **Phase 4: Production Validation** (Week 3)
- [ ] **Process test batch** of 5-10 books
- [ ] **Monitor queue status** progression
- [ ] **Validate output quality** against existing standards
- [ ] **Document operational procedures**

---

## **Quality Gates & Validation**

### **Data Integrity Checks**
```sql
-- Validate queue item processing
SELECT 
  status,
  COUNT(*) as count,
  AVG(EXTRACT(EPOCH FROM (completed_at - started_at))/60) as avg_processing_minutes
FROM book_processing_queue 
WHERE created_at >= NOW() - INTERVAL '24 hours'
GROUP BY status;

-- Verify no data loss
SELECT COUNT(*) as books_without_queue_entry
FROM books b 
LEFT JOIN book_processing_queue bpq ON b.id = bpq.book_id
WHERE bpq.book_id IS NULL
AND b.created_at >= NOW() - INTERVAL '7 days';
```

### **Performance Benchmarks**
- **Processing Speed**: Target <15 minutes per book (current: ~18 minutes)
- **Error Rate**: <5% failed processing attempts
- **Queue Throughput**: Process 20+ books per day
- **Data Consistency**: 100% queue status accuracy

---

## **Risk Mitigation**

### **Rollback Plan**
1. **Preserve original scenario** configuration as backup
2. **Maintain parallel processing** during transition period
3. **Queue state recovery** procedures for failed transactions
4. **Agent compatibility** verification before production deployment

### **Monitoring & Alerts**
- **Queue status monitoring** for stuck processing items
- **Agent response validation** for quality degradation
- **Database connection** health checks
- **Processing time** anomaly detection

---

## **Next Steps**

### **Immediate Actions** (This Session)
1. **Create development copy** of scenario 2354620
2. **Begin Module 1 conversion** (Google Sheets → Supabase)
3. **Test basic queue query** functionality
4. **Document module transformation** progress

### **Follow-up Sessions**
1. **Complete Stage 1 integration** with queue management
2. **Implement Stage 2 queue handoff** mechanism
3. **Add comprehensive error handling** across all modules
4. **Performance test** with realistic workload

---

**This document serves as the master reference for transforming the "Importing books Claude Test" scenario from Google Sheets dependency to a robust, queue-driven Supabase integration that maintains the existing two-stage Islamic text processing pipeline while adding enterprise-grade workflow management capabilities.**