# 🚀 Simple Google Sheets to Library Setup

**What this does**: Automatically add books from Google Sheets to your library database.

---

## ✅ **System is Already Working**

The database is deployed and processing books automatically. You just need to connect Google Sheets.

**Current Status**: 
- ✅ Database functions working
- ✅ All books processed and queued for enrichment  
- ✅ Duplicate detection working 

---

## 📊 **Step 1: Create Your Google Sheet**

Create a sheet with these columns:

| Column A | Column B | Column C | Column D | Column E |
|----------|----------|----------|----------|----------|
| **Title** | **Author** | **Status** | **Notes** | **Processed At** |

**Example**:
```
Kitab al-Irshad          | Sheikh al-Mufid    | Processing | Sending... | 2025-01-07 15:30
Al-Kafi                  | al-Kulayni         | Completed  | Success    | 2025-01-07 15:31
```

---

## 🔧 **Step 2: Add Google Apps Script**

1. In your Google Sheet: **Extensions** → **Apps Script**
2. Delete default code and paste this:

```javascript
// Configuration
const SUPABASE_URL = 'https://aayvvcpxafzhcjqewwja.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY0Njc3NTQsImV4cCI6MjA2MjA0Mzc1NH0.pQ12CUZnA8iD7_QxTEMK3AyJfNH0-H03-oinLxVHfg0';

// Column positions
const COLUMNS = {
  TITLE: 1,    // Column A
  AUTHOR: 2,   // Column B  
  STATUS: 3,   // Column C
  NOTES: 4,    // Column D
  PROCESSED: 5 // Column E
};

/**
 * Automatically runs when you edit the sheet
 */
function onEdit(e) {
  // Guard against undefined event object
  if (!e || !e.range) {
    console.log('onEdit called without valid event object');
    return;
  }
  
  const range = e.range;
  const sheet = range.getSheet();
  
  // Only process data rows (skip header)
  if (range.getRow() < 2) return;
  
  // Only process if Title or Author columns were edited
  if (range.getColumn() <= 2) {
    const row = range.getRow();
    processBookEntry(sheet, row);
  }
}

/**
 * Process a book entry and send to database
 */
function processBookEntry(sheet, rowNumber) {
  try {
    // Get data from the row
    const title = sheet.getRange(rowNumber, COLUMNS.TITLE).getValue();
    const author = sheet.getRange(rowNumber, COLUMNS.AUTHOR).getValue();
    
    // Skip if missing required data
    if (!title || !author) {
      updateRowStatus(sheet, rowNumber, 'Incomplete', 'Missing title or author');
      return;
    }
    
    // Update status to processing
    updateRowStatus(sheet, rowNumber, 'Processing', 'Sending to database...');
    
    // Send to database
    const result = sendToDatabase(title, author, rowNumber);
    
    if (result.success) {
      updateRowStatus(sheet, rowNumber, 'Sent', 'Successfully sent');
      
      // Wait and check if processed
      Utilities.sleep(3000); // Wait 3 seconds
      checkProcessingStatus(sheet, rowNumber, result.stagingId);
    } else {
      updateRowStatus(sheet, rowNumber, 'Error', result.error);
    }
    
  } catch (error) {
    updateRowStatus(sheet, rowNumber, 'Error', 'Script error: ' + error.message);
    console.error('processBookEntry error:', error);
  }
}

/**
 * Send book data to database
 */
function sendToDatabase(title, author, rowNumber) {
  try {
    const payload = {
      title: title.toString().trim(),
      author_name: author.toString().trim(),
      sheets_row_number: rowNumber,
      sheets_source: 'Google Sheets Direct Import',
      sheets_imported_at: new Date().toISOString()
    };
    
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Prefer': 'return=representation'
      },
      payload: JSON.stringify(payload)
    };
    
    const response = UrlFetchApp.fetch(`${SUPABASE_URL}/rest/v1/book_author_staging`, options);
    
    if (response.getResponseCode() === 201) {
      const responseData = JSON.parse(response.getContentText());
      return {
        success: true,
        stagingId: responseData[0].id,
        data: responseData[0]
      };
    } else {
      return {
        success: false,
        error: `HTTP ${response.getResponseCode()}: ${response.getContentText()}`
      };
    }
    
  } catch (error) {
    return {
      success: false,
      error: 'Network error: ' + error.message
    };
  }
}

/**
 * Check if book was processed successfully
 */
function checkProcessingStatus(sheet, rowNumber, stagingId) {
  try {
    const options = {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    };
    
    const response = UrlFetchApp.fetch(
      `${SUPABASE_URL}/rest/v1/book_author_staging?id=eq.${stagingId}&select=*`, 
      options
    );
    
    if (response.getResponseCode() === 200) {
      const data = JSON.parse(response.getContentText());
      if (data.length > 0) {
        const entry = data[0];
        updateStatusFromDatabase(sheet, rowNumber, entry);
      }
    }
    
  } catch (error) {
    console.error('checkProcessingStatus error:', error);
  }
}

/**
 * Update status based on database processing
 */
function updateStatusFromDatabase(sheet, rowNumber, entry) {
  let status = 'Processing';
  let notes = 'In system';
  
  switch (entry.processing_status) {
    case 'completed':
      status = 'Completed';
      notes = 'Successfully added to library';
      break;
      
    case 'duplicate_detected':
      status = 'Duplicate';
      notes = 'Already exists in library';
      break;
      
    case 'error':
      status = 'Error';
      notes = 'Processing failed';
      break;
  }
  
  updateRowStatus(sheet, rowNumber, status, notes);
}

/**
 * Update the status columns
 */
function updateRowStatus(sheet, rowNumber, status, notes) {
  sheet.getRange(rowNumber, COLUMNS.STATUS).setValue(status);
  sheet.getRange(rowNumber, COLUMNS.NOTES).setValue(notes);
  sheet.getRange(rowNumber, COLUMNS.PROCESSED).setValue(new Date());
}

/**
 * Test the connection (run this first)
 */
function testConnection() {
  try {
    const options = {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    };
    
    const response = UrlFetchApp.fetch(`${SUPABASE_URL}/rest/v1/book_author_staging?limit=1`, options);
    
    if (response.getResponseCode() === 200) {
      console.log('✅ Connection successful!');
      return true;
    } else {
      console.log('❌ Connection failed:', response.getResponseCode());
      return false;
    }
  } catch (error) {
    console.log('❌ Connection error:', error.message);
    return false;
  }
}
```

