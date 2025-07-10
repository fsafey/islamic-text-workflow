# Make.com Module Configuration Guide - Islamic Text Processing Pipeline

## 🎯 **Complete Module Setup for Supabase Integration - STREAMLINED 25-FIELD VERSION**

This guide provides the exact field configurations for each module in the Islamic text processing pipeline.

**🚀 UPDATED: July 2025 - Streamlined from 155 fields to 25 essential fields (83% reduction)**

## 📋 **Module Purpose & Flow Explanation**

**Module 1 (Fetch Queued Books)**: Retrieves pending books from the processing queue ordered by priority to ensure systematic book processing.

**Module 2 (Check Queue)**: Routes the scenario to continue only if books are found in the queue, preventing unnecessary processing when queue is empty.

**Module 3 (Iterator)**: Processes each book individually from the queue data, enabling batch processing while maintaining data integrity per book.

**Module 9 (Get Book Details)**: Fetches complete book information from the main books table using the book_id from the queue for full context processing.

**Module 4 (Claude Analysis)**: Sends book data to Claude AI for hybrid analysis, generating insights about content, themes, and categorization.

**Module 5 (Store Analysis)**: Saves Claude's streamlined analysis results (8 essential fields) to `book_analysis_results_streamlined` table for future reference and audit trail.

**Module 6 (Enrichment Processing)**: Processes Claude's analysis to generate final metadata like title aliases, keywords, and descriptions for search optimization.

**Module 7 (Store Enrichment)**: Saves streamlined enrichment results (17 essential fields) to `book_enrichment_results_streamlined` table for tracking the enhancement process and debugging.

**Module 8 (Update Books Table)**: Applies the final enriched metadata to the main books table, updating searchable fields with AI-generated content.

**Module 10 (Mark Queue Complete)**: Updates the processing queue status to "completed" for the processed book, ensuring it won't be reprocessed.

---

## 🔑 **CRITICAL: Module 1 Configuration (Fetch Queued Books)**

### **Module Type**: `supabase:ListRows`
### **Version**: 1

**⚠️ ESSENTIAL FIELDS - GET THIS RIGHT FIRST:**

| Field | Value | Critical Notes |
|-------|--------|----------------|
| **Connection** | `supabase-imam-lib` | Must create this connection first in Make.com |
| **Table** | `book_processing_queue` | Exact table name - case sensitive |
| **Select Fields** | `book_id,status,priority,created_at` | Comma-separated, no spaces |
| **Filter** | `status=eq.pending` | Only fetch pending books |
| **Order** | `priority,created_at` | Process by priority first, then oldest |
| **Limit** | `1` | Process one book at a time for stability |

### **Connection Setup (Do This First):**
1. **Supabase URL**: `https://aayvvcpxafzhcjqewwja.supabase.co`
2. **API Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ2Nzc1NCwiZXhwIjoyMDYyMDQzNzU0fQ.PHNLmAb0-jzy0CGl3ThVdgXZkAGTBWLxC5O-RDgp_yQ`
3. **Connection Name**: `supabase-imam-lib`

### **Critical Success Criteria:**
- ✅ Returns `book_id` (integer)
- ✅ Returns `status` (should be "pending")
- ✅ Returns `priority` (integer)
- ✅ Returns `created_at` (timestamp)

---

## 📋 **Complete Module Flow Configuration**

### **Module 2: Check Queue**
**Type**: `builtin:BasicRouter`

| Field | Value |
|-------|--------|
| **Condition** | `{{length(1.data) > 0}}` |

---

### **Module 3: Iterator**
**Type**: `builtin:ArrayIterator`

| Field | Value |
|-------|--------|
| **Array** | `{{1.data}}` |

---

### **Module 9: Get Book Details**
**Type**: `supabase:ListRows`

| Field | Value |
|-------|--------|
| **Connection** | `supabase-imam-lib` |
| **Table** | `books` |
| **Select Fields** | `id,title,author_name` |
| **Filter** | `id=eq.{{3.book_id}}` |

**Expected Output**: Single book record with full details

---

### **Module 4: Claude Analysis**
**Type**: `http:ActionSendData`

| Field | Value |
|-------|--------|
| **Method** | `POST` |
| **URL** | `https://a57b-2601-403-4280-2f0-34ff-ffe9-2152-b9e0.ngrok-free.app/claude/hybrid-analysis` |
| **Headers** | `Content-Type: application/json` |
| **Body** | `{"book_id": "{{9.data.0.id}}", "title": "{{9.data.0.title}}", "author": "{{9.data.0.author_name}}"}` |
| **Timeout** | `180` |

