# Google Sheets to Library Staging System

## 🎯 **Purpose**

Create a seamless pipeline from **Google Sheets** → **Staging Table** → **Library Processing** → **Enhanced Books** that allows easy book intake while preventing duplicates and ensuring data quality.

---

## 📊 **Staging Table: `book_intake_staging`**

### **Core Fields**
- `title` - Book title from Google Sheets
- `author_name` - Author name from Google Sheets
- `intake_status` - Processing workflow status
- `duplicate_check_status` - Duplicate detection results
- `target_book_id` - UUID prepared for books table insertion

### **Processing Workflow States**
1. **pending** → New entry from Google Sheets
2. **processing** → Duplicate detection and validation running
3. **validated** → Ready for library processing
4. **rejected** → Failed validation or confirmed duplicate
5. **completed** → Successfully processed into library
6. **error** → Processing error, needs manual review

---

## 🚀 **Google Sheets Setup**

### **Required Sheet Structure**
```
Column A: Title
Column B: Author
Column C: Status (auto-populated by Make.com)
Column D: Notes (auto-populated by Make.com)
```

### **Example Google Sheet Data**
| Title | Author | Status | Notes |
|-------|--------|--------|-------|
| Kitab al-Irshad | Sheikh al-Mufid | Processing | Checking for duplicates... |
| Al-Kafi | Muhammad ibn Ya'qub al-Kulayni | Validated | Ready for library processing |
| Nahj al-Balagha | Compiled by Sharif al-Radi | Duplicate | Already exists in library |

---

## ⚡ **Make.com Integration Workflow**

### **Module 1: Google Sheets Trigger**
**Type**: `google-sheets:WatchRows`

| Field | Value |
|-------|--------|
| **Connection** | Your Google Sheets connection |
| **Spreadsheet** | Your book intake spreadsheet |
| **Sheet** | Sheet name (e.g., "New Books 2025") |
| **Range** | A:B (Title and Author columns) |
| **Trigger** | On new row |

### **Module 2: Insert into Staging**
**Type**: `supabase:CreateRow`

| Field | Value |
|-------|--------|
| **Connection** | `supabase-imam-lib-enrichment` |
| **Table** | `book_intake_staging` |
| **title** | `{{1.values.0}}` (Column A) |
| **author_name** | `{{1.values.1}}` (Column B) |
| **google_sheets_source** | `"New Books 2025"` |
| **google_sheets_row_id** | `{{1.row}}` |
| **google_sheets_timestamp** | `{{now}}` |

### **Module 3: Duplicate Detection**
**Type**: `supabase:ExecuteSQL`

| Field | Value |
|-------|--------|
| **Connection** | `supabase-imam-lib-enrichment` |
| **SQL** | `SELECT * FROM check_staging_duplicates('{{2.data.title}}', '{{2.data.author_name}}')` |

### **Module 4: Update Duplicate Status**
**Type**: `supabase:UpdateRows`

| Field | Value |
|-------|--------|
| **Connection** | `supabase-imam-lib-enrichment` |
| **Table** | `book_intake_staging` |
| **Filter** | `id=eq.{{2.data.id}}` |
| **duplicate_check_status** | `{{if(length(3.data) > 0; "potential_duplicate"; "no_duplicate")}}` |
| **duplicate_book_id** | `{{first(3.data).book_id}}` |
| **duplicate_similarity_score** | `{{first(3.data).similarity_score}}` |

### **Module 5: Validation**
**Type**: `supabase:ExecuteSQL`

| Field | Value |
|-------|--------|
| **Connection** | `supabase-imam-lib-enrichment` |
| **SQL** | `SELECT validate_staging_entry('{{2.data.id}}')` |

### **Module 6: Update Status to Validated**
**Type**: `supabase:UpdateRows`

| Field | Value |
|-------|--------|
| **Connection** | `supabase-imam-lib-enrichment` |
| **Table** | `book_intake_staging` |
| **Filter** | `id=eq.{{2.data.id}} AND duplicate_check_status='no_duplicate'` |
| **intake_status** | `validated` |
| **books_table_insert_ready** | `true` |

### **Module 7: Update Google Sheets Status**
**Type**: `google-sheets:UpdateRow`

