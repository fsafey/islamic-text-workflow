# Google Apps Script Direct Integration Setup

## 🎯 **Complete Google Sheets to Supabase Integration**

This guide provides everything needed to set up direct Google Sheets integration with your Supabase staging system using Google Apps Script.

---

## 📊 **Google Sheet Setup**

### **1. Create Your Book Intake Sheet**

Create a new Google Sheet with this structure:

| Column | Header | Purpose |
|--------|--------|---------|
| A | Title | Book title |
| B | Author | Author name |
| C | Status | Auto-updated by script |
| D | Notes | Auto-updated by script |
| E | Processed At | Auto-updated by script |

### **2. Sample Data Format**
```
Title                          | Author                        | Status     | Notes           | Processed At
Kitab al-Irshad               | Sheikh al-Mufid               | Processing | Sending to DB... | 2025-01-07 15:30
Al-Kafi                       | Muhammad ibn Ya'qub al-Kulayni| Completed  | Successfully added | 2025-01-07 15:31
Nahj al-Balagha               | Compiled by Sharif al-Radi    | Duplicate  | Already exists  | 2025-01-07 15:32
```

---

## 🔧 **Google Apps Script Code**

### **Script 1: Main Integration Script**

```javascript
/**
 * Islamic Library Google Sheets to Supabase Integration
 * Automatically sends book data to staging system when rows are added/edited
 */

// Configuration
const SUPABASE_URL = 'https://aayvvcpxafzhcjqewwja.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY0Njc3NTQsImV4cCI6MjA2MjA0Mzc1NH0.pQ12CUZnA8iD7_QxTEMK3AyJfNH0-H03-oinLxVHfg0'; // Get from Supabase dashboard

// Column mappings
const COLUMNS = {
  TITLE: 1,    // Column A
  AUTHOR: 2,   // Column B  
  STATUS: 3,   // Column C
  NOTES: 4,    // Column D
  PROCESSED: 5 // Column E
};

/**
 * Triggered when any cell is edited
 */
function onEdit(e) {
  // Guard against undefined event object
  if (!e || !e.range) {
    console.log('onEdit called without valid event object');
    return;
  }
  
  const range = e.range;
  const sheet = range.getSheet();
  
  // Only process main data rows (skip header)
  if (range.getRow() < 2) return;
  
  // Only process if Title or Author columns were edited
  if (range.getColumn() <= 2) {
    const row = range.getRow();
    processBookEntry(sheet, row);
  }
}

/**
 * Process a book entry and send to Supabase
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
    
    // Send to Supabase
    const result = sendToSupabase(title, author, rowNumber);
    
    if (result.success) {
      updateRowStatus(sheet, rowNumber, 'Sent', 'Successfully sent to staging');
      
      // Start monitoring for processing completion using Utilities.sleep
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
 * Send book data to Supabase staging table
 */
function sendToSupabase(title, author, rowNumber) {
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
 * Check if staging entry has been processed
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
        updateStatusFromStaging(sheet, rowNumber, entry);
      }
    }
    
  } catch (error) {
    console.error('checkProcessingStatus error:', error);
  }
}

/**
 * Update row status based on staging entry data
 */
function updateStatusFromStaging(sheet, rowNumber, stagingEntry) {
  let status = 'Processing';
  let notes = 'In staging system';
  
  switch (stagingEntry.processing_status) {
    case 'completed':
      status = 'Completed';
      notes = 'Successfully added to library';
      if (stagingEntry.added_to_processing_queue) {
        notes += ' and queued for enrichment';
      }
      break;
      
    case 'duplicate_detected':
      status = 'Duplicate';
      notes = 'Duplicate detected - not added';
      if (stagingEntry.duplicate_type === 'book_duplicate') {
        notes = 'Book already exists in library';
      }
      break;
      
    case 'error':
      status = 'Error';
      notes = 'Processing failed';
      if (stagingEntry.processing_errors && stagingEntry.processing_errors.length > 0) {
        notes += ': ' + stagingEntry.processing_errors[0];
      }
      break;
      
    case 'book_created':
      status = 'Book Created';
      notes = 'Book successfully created';
      break;
      
    case 'author_created':
      status = 'Author Created';
      notes = 'Author processed, creating book...';
      break;
  }
  
  updateRowStatus(sheet, rowNumber, status, notes);
}

/**
 * Update the status and notes for a row
 */
function updateRowStatus(sheet, rowNumber, status, notes) {
  sheet.getRange(rowNumber, COLUMNS.STATUS).setValue(status);
  sheet.getRange(rowNumber, COLUMNS.NOTES).setValue(notes);
  sheet.getRange(rowNumber, COLUMNS.PROCESSED).setValue(new Date());
}

/**
 * Bulk process all rows (for initial setup)
 */
function processAllRows() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const lastRow = sheet.getLastRow();
  
  for (let row = 2; row <= lastRow; row++) {
    const title = sheet.getRange(row, COLUMNS.TITLE).getValue();
    const author = sheet.getRange(row, COLUMNS.AUTHOR).getValue();
    
    if (title && author) {
      processBookEntry(sheet, row);
      Utilities.sleep(1000); // Wait 1 second between requests
    }
  }
}

/**
 * Test function to verify Supabase connection
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
      console.log('Response:', response.getContentText());
      return true;
    } else {
      console.log('❌ Connection failed:', response.getResponseCode(), response.getContentText());
      return false;
    }
  } catch (error) {
    console.log('❌ Connection error:', error.message);
    return false;
  }
}

/**
 * Manual test function for processing a specific row
 * Use this to test without triggering onEdit
 */
function testProcessRow() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const testRow = 2; // Change this to test different rows
  
  console.log('Testing row:', testRow);
  processBookEntry(sheet, testRow);
}

/**
 * Test with sample data (creates a test row)
 */
function testWithSampleData() {
  const sheet = SpreadsheetApp.getActiveSheet();
  
  // Add test data to a new row
  const lastRow = sheet.getLastRow() + 1;
  sheet.getRange(lastRow, COLUMNS.TITLE).setValue('Test Book - ' + new Date().getTime());
  sheet.getRange(lastRow, COLUMNS.AUTHOR).setValue('Test Author - Script');
  
  console.log('Added test data to row:', lastRow);
  
  // Process the test row
  processBookEntry(sheet, lastRow);
}
```