**⚠️ IMPORTANT**: ngrok URL changes on restart. Update both Module 4 and Module 6 URLs when ngrok restarts.

---

### **Module 5: Store Analysis (Parallel) - STREAMLINED 8 FIELDS**
**Type**: `supabase:CreateRow`

| Field | Value | Notes |
|-------|--------|-------|
| **Connection** | `supabase-imam-lib` | |
| **Table** | `book_analysis_results_streamlined` | 🔄 **UPDATED** from `book_analysis_results` |
| **book_id** | `{{9.data.0.id}}` | |
| **input_title** | `{{9.data.0.title}}` | 🔄 **UPDATED** from `title` |
| **input_author** | `{{9.data.0.author_name}}` | 🔄 **UPDATED** from `author` |
| **central_node** | `{{4.data.central_node}}` | ✨ **NEW** - Core thesis field |
| **genre_classification** | `{{4.data.genre_classification}}` | ✨ **NEW** - Work type |
| **methodological_foundation** | `{{4.data.methodological_foundation}}` | ✨ **NEW** - Sources/methods |
| **scholarly_perspective** | `{{4.data.scholarly_perspective}}` | ✨ **NEW** - School of thought |
| **network_description** | `{{4.data.network_description}}` | ✨ **NEW** - Conceptual connections |
| **analysis_quality_score** | `{{4.data.analysis_quality_score}}` | ✨ **NEW** - Quality (1-10) |
| **quality_gate_passed** | `{{4.data.quality_gate_passed}}` | ✨ **NEW** - Quality validation |
| **ready_for_stage2** | `{{4.data.ready_for_stage2}}` | ✨ **NEW** - Pipeline readiness |
| **stage_status** | `completed` | 🔄 **UPDATED** from `stage` |

**⚡ Performance Impact**: Stores only 8 essential fields instead of all 155 analysis fields (95% reduction)

---

### **Module 6: Enrichment Processing (Parallel)**
**Type**: `http:ActionSendData`

| Field | Value |
|-------|--------|
| **Method** | `POST` |
| **URL** | `https://a57b-2601-403-4280-2f0-34ff-ffe9-2152-b9e0.ngrok-free.app/claude/enrichment-execution` |
| **Headers** | `Content-Type: application/json` |
| **Body** | `{"book_id": "{{9.data.0.id}}", "analysis_data": {{4.data}}, "original_book": {"title": "{{9.data.0.title}}", "author_name": "{{9.data.0.author_name}}"}}` |
| **Timeout** | `180` |

---

### **Module 7: Store Enrichment - STREAMLINED 17 FIELDS**
**Type**: `supabase:CreateRow`

