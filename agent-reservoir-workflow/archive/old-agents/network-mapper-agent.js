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
    agent: 'Network Mapper',
    status: 'active',
    processed: processedBooks,
    errors,
    timestamp: new Date().toISOString() 
  });
});

// Process next available book
app.post('/process', async (req, res) => {
  try {
    console.log('🕸️ Network Mapper: Analyzing connections...');
    
    // Get books ready for network analysis
    const { data: booksReady, error: queryError } = await supabase
      .rpc('get_books_ready_for_agent', { agent_type: 'network' });
    
    if (queryError || !booksReady || booksReady.length === 0) {
      return res.json({ message: 'No books ready for network analysis', available: 0 });
    }
    
    console.log(`🔗 Found ${booksReady.length} books ready for network mapping`);
    
    const results = [];
    
    for (const book of booksReady) {
      try {
        console.log(`🎯 Mapping networks: "${book.title}" by ${book.author_name}`);
        
        const networkAnalysis = await createNetworkMap(book.title, book.author_name, book.book_id);
        
        // Update reservoir with network findings
        const { error: updateError } = await supabase
          .from('book_enrichment_reservoir')
          .update({
            network_analysis: networkAnalysis,
            network_completed: true,
            network_completed_at: new Date().toISOString()
          })
          .eq('id', book.reservoir_id);
        
        if (updateError) {
          throw new Error(`Reservoir update failed: ${updateError.message}`);
        }
        
        processedBooks++;
        results.push({
          book_id: book.book_id,
          title: book.title,
          connections_found: networkAnalysis.related_books.length,
          key_concepts: networkAnalysis.key_concepts.length,
          success: true
        });
        
        console.log(`✅ Network mapped: ${book.title} (${networkAnalysis.related_books.length} connections)`);
        
      } catch (error) {
        console.error(`❌ Network mapping failed for ${book.title}:`, error.message);
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
      agent: 'Network Mapper',
      processed: results.length,
      results,
      total_processed: processedBooks,
      total_errors: errors
    });
    
  } catch (error) {
    console.error('Network Mapper processing error:', error);
    res.status(500).json({ error: error.message, agent: 'Network Mapper' });
  }
});

// Simple network mapping - extract key concepts and find related books
async function createNetworkMap(title, authorName, bookId) {
  console.log(`🕸️ Building network for: ${title}`);
  
  // Extract key concepts from title and author
  const keyConcepts = extractKeyConcepts(title, authorName);
  
  // Find related books based on keywords
  const relatedBooks = await findRelatedBooks(title, authorName, bookId);
  
  // Calculate simple network metrics
  const networkMetrics = {
    concept_count: keyConcepts.length,
    connection_strength: relatedBooks.length > 0 ? 'high' : 'low',
    network_density: Math.min(relatedBooks.length / 10, 1.0) // Simple density measure
  };
  
  return {
    key_concepts: keyConcepts,
    related_books: relatedBooks,
    network_metrics: networkMetrics,
    generated_at: new Date().toISOString(),
    agent: 'network_mapper'
  };
}

// Extract key concepts from title and author name
function extractKeyConcepts(title, authorName) {
  const concepts = [];
  
  // Split title into meaningful words
  const titleWords = title.toLowerCase()
    .replace(/[^a-z\s]/g, ' ')
    .split(/\s+/)
    .filter(word => word.length > 3)
    .filter(word => !['book', 'kitab', 'sharh'].includes(word));
  
  // Add important title words as concepts
  titleWords.forEach(word => {
    concepts.push({
      text: word,
      type: 'title_concept',
      importance: 0.8
    });
  });
  
  // Add author as a concept if it's a known scholar
  if (authorName.includes('al-') || authorName.includes('ibn')) {
    concepts.push({
      text: authorName,
      type: 'author',
      importance: 0.9
    });
  }
  
  return concepts.slice(0, 5); // Keep top 5 concepts
}

// Find related books using simple keyword matching
async function findRelatedBooks(title, authorName, bookId) {
  try {
    // Get books by same author first
    const { data: sameAuthorBooks, error: authorError } = await supabase
      .from('books')
      .select('id, title')
      .ilike('author_name', `%${authorName}%`)
      .neq('id', bookId)
      .limit(3);
    
    const relatedBooks = [];
    
    if (sameAuthorBooks && !authorError) {
      sameAuthorBooks.forEach(book => {
        relatedBooks.push({
          book_id: book.id,
          title: book.title,
          connection_type: 'same_author',
          strength: 0.9
        });
      });
    }
    
    // Find books with similar keywords if they exist
    const titleWords = title.toLowerCase().split(/\s+/).filter(w => w.length > 4);
    
    if (titleWords.length > 0) {
      const { data: similarBooks, error: simError } = await supabase
        .from('books')
        .select('id, title, keywords')
        .neq('id', bookId)
        .limit(5);
        
      if (similarBooks && !simError) {
        similarBooks.forEach(book => {
          if (book.keywords && Array.isArray(book.keywords)) {
            const commonWords = titleWords.filter(word => 
              book.keywords.some(keyword => 
                keyword.toLowerCase().includes(word) || word.includes(keyword.toLowerCase())
              )
            );
            
            if (commonWords.length > 0) {
              relatedBooks.push({
                book_id: book.id,
                title: book.title,
                connection_type: 'keyword_similarity',
                strength: Math.min(commonWords.length / titleWords.length, 0.8)
              });
            }
          }
        });
      }
    }
    
    return relatedBooks.slice(0, 5); // Return top 5 related books
    
  } catch (error) {
    console.error('Error finding related books:', error);
    return [];
  }
}

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
  console.log(`🕸️ Network Mapper Agent running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`⚡ Process books: http://localhost:${PORT}/process`);
  console.log('🌐 Specialization: Simple concept networks and book connections');
});