---

## ⚡ **Step 3: Set Up Automatic Processing**

1. In Apps Script editor, click the **trigger icon** (⏰)
2. Click **+ Add Trigger**
3. Configure:
   - **Function**: `onEdit`
   - **Event source**: `From spreadsheet`
   - **Event type**: `On edit`
4. **Save**

---

## 🧪 **Step 4: Test**

1. **Test Connection**: In Apps Script, run `testConnection()`
2. **Add Test Book**: In your sheet, add:
   - A2: `Test Book Title`
   - B2: `Test Author Name`
3. **Watch**: Columns C, D, E should update automatically

---

## 🎯 **How It Works**

```
Google Sheets → Database Staging → Library Tables → Enrichment Queue
```

1. **You type** book title and author in Google Sheets
2. **Script automatically** sends data to staging database
3. **Database automatically** processes entry:
   - Checks for duplicates
   - Creates author (if new)
   - Creates book (if not duplicate)
   - Adds to enrichment queue
4. **Status updates** back to Google Sheets

---

## 🔧 **Troubleshooting**

**Connection Failed?**
- Check your internet connection
- Verify the script was saved properly

**Not Processing?**
- Make sure trigger is set up
- Check that you're editing columns A or B
- Row 1 is header, data starts at row 2

**Stuck Processing?**
- Wait 10 seconds, it may take time
- Books are processed in batches automatically

---

## 📊 **Monitor Your Library**

Database automatically processes books every few minutes. Your books flow through this pipeline:

1. **Google Sheets** (your input)
2. **Staging System** (duplicate detection)
3. **Library Database** (searchable books)
4. **Enrichment Queue** (AI enhancement)

---

**🎉 Ready to Use!**

Just start adding books to your Google Sheet. The system handles everything else automatically.