| Field | Value | Notes |
|-------|--------|-------|
| **Connection** | `supabase-imam-lib` | |
| **Table** | `book_enrichment_results_streamlined` | 🔄 **UPDATED** from `book_enrichment_results` |
| **book_id** | `{{9.data.0.id}}` | |
| **input_book_title** | `{{9.data.0.title}}` | ✨ **NEW** - Input book title |
| **input_author_name** | `{{9.data.0.author_name}}` | ✨ **NEW** - Input author name |
| **input_analysis_data** | `{{4.data}}` | ✨ **NEW** - Stage 1 analysis data |
| **final_title_alias** | `{{6.data.final_title_alias}}` | ✨ **NEW** - Generated aliases |
| **final_keywords** | `{{6.data.final_keywords}}` | ✨ **NEW** - Generated keywords |
| **final_description** | `{{6.data.final_description}}` | ✨ **NEW** - Generated description |
| **transliteration_variations_count** | `{{6.data.transliteration_variations_count}}` | ✨ **NEW** - Variation count |
| **core_concepts_count** | `{{6.data.core_concepts_count}}` | ✨ **NEW** - Concept count |
| **contextual_associations_count** | `{{6.data.contextual_associations_count}}` | ✨ **NEW** - Association count |
| **description_word_count** | `{{6.data.description_word_count}}` | ✨ **NEW** - Word count (100-150) |
| **academic_tone_maintained** | `{{6.data.academic_tone_maintained}}` | ✨ **NEW** - Tone validation |
| **enrichment_quality_score** | `{{6.data.enrichment_quality_score}}` | ✨ **NEW** - Quality score |
| **sql_executed** | `{{6.data.sql_executed}}` | ✨ **NEW** - Execution status |
| **execution_successful** | `{{6.data.execution_successful}}` | ✨ **NEW** - Success flag |
| **methodology_compliance_gate_passed** | `{{6.data.methodology_compliance_gate_passed}}` | ✨ **NEW** - Compliance gate |
| **execution_timestamp** | `{{6.data.execution_timestamp}}` | ✨ **NEW** - Execution time |
| **rows_affected** | `{{6.data.rows_affected}}` | ✨ **NEW** - DB rows updated |
| **execution_error** | `{{6.data.execution_error}}` | ✨ **NEW** - Error tracking |
| **books_updated_at** | `{{6.data.books_updated_at}}` | ✨ **NEW** - Update timestamp |
| **overall_quality_gate_passed** | `{{6.data.overall_quality_gate_passed}}` | ✨ **NEW** - Overall gate |
| **stage_status** | `completed` | 🔄 **UPDATED** from `stage` |

**⚡ Performance Impact**: Stores 17 essential fields instead of all 96 enrichment fields (82% reduction)

---

### **Module 8: Update Books Table**
**Type**: `supabase:UpdateRows`

| Field | Value |
|-------|--------|
| **Connection** | `supabase-imam-lib` |
| **Table** | `books` |
| **Filter** | `id=eq.{{9.data.0.id}}` |
| **title_alias** | `{{6.data.final_title_alias}}` |
| **keywords** | `{{6.data.final_keywords}}` |
| **description** | `{{6.data.final_description}}` |
| **updated_at** | `{{now}}` |

---

### **Module 10: Mark Queue Complete**
**Type**: `supabase:UpdateRows`

| Field | Value |
|-------|--------|
| **Connection** | `supabase-imam-lib` |
| **Table** | `book_processing_queue` |
| **Filter** | `book_id=eq.{{3.book_id}}` |
| **status** | `completed` |
| **processed_at** | `{{now}}` |

---

## ⏰ **Scenario Scheduling & Execution Settings**

### **Recommended Schedule Configuration**
```json
{
  "type": "interval",
  "interval": 5,
  "intervalType": "minutes"
}
```

### **Scenario Metadata Settings**
```json
{
  "version": 1,
  "scenario": {
    "roundtrips": 1,
    "maxErrors": 3,
    "autoCommit": true,
    "autoCommitTriggerLast": true,
    "sequential": false,
    "confidential": false,
    "dataloss": false,
    "dlq": false,
    "freshVariables": false
  }
}
```

### **Error Handling Configuration**
- **Max Errors**: 3 (allows retries for transient failures)
- **Timeout**: 180 seconds for Claude endpoints
- **Auto Commit**: true (saves progress automatically)
- **Sequential**: false (enables parallel processing for Modules 5 & 7)

### **Performance Settings**
- **Processing Rate**: 1 book per 5-minute interval (12 books/hour)
- **Parallel Operations**: Analysis storage (Module 5) and enrichment processing (Module 6) run in parallel
- **Queue Management**: Processes oldest high-priority books first