---

## 🔑 **Supabase API Key Setup**

### **1. Get Your Supabase Anon Key**

1. Go to your Supabase dashboard: https://supabase.com/dashboard
2. Select your project: `imam-lib-masha-allah`
3. Go to Settings → API
4. Copy the `anon public` key
5. Replace `YOUR_SUPABASE_ANON_KEY` in the script

### **2. Verify API Access**

Test your connection by running the `testConnection()` function in the Apps Script editor.

---

## ⚙️ **Apps Script Setup Steps**

### **1. Create the Apps Script Project**

1. In your Google Sheet, go to `Extensions` → `Apps Script`
2. Delete the default `myFunction`
3. Paste the complete script code above
4. Save the project with name: "Islamic Library Integration"

### **2. Set Up Triggers**

1. In Apps Script editor, click the trigger icon (⏰)
2. Click `+ Add Trigger`
3. Configure:
   - Choose function: `onEdit`
   - Event source: `From spreadsheet`
   - Event type: `On edit`
4. Save the trigger

### **3. Test the Integration**

1. Run `testConnection()` function first
2. Add a test book in your sheet:
   - A1: "Test Book Title"
   - B1: "Test Author Name"
3. Watch columns C, D, E update automatically

---

## 📊 **Advanced Features**

### **Script 2: Batch Processing and Monitoring**

```javascript
/**
 * Advanced monitoring and batch processing functions
 */

/**
 * Get staging system status
 */
function getStagingStatus() {
  try {
    const options = {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    };
    
    const response = UrlFetchApp.fetch(
      `${SUPABASE_URL}/rest/v1/staging_processing_dashboard`, 
      options
    );
    
    if (response.getResponseCode() === 200) {
      const data = JSON.parse(response.getContentText());
      console.log('Staging Status:', data);
      return data;
    }
  } catch (error) {
    console.error('getStagingStatus error:', error);
  }
}

/**
 * Process all staging entries (trigger processing)
 */
function processAllStagingEntries() {
  try {
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      },
      payload: JSON.stringify({})
    };
    
    const response = UrlFetchApp.fetch(
      `${SUPABASE_URL}/rest/v1/rpc/process_all_new_staging_entries`, 
      options
    );
    
    if (response.getResponseCode() === 200) {
      const result = JSON.parse(response.getContentText());
      console.log('Processing Results:', result);
      return result;
    }
  } catch (error) {
    console.error('processAllStagingEntries error:', error);
  }
}

/**
 * Update all sheet rows with latest status
 */
function refreshAllStatuses() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const lastRow = sheet.getLastRow();
  
  for (let row = 2; row <= lastRow; row++) {
    const title = sheet.getRange(row, COLUMNS.TITLE).getValue();
    const author = sheet.getRange(row, COLUMNS.AUTHOR).getValue();
    
    if (title && author) {
      // Find staging entry for this row
      findAndUpdateStagingStatus(sheet, row, title, author);
      Utilities.sleep(500); // Pause between requests
    }
  }
}

/**
 * Find staging entry and update row status
 */
function findAndUpdateStagingStatus(sheet, rowNumber, title, author) {
  try {
    const options = {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    };
    
    const encodedTitle = encodeURIComponent(title);
    const encodedAuthor = encodeURIComponent(author);
    
    const response = UrlFetchApp.fetch(
      `${SUPABASE_URL}/rest/v1/book_author_staging?title=eq.${encodedTitle}&author_name=eq.${encodedAuthor}&order=created_at.desc&limit=1`, 
      options
    );
    
    if (response.getResponseCode() === 200) {
      const data = JSON.parse(response.getContentText());
      if (data.length > 0) {
        updateStatusFromStaging(sheet, rowNumber, data[0]);
      }
    }
  } catch (error) {
    console.error('findAndUpdateStagingStatus error:', error);
  }
}

/**
 * Create a summary of all processing
 */
function createProcessingSummary() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const stagingStatus = getStagingStatus();
  
  // Create summary in a new sheet or range
  const summaryRange = sheet.getRange('G1:H10');
  const summaryData = [
    ['Processing Summary', ''],
    ['Total Entries', ''],
    ['Completed', ''],
    ['Duplicates', ''],
    ['Errors', ''],
    ['In Progress', ''],
    ['', ''],
    ['Last Updated', new Date()],
  ];
  
  if (stagingStatus && stagingStatus.length > 0) {
    let completed = 0, duplicates = 0, errors = 0, inProgress = 0;
    
    stagingStatus.forEach(status => {
      if (status.processing_status === 'completed') completed += status.count;
      else if (status.processing_status === 'duplicate_detected') duplicates += status.count;
      else if (status.processing_status === 'error') errors += status.count;
      else inProgress += status.count;
    });
    
    summaryData[1][1] = completed + duplicates + errors + inProgress;
    summaryData[2][1] = completed;
    summaryData[3][1] = duplicates;
    summaryData[4][1] = errors;
    summaryData[5][1] = inProgress;
  }
  
  summaryRange.setValues(summaryData);
}
```