| Field | Value |
|-------|--------|
| **Connection** | Your Google Sheets connection |
| **Spreadsheet** | Your book intake spreadsheet |
| **Sheet** | Sheet name |
| **Row** | `{{1.row}}` |
| **Range** | `C{{1.row}}:D{{1.row}}` |
| **Values** | `[["{{4.data.duplicate_check_status}}", "{{if(4.data.duplicate_check_status = 'no_duplicate'; 'Ready for processing'; 'Needs review - potential duplicate')}}"]]` |

---

## 📈 **Staging Processing Workflow**

### **Stage 1: Intake from Google Sheets**
```sql
-- New entries arrive from Google Sheets
INSERT INTO book_intake_staging (title, author_name, google_sheets_source) 
VALUES ('New Book Title', 'Author Name', 'Sheet Source');
```

### **Stage 2: Duplicate Detection**
```sql
-- Check for potential duplicates
SELECT * FROM check_staging_duplicates('New Book Title', 'Author Name');

-- Update duplicate status
UPDATE book_intake_staging SET 
    duplicate_check_status = 'no_duplicate',
    intake_status = 'processing'
WHERE id = staging_id;
```

### **Stage 3: Validation**
```sql
-- Validate entry quality
SELECT validate_staging_entry(staging_id);

-- Mark as ready for library processing
UPDATE book_intake_staging SET
    intake_status = 'validated',
    books_table_insert_ready = true
WHERE id = staging_id AND duplicate_check_status = 'no_duplicate';
```

### **Stage 4: Library Processing**
```sql
-- Queue for 4-agent library enrichment
INSERT INTO book_processing_queue (book_id, status, priority)
SELECT target_book_id, 'pending', 1
FROM staging_ready_for_processing;
```

---

## 📊 **Monitoring & Management**

### **Staging Dashboard Query**
```sql
-- Overview of staging system status
SELECT * FROM staging_dashboard;

-- Results:
-- intake_status | duplicate_check_status | count | oldest_entry | newest_entry
-- pending       | pending                | 5     | 2025-01-07   | 2025-01-07
-- validated     | no_duplicate           | 12    | 2025-01-06   | 2025-01-07
-- rejected      | confirmed_duplicate    | 3     | 2025-01-06   | 2025-01-07
```

### **Ready for Processing**
```sql
-- Books ready for library processing
SELECT * FROM staging_ready_for_processing;
```

### **Manual Review Queue**
```sql
-- Entries needing manual review
SELECT * FROM staging_manual_review_queue;
```

### **Duplicate Detection Results**
```sql
-- Potential duplicates for review
SELECT * FROM staging_potential_duplicates;
```

---

## 🔧 **Advanced Features**

### **Author Matching Intelligence**
```sql
-- Find matching authors in existing database
SELECT * FROM find_matching_authors('Muhammad ibn Ya''qub al-Kulayni');

-- Results:
-- author_id | name | confidence_score
-- uuid-123  | Muhammad ibn Ya'qub al-Kulayni | 1.00
-- uuid-456  | al-Kulayni | 0.75
```

### **Bulk Processing Operations**
```sql
-- Process all validated entries to library
WITH validated_entries AS (
    SELECT target_book_id, title, author_name 
    FROM staging_ready_for_processing
)
INSERT INTO books (id, title, author_name, status)
SELECT target_book_id, title, author_name, 'available'
FROM validated_entries;

-- Mark as completed
UPDATE book_intake_staging SET 
    intake_status = 'completed',
    processed_at = NOW()
WHERE books_table_insert_ready = true;
```

### **Quality Control Reporting**
```sql
-- Daily intake report
SELECT 
    DATE(created_at) as intake_date,
    COUNT(*) as total_entries,
    COUNT(CASE WHEN intake_status = 'completed' THEN 1 END) as processed,
    COUNT(CASE WHEN duplicate_check_status = 'potential_duplicate' THEN 1 END) as duplicates_detected,
    COUNT(CASE WHEN manual_review_required THEN 1 END) as manual_reviews
FROM book_intake_staging
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY intake_date DESC;
```

---

## 🚨 **Error Handling & Recovery**

### **Common Issues & Solutions**

#### **Duplicate Detection False Positives**
```sql
-- Override false positive duplicate
UPDATE book_intake_staging SET
    duplicate_check_status = 'no_duplicate',
    duplicate_book_id = NULL,
    intake_status = 'validated',
    manual_review_required = false,
    validation_notes = 'Manually reviewed - not a duplicate'
WHERE id = staging_id;
```