---

## 🚀 **STREAMLINED IMPLEMENTATION BENEFITS**

### **Performance Improvements**
- **83% field reduction**: 155 fields → 25 essential fields
- **Faster webhook responses**: Reduced JSON payload sizes
- **Faster database operations**: Fewer fields to insert/update
- **Simplified monitoring**: Focused on essential metrics only

### **Key Changes from Original Plan**
- **Module 5**: Now stores 8 structured analysis fields instead of 1 blob field
- **Module 7**: Now stores 17 structured enrichment fields instead of 1 blob field
- **Quality gates**: Built-in validation with `quality_gate_passed` and `overall_quality_gate_passed`
- **Pipeline readiness**: `ready_for_stage2` field for automated workflow control

### **Monitoring Advantages**
- **Individual field access**: No need to parse JSON blobs
- **Quality tracking**: Direct access to quality scores and gate status
- **Execution tracking**: Detailed SQL execution and error information
- **Pipeline status**: Clear indication of workflow stage completion

---

## 🌐 **Webhook URL Management - CRITICAL**

### **Current Webhook URLs (Updated: July 6, 2025)**
- **Analysis Endpoint**: `https://a57b-2601-403-4280-2f0-34ff-ffe9-2152-b9e0.ngrok-free.app/claude/hybrid-analysis`
- **Enrichment Endpoint**: `https://a57b-2601-403-4280-2f0-34ff-ffe9-2152-b9e0.ngrok-free.app/claude/enrichment-execution`

### **⚠️ BEFORE BUILDING Make.com Scenario**
1. **Verify Agent is Running**:
   ```bash
   curl -X GET https://a57b-2601-403-4280-2f0-34ff-ffe9-2152-b9e0.ngrok-free.app/health
   ```

2. **Get Current ngrok URL** (if different):
   ```bash
   curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"'
   ```

3. **Update URLs in Modules 4 & 6** if ngrok URL has changed

### **Production Considerations**
- **ngrok URLs are temporary** - they change when ngrok restarts
- **For production**: Consider using a permanent webhook service or domain
- **Always test webhook connectivity** before starting scenario

---

## 🚨 **Critical Setup Order**

### **0. PREREQUISITE: Deploy Streamlined Database Schema - ✅ COMPLETED**

**Status**: ✅ **DEPLOYED** - Streamlined tables are live and ready for production use

```bash
# ✅ ALREADY EXECUTED - Streamlined schema is deployed
PGPASSWORD="sXm0id2x7pEjggUd" psql \
  -h aws-0-us-east-2.pooler.supabase.com \
  -p 5432 \
  -U postgres.aayvvcpxafzhcjqewwja \
  -d postgres \
  -f islamic-text-workflow/make-com-integration/database/streamlined-schema.sql
```

**Deployed Tables**:
- ✅ `book_analysis_results_streamlined` (8 fields)
- ✅ `book_enrichment_results_streamlined` (17 fields)  
- ✅ `streamlined_pipeline_status` view (monitoring)
- ✅ Quality gate triggers and indexes

**Current Status**: 507 books ready for streamlined processing

### **1. FIRST: Create Supabase Connection**
- Name: `supabase-imam-lib`
- URL: `https://aayvvcpxafzhcjqewwja.supabase.co`
- API Key: Service role key (see above)

### **2. SECOND: Test Module 1**
- Configure exactly as shown above
- Test execution to ensure it returns queue data
- Verify `book_id` field is populated

### **3. THIRD: Configure Remaining Modules**
- Follow exact field mappings above
- Pay attention to data references ({{1.data}}, {{3.book_id}}, {{9.data.0.id}})
- **IMPORTANT**: Ensure you're using the streamlined table names:
  - `book_analysis_results_streamlined` (not `book_analysis_results`)
  - `book_enrichment_results_streamlined` (not `book_enrichment_results`)

---

## 🔍 **Troubleshooting Module 1**

