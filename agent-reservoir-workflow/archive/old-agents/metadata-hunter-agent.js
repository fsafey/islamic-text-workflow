const express = require('express');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(express.json());

// Supabase client with service role key
const supabase = createClient(
  'https://aayvvcpxafzhcjqewwja.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ2Nzc1NCwiZXhwIjoyMDYyMDQzNzU0fQ.PHNLmAb0-jzy0CGl3ThVdgXZkAGTBWLxC5O-RDgp_yQ'
);

let processedBooks = 0;
let errors = 0;

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    agent: 'Metadata Hunter',
    status: 'active',
    processed: processedBooks,
    errors,
    timestamp: new Date().toISOString() 
  });
});

// Process next available book
app.post('/process', async (req, res) => {
  try {
    console.log('🔍 Metadata Hunter: Looking for metadata gaps...');
    
    // Get books ready for metadata analysis
    const { data: booksReady, error: queryError } = await supabase
      .rpc('get_books_ready_for_agent', { agent_type: 'metadata' });
    
    if (queryError || !booksReady || booksReady.length === 0) {
      return res.json({ message: 'No books ready for metadata analysis', available: 0 });
    }
    
    console.log(`📋 Found ${booksReady.length} books ready for metadata hunting`);
    
    const results = [];
    
    for (const book of booksReady) {
      try {
        console.log(`🎯 Hunting metadata: "${book.title}" by ${book.author_name}`);
        
        const metadataFindings = await gatherMetadata(book.title, book.author_name, book.book_id);
        
        // Update reservoir with metadata findings
        const { error: updateError } = await supabase
          .from('book_enrichment_reservoir')
          .update({
            metadata_findings: metadataFindings,
            metadata_completed: true,
            metadata_completed_at: new Date().toISOString()
          })
          .eq('id', book.reservoir_id);
        
        if (updateError) {
          throw new Error(`Reservoir update failed: ${updateError.message}`);
        }
        
        processedBooks++;
        results.push({
          book_id: book.book_id,
          title: book.title,
          metadata_fields_found: metadataFindings.fields_discovered.length,
          categories_found: metadataFindings.categories.length,
          success: true
        });
        
        console.log(`✅ Metadata hunted: ${book.title}`);
        
      } catch (error) {
        console.error(`❌ Metadata hunting failed for ${book.title}:`, error.message);
        errors++;
        results.push({
          book_id: book.book_id,
          title: book.title,
          error: error.message,
          success: false
        });
      }
    }
    
    res.json({
      success: true,
      agent: 'Metadata Hunter',
      processed: results.length,
      results,
      total_processed: processedBooks,
      total_errors: errors
    });
    
  } catch (error) {
    console.error('Metadata Hunter processing error:', error);
    res.status(500).json({ error: error.message, agent: 'Metadata Hunter' });
  }
});

// Gather metadata from title and author patterns
async function gatherMetadata(title, authorName, bookId) {
  console.log(`🔍 Gathering metadata for: ${title}`);
  
  // Extract potential metadata from title patterns
  const metadataFields = extractMetadataFromTitle(title);
  
  // Determine categories
  const categories = categorizeBook(title, authorName);
  
  // Estimate publication details
  const publicationInfo = estimatePublicationInfo(title, authorName);
  
  // Check for existing metadata in database
  const existingMetadata = await checkExistingMetadata(bookId);
  
  return {
    fields_discovered: metadataFields,
    categories: categories,
    publication_info: publicationInfo,
    existing_metadata: existingMetadata,
    metadata_quality: assessMetadataQuality(metadataFields, categories),
    generated_at: new Date().toISOString(),
    agent: 'metadata_hunter'
  };
}

// Extract metadata clues from title
function extractMetadataFromTitle(title) {
  const fields = [];
  const titleLower = title.toLowerCase();
  
  // Volume/Part indicators
  if (titleLower.includes('volume') || titleLower.includes('vol') || titleLower.includes('part')) {
    fields.push({ field: 'volume_series', value: 'multi_volume_work', confidence: 0.8 });
  }
  
  // Edition indicators
  if (titleLower.includes('revised') || titleLower.includes('edition') || titleLower.includes('ed.')) {
    fields.push({ field: 'edition', value: 'revised_edition', confidence: 0.7 });
  }
  
  // Language indicators
  if (titleLower.includes('english') || titleLower.includes('translation')) {
    fields.push({ field: 'language', value: 'english_translation', confidence: 0.9 });
  } else {
    fields.push({ field: 'language', value: 'arabic_original', confidence: 0.6 });
  }
  
  // Format indicators
  if (titleLower.includes('commentary') || titleLower.includes('sharh')) {
    fields.push({ field: 'format', value: 'commentary', confidence: 0.9 });
  } else if (titleLower.includes('collection') || titleLower.includes('anthology')) {
    fields.push({ field: 'format', value: 'collection', confidence: 0.8 });
  }
  
  return fields;
}