#### **Google Sheets Connection Issues**
```sql
-- Check entries missing Google Sheets metadata
SELECT id, title, author_name, created_at 
FROM book_intake_staging 
WHERE google_sheets_source IS NULL 
   OR google_sheets_row_id IS NULL;
```

#### **Stalled Processing Recovery**
```sql
-- Reset stalled entries
UPDATE book_intake_staging SET
    intake_status = 'pending',
    processing_errors = 'Reset from stalled state: ' || NOW()
WHERE 
    intake_status = 'processing' 
    AND updated_at < NOW() - INTERVAL '1 hour';
```

---

## 📋 **Deployment Steps**

### **1. Deploy Staging Schema**
```bash
cd /Users/farieds/imam-lib-masha-allah/islamic-text-workflow/4-agent-reservoir-system

# Deploy staging table and functions
PGPASSWORD="sXm0id2x7pEjggUd" psql \
  -h aws-0-us-east-2.pooler.supabase.com \
  -p 5432 \
  -U postgres.aayvvcpxafzhcjqewwja \
  -d postgres \
  -f database/staging-area-schema.sql
```

### **2. Configure Google Sheets**
1. Create new Google Sheet with Title/Author columns
2. Share with Make.com service account
3. Set up Make.com Google Sheets connection
4. Test data entry and Make.com trigger

### **3. Deploy Make.com Workflow**
1. Configure 7-module workflow as specified above
2. Test with sample data
3. Verify duplicate detection works
4. Check Google Sheets status updates

### **4. Integration with Library Processing**
```sql
-- Connect staging to existing book processing queue
CREATE OR REPLACE FUNCTION stage_to_library_queue()
RETURNS INTEGER AS $$
DECLARE
    processed_count INTEGER := 0;
BEGIN
    -- Insert validated staging entries into processing queue
    INSERT INTO book_processing_queue (book_id, status, priority)
    SELECT 
        target_book_id,
        'pending',
        1
    FROM staging_ready_for_processing;
    
    GET DIAGNOSTICS processed_count = ROW_COUNT;
    
    -- Mark staging entries as queued
    UPDATE book_intake_staging SET
        intake_status = 'completed',
        processed_at = NOW()
    WHERE books_table_insert_ready = true;
    
    RETURN processed_count;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 **Success Metrics**

### **Quality Metrics**
- **95%+ duplicate detection accuracy** - Prevents library duplicates
- **90%+ automatic validation success** - Reduces manual review burden
- **<5 minute processing time** - Fast Google Sheets to staging pipeline
- **100% audit trail** - Complete tracking from Google Sheets to library

### **Operational Benefits**
- **Easy Book Intake**: Librarians add books via familiar Google Sheets interface
- **Automatic Quality Control**: Duplicate detection and validation without manual work
- **Seamless Integration**: Direct connection to existing library processing pipeline
- **Full Transparency**: Complete visibility into intake and processing status

### **User Experience**
- **Simple Interface**: Google Sheets familiar to all users
- **Real-time Feedback**: Status updates show processing progress
- **Error Prevention**: Duplicate detection prevents library pollution
- **Manual Override**: Review queue allows human decision-making when needed

---

## 🚀 **Next Steps**

### **Phase 1: Basic Staging (Current)**
1. ✅ Deploy staging table schema
2. 🔄 Configure Google Sheets integration
3. 🔄 Test duplicate detection and validation
4. 🔄 Integrate with existing book processing queue

### **Phase 2: Enhanced Intelligence**
1. Advanced author matching with fuzzy logic
2. Category prediction based on title analysis
3. Historical period detection from author names
4. Automated metadata suggestions

### **Phase 3: Advanced Features**
1. Bulk import from CSV/Excel files
2. API integration for external catalog imports
3. Image and cover processing pipeline
4. Advanced duplicate detection using semantic similarity

---

**Ready to deploy your Google Sheets to Library Staging System!** 🚀

This system provides a user-friendly intake process while maintaining data quality and preventing duplicates, creating a seamless bridge between casual book entry and your sophisticated library processing pipeline.

*Transform book intake from a manual, error-prone process into an intelligent, automated pipeline that maintains library quality while reducing administrative burden.*