### **Common Issues:**
- **No data returned**: Check filter `status=eq.pending`
- **Connection failed**: Verify Supabase URL and API key
- **Wrong table**: Ensure `book_processing_queue` exists
- **Empty queue**: Check if books are in queue with `status='pending'`

### **Test Query to Verify Queue:**
```sql
SELECT book_id, status, priority, created_at 
FROM book_processing_queue 
WHERE status = 'pending' 
ORDER BY priority, created_at 
LIMIT 1;
```

### **Expected Module 1 Output:**
```json
{
  "data": [
    {
      "book_id": 123,
      "status": "pending", 
      "priority": 1,
      "created_at": "2025-01-07T10:00:00Z"
    }
  ]
}
```

---

## ✅ **Success Validation & Production Deployment Status**

### **Streamlined Implementation Status**
- ✅ **Database Schema**: Deployed and ready
- ✅ **Agent Code**: Updated for 25-field structure  
- ✅ **Make.com Scenario**: Updated field mappings
- ✅ **Monitoring Views**: Active and functional

### **Test Complete Flow**
After configuring all modules, test the complete streamlined flow:

1. **Module 1**: Returns pending queue item
2. **Module 9**: Fetches book details using `book_id`
3. **Module 4**: Claude analysis returns 8 structured fields
4. **Module 5**: Stores 8 analysis fields in `book_analysis_results_streamlined`
5. **Module 6**: Claude enrichment returns 17 structured fields
6. **Module 7**: Stores 17 enrichment fields in `book_enrichment_results_streamlined`
7. **Module 8**: Updates books table with final metadata
8. **Module 10**: Marks queue item as completed

### **Validation Queries**

**Check Streamlined Pipeline Status**:
```sql
SELECT overall_status, COUNT(*) as count 
FROM streamlined_pipeline_status 
GROUP BY overall_status 
ORDER BY count DESC;
```

**Monitor Processing Quality**:
```sql
-- Analysis Quality
SELECT 
    COUNT(*) as total_analyses,
    COUNT(CASE WHEN quality_gate_passed THEN 1 END) as passed_quality,
    COUNT(CASE WHEN ready_for_stage2 THEN 1 END) as ready_for_enrichment
FROM book_analysis_results_streamlined;

-- Enrichment Quality  
SELECT 
    COUNT(*) as total_enrichments,
    COUNT(CASE WHEN overall_quality_gate_passed THEN 1 END) as passed_all_gates,
    COUNT(CASE WHEN execution_successful THEN 1 END) as successful_executions
FROM book_enrichment_results_streamlined;
```

**Performance Comparison**:
```sql
-- Compare field counts (should show dramatic reduction)
SELECT 
    'Original Analysis' as table_type,
    COUNT(*) as total_columns
FROM information_schema.columns 
WHERE table_name = 'book_analysis_results'
UNION ALL
SELECT 
    'Streamlined Analysis' as table_type,
    COUNT(*) as total_columns  
FROM information_schema.columns 
WHERE table_name = 'book_analysis_results_streamlined';
```

### **Production Readiness Checklist**
- ✅ Streamlined database schema deployed
- ✅ 507 books ready for processing
- ✅ Agent returning 25 essential fields (83% reduction)
- ✅ Make.com scenario field mappings updated
- ✅ Quality gates and triggers active
- ✅ Monitoring views functional
- 🔄 **NEXT**: Deploy updated scenario to Make.com production
- 🔄 **NEXT**: Process test books through streamlined pipeline

**Final Test**: Check that `book_processing_queue.status` changes from "pending" to "completed" and verify data appears in streamlined tables with proper field structure.

---

## 🔧 **Streamlined Implementation Troubleshooting**

### **Common Issues & Solutions**

**❌ Table Not Found Error**:
```
ERROR: relation "book_analysis_results_streamlined" does not exist
```
**Solution**: Verify streamlined tables are deployed:
```sql
\d book_analysis_results_streamlined
\d book_enrichment_results_streamlined
```

