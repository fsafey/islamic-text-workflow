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
    agent: 'Flowchart Mapper',
    status: 'active',
    processed: processedBooks,
    errors,
    timestamp: new Date().toISOString() 
  });
});

// Process next available book
app.post('/process', async (req, res) => {
  try {
    console.log('🗺️ Flowchart Mapper: Looking for books to analyze...');
    
    // Get books ready for flowchart analysis
    const { data: booksReady, error: queryError } = await supabase
      .rpc('get_books_ready_for_agent', { agent_type: 'flowchart' });
    
    if (queryError || !booksReady || booksReady.length === 0) {
      return res.json({ message: 'No books ready for flowchart analysis', available: 0 });
    }
    
    console.log(`📊 Found ${booksReady.length} books ready for flowchart mapping`);
    
    const results = [];
    
    for (const book of booksReady) {
      try {
        console.log(`🎯 Analyzing: "${book.title}" by ${book.author_name}`);
        
        const flowchartAnalysis = createFlowchartMap(book.title, book.author_name);
        
        // Update reservoir with flowchart findings
        const { error: updateError } = await supabase
          .from('book_enrichment_reservoir')
          .update({
            flowchart_analysis: flowchartAnalysis,
            flowchart_completed: true,
            flowchart_completed_at: new Date().toISOString()
          })
          .eq('id', book.reservoir_id);
        
        if (updateError) {
          throw new Error(`Reservoir update failed: ${updateError.message}`);
        }
        
        processedBooks++;
        results.push({
          book_id: book.book_id,
          title: book.title,
          structure_type: flowchartAnalysis.structure_type,
          success: true
        });
        
        console.log(`✅ Flowchart mapped: ${book.title}`);
        
      } catch (error) {
        console.error(`❌ Flowchart mapping failed for ${book.title}:`, error.message);
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
      agent: 'Flowchart Mapper',
      processed: results.length,
      results,
      total_processed: processedBooks,
      total_errors: errors
    });
    
  } catch (error) {
    console.error('Flowchart Mapper processing error:', error);
    res.status(500).json({ error: error.message, agent: 'Flowchart Mapper' });
  }
});

// Simple flowchart mapping - extract basic structure patterns
function createFlowchartMap(title, authorName) {
  console.log(`🗺️ Mapping structure for: ${title}`);
  
  const titleLower = title.toLowerCase();
  
  // Detect basic structure patterns
  let structureType = 'linear';
  let complexity = 'simple';
  let sections = [];
  
  if (titleLower.includes('introduction') || titleLower.includes('basic')) {
    structureType = 'introductory';
    sections = ['Introduction', 'Core Concepts', 'Applications', 'Conclusion'];
  } else if (titleLower.includes('commentary') || titleLower.includes('sharh')) {
    structureType = 'commentary';
    sections = ['Text Analysis', 'Interpretation', 'Context', 'Implications'];
  } else if (titleLower.includes('collection') || titleLower.includes('anthology')) {
    structureType = 'compilation';
    sections = ['Compilation Method', 'Categories', 'Sources', 'Index'];
  } else {
    structureType = 'standard';
    sections = ['Introduction', 'Main Content', 'Analysis', 'Conclusion'];
  }
  
  // Simple complexity assessment
  if (title.length > 50 || authorName.includes('al-')) {
    complexity = 'advanced';
  } else if (titleLower.includes('introduction') || titleLower.includes('guide')) {
    complexity = 'beginner';
  } else {
    complexity = 'intermediate';
  }
  
  return {
    structure_type: structureType,
    complexity_level: complexity,
    estimated_sections: sections,
    section_count: sections.length,
    generated_at: new Date().toISOString(),
    agent: 'flowchart_mapper'
  };
}

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🗺️ Flowchart Mapper Agent running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`⚡ Process books: http://localhost:${PORT}/process`);
  console.log('📊 Specialization: Simple structure mapping');
});