---

## 🔄 **Automated Processing Setup**

### **Script 3: Scheduled Processing**

```javascript
/**
 * Set up time-driven triggers for automatic processing
 */
function setupAutomaticProcessing() {
  // Delete existing triggers
  const triggers = ScriptApp.getProjectTriggers();
  triggers.forEach(trigger => {
    if (trigger.getHandlerFunction() === 'automaticProcessing') {
      ScriptApp.deleteTrigger(trigger);
    }
  });
  
  // Create new trigger to run every 5 minutes
  ScriptApp.newTrigger('automaticProcessing')
    .timeBased()
    .everyMinutes(5)
    .create();
    
  console.log('Automatic processing trigger created - runs every 5 minutes');
}

/**
 * Automatic processing function (runs every 5 minutes)
 */
function automaticProcessing() {
  try {
    // Process any pending staging entries
    const result = processAllStagingEntries();
    
    if (result && (result.successful_books > 0 || result.duplicates_detected > 0)) {
      // Update sheet statuses
      refreshAllStatuses();
      
      // Update summary
      createProcessingSummary();
      
      console.log('Automatic processing completed:', result);
    }
  } catch (error) {
    console.error('automaticProcessing error:', error);
  }
}
```

---

## 🎯 **Deployment Checklist**

### **✅ Pre-Deployment**
- [ ] Google Sheet created with correct column structure
- [ ] Supabase anon key obtained and configured
- [ ] Apps Script project created and saved
- [ ] Connection tested with `testConnection()`

### **✅ Initial Setup**
- [ ] OnEdit trigger configured
- [ ] Test entry added to sheet
- [ ] Status updates working correctly
- [ ] Staging system receiving data

### **✅ Advanced Setup**
- [ ] Batch processing functions tested
- [ ] Automatic processing trigger configured
- [ ] Summary dashboard working
- [ ] Error handling tested

### **✅ Production Ready**
- [ ] All sheet rows processed successfully
- [ ] Duplicate detection working
- [ ] Error scenarios handled gracefully
- [ ] Monitoring and alerts configured

---

## 🚨 **Troubleshooting**

### **Common Issues**

**Connection Failed**
```javascript
// Check API key
console.log('API Key length:', SUPABASE_ANON_KEY.length);
// Should be ~200+ characters

// Test URL
console.log('URL:', SUPABASE_URL);
// Should be https://aayvvcpxafzhcjqewwja.supabase.co
```

**Trigger Not Working**
```javascript
// Check if trigger exists
function listTriggers() {
  const triggers = ScriptApp.getProjectTriggers();
  triggers.forEach(trigger => {
    console.log('Trigger:', trigger.getHandlerFunction(), trigger.getEventType());
  });
}
```

**Data Not Processing**
```javascript
// Check staging table directly
function checkStagingTable() {
  const options = {
    method: 'GET',
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    }
  };
  
  const response = UrlFetchApp.fetch(
    `${SUPABASE_URL}/rest/v1/book_author_staging?order=created_at.desc&limit=5`, 
    options
  );
  
  console.log('Recent staging entries:', response.getContentText());
}
```

---

## 📈 **Success Metrics**

### **Performance Targets**
- **< 3 seconds** from sheet edit to status update
- **95%+ success rate** for data transmission
- **99%+ duplicate detection accuracy**
- **< 1 minute** total processing time per book

### **Quality Metrics**
- **Zero manual intervention** for standard entries
- **Complete audit trail** from sheet to library
- **Real-time status updates** for all entries
- **Automatic error recovery** for temporary failures

---

**🚀 Ready to deploy Google Sheets Direct Integration!**

This system provides a seamless, user-friendly interface for book intake while maintaining complete integration with your sophisticated staging and processing pipeline.

*Transform book entry from manual database work into simple Google Sheets editing with automatic library enhancement.*