**❌ Wrong Field Names in Make.com**:
- Ensure using `input_title` not `title` in Module 5
- Ensure using `input_author` not `author` in Module 5  
- Check all field names match the streamlined structure

**❌ Agent Returns Wrong Field Structure**:
- Verify agent is returning 8 analysis fields
- Verify agent is returning 17 enrichment fields
- Test endpoints: `curl -X GET http://localhost:3002/health`

**❌ Quality Gates Not Triggering**:
```sql
-- Check trigger functions exist
SELECT proname FROM pg_proc WHERE proname LIKE '%streamlined%';
```

### **Performance Monitoring**

**Check Field Reduction Impact**:
```sql
-- Original vs Streamlined field counts
SELECT 
    'book_analysis_results' as table_name,
    COUNT(*) as field_count
FROM information_schema.columns 
WHERE table_name = 'book_analysis_results'
UNION ALL
SELECT 
    'book_analysis_results_streamlined' as table_name,
    COUNT(*) as field_count
FROM information_schema.columns 
WHERE table_name = 'book_analysis_results_streamlined';
```

**Agent Response Time Testing**:
```bash
# Test analysis endpoint
time curl -X POST http://localhost:3002/claude/hybrid-analysis \
  -H "Content-Type: application/json" \
  -d '{"book_id": "test", "title": "Test Book", "author": "Test Author"}'

# Test enrichment endpoint  
time curl -X POST http://localhost:3002/claude/enrichment-execution \
  -H "Content-Type: application/json" \
  -d '{"book_id": "test", "analysis_data": {}, "original_book": {"title": "Test", "author_name": "Test"}}'
```

### **File Locations**
- **Schema**: `islamic-text-workflow/make-com-integration/database/streamlined-schema.sql`
- **Migration**: `islamic-text-workflow/make-com-integration/database/migrate-to-streamlined.sql`
- **Agent Code**: `islamic-text-workflow/make-com-integration/production/claude-desktop-agent.js`
- **Scenario**: `islamic-text-workflow/make-com-integration/production/final_make_scenario.json`
- **Field Mapping**: `islamic-text-workflow/make-com-integration/STREAMLINED_FIELD_MAPPING.md`

---

## 📋 **Quick Reference for Make.com Building**

### **Essential Connection Details**
- **Supabase URL**: `https://aayvvcpxafzhcjqewwja.supabase.co`
- **API Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ2Nzc1NCwiZXhwIjoyMDYyMDQzNzU0fQ.PHNLmAb0-jzy0CGl3ThVdgXZkAGTBWLxC5O-RDgp_yQ`
- **Connection Name**: `supabase-imam-lib`

### **Current Webhook URLs** (Verify before building)
- **Analysis**: `https://a57b-2601-403-4280-2f0-34ff-ffe9-2152-b9e0.ngrok-free.app/claude/hybrid-analysis`
- **Enrichment**: `https://a57b-2601-403-4280-2f0-34ff-ffe9-2152-b9e0.ngrok-free.app/claude/enrichment-execution`

### **Key Table Names**
- **Queue**: `book_processing_queue`
- **Books**: `books`
- **Analysis Storage**: `book_analysis_results_streamlined`
- **Enrichment Storage**: `book_enrichment_results_streamlined`

### **Critical Field Mappings**
- **Module 1 Filter**: `status=eq.pending`
- **Module 5 Table**: `book_analysis_results_streamlined`
- **Module 7 Table**: `book_enrichment_results_streamlined`
- **Module 8 Fields**: `final_title_alias`, `final_keywords`, `final_description`

### **Pre-Build Checklist**
- [ ] Supabase connection created and tested
- [ ] Agent running on port 3002
- [ ] ngrok tunnel active and tested
- [ ] Webhook URLs updated in Modules 4 & 6
- [ ] Streamlined database tables deployed
- [ ] 507 books confirmed in processing queue

**Ready to build your Make.com scenario!** 🚀