// Categorize book based on title and author
function categorizeBook(title, authorName) {
  const categories = [];
  const titleLower = title.toLowerCase();
  
  // Religious categories
  if (titleLower.includes('quran') || titleLower.includes('tafsir')) {
    categories.push('Quranic Studies');
  }
  if (titleLower.includes('hadith') || titleLower.includes('sunnah')) {
    categories.push('Hadith Literature');
  }
  if (titleLower.includes('fiqh') || titleLower.includes('jurisprudence')) {
    categories.push('Islamic Law');
  }
  if (titleLower.includes('theology') || titleLower.includes('kalam')) {
    categories.push('Islamic Theology');
  }
  if (titleLower.includes('history') || titleLower.includes('tarikh')) {
    categories.push('Islamic History');
  }
  
  // Author-based categories
  if (authorName.includes('al-Bukhari') || authorName.includes('al-Tirmidhi')) {
    categories.push('Classical Hadith');
  }
  if (authorName.includes('al-Tabari') || authorName.includes('Ibn Kathir')) {
    categories.push('Classical Tafsir');
  }
  
  // Default category
  if (categories.length === 0) {
    categories.push('Islamic Literature');
  }
  
  return categories;
}

// Estimate publication information
function estimatePublicationInfo(title, authorName) {
  let estimatedYear = null;
  let estimatedPublisher = 'Unknown';
  
  // Classical authors with known death dates
  const classicalAuthors = {
    'al-Bukhari': 870,
    'al-Tirmidhi': 892,
    'al-Tabari': 923,
    'Ibn Kathir': 1373,
    'al-Ghazali': 1111
  };
  
  // Check for classical authors
  for (const [author, deathYear] of Object.entries(classicalAuthors)) {
    if (authorName.includes(author)) {
      estimatedYear = deathYear;
      estimatedPublisher = 'Classical Islamic Text';
      break;
    }
  }
  
  // Modern publication indicators
  if (!estimatedYear) {
    if (title.includes('Contemporary') || title.includes('Modern')) {
      estimatedYear = 2000;
      estimatedPublisher = 'Islamic Publishing House';
    } else {
      estimatedYear = 1400; // Default medieval period
      estimatedPublisher = 'Traditional Islamic Text';
    }
  }
  
  return {
    estimated_year: estimatedYear,
    estimated_publisher: estimatedPublisher,
    certainty: estimatedYear < 1000 ? 'high' : 'low'
  };
}

// Check existing metadata in database
async function checkExistingMetadata(bookId) {
  try {
    const { data: book, error } = await supabase
      .from('books')
      .select('keywords, description, publication_year, publisher')
      .eq('id', bookId)
      .single();
    
    if (error || !book) {
      return { status: 'not_found', fields: [] };
    }
    
    const existingFields = [];
    if (book.keywords) existingFields.push('keywords');
    if (book.description) existingFields.push('description');
    if (book.publication_year) existingFields.push('publication_year');
    if (book.publisher) existingFields.push('publisher');
    
    return {
      status: 'found',
      fields: existingFields,
      completeness: existingFields.length / 4 // Out of 4 key fields
    };
  } catch (error) {
    return { status: 'error', error: error.message };
  }
}

// Assess metadata quality
function assessMetadataQuality(fields, categories) {
  const score = (fields.length * 0.3) + (categories.length * 0.4) + 0.3; // Base score
  
  let quality = 'poor';
  if (score >= 2.0) quality = 'excellent';
  else if (score >= 1.5) quality = 'good';
  else if (score >= 1.0) quality = 'fair';
  
  return {
    score: Math.round(score * 100) / 100,
    quality: quality,
    recommendations: generateRecommendations(fields, categories)
  };
}

// Generate metadata improvement recommendations
function generateRecommendations(fields, categories) {
  const recommendations = [];
  
  if (fields.length < 3) {
    recommendations.push('Add more descriptive metadata fields');
  }
  if (categories.length < 2) {
    recommendations.push('Assign additional subject categories');
  }
  if (!fields.some(f => f.field === 'language')) {
    recommendations.push('Specify language information');
  }
  
  return recommendations;
}

const PORT = process.env.PORT || 3003;
app.listen(PORT, () => {
  console.log(`🔍 Metadata Hunter Agent running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`⚡ Process books: http://localhost:${PORT}/process`);
  console.log('📋 Specialization: Metadata discovery and cataloging');
});