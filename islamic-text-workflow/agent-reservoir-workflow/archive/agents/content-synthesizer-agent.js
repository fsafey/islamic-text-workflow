const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const TokenTracker = require('../lib/TokenTracker');
const ClaudeCodeExecutor = require('../lib/ClaudeCodeExecutor');

const app = express();
app.use(express.json());

// Initialize token tracking for this agent
const tokenTracker = new TokenTracker('content_synthesizer');

// Initialize Claude Code executor
const claudeExecutor = new ClaudeCodeExecutor('content_synthesizer', tokenTracker);

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
    agent: 'Enhanced Content Synthesizer - Library Catalog Synthesis Specialist',
    status: 'active',
    mission: 'Transform mapper research into library catalog fields',
    methodology: 'Spartan Research-to-Catalog Transformation',
    fields_synthesized: 'categories, keywords, description, title_alias',
    source_data: 'Flowchart Mapper + Network Mapper research findings',
    processed: processedBooks,
    errors,
    timestamp: new Date().toISOString() 
  });
});

// Token usage endpoint for orchestrator monitoring
app.get('/agent-tokens', (req, res) => {
  res.json(tokenTracker.getTokenUsage());
});

// Token reset endpoint for orchestrator-initiated restarts
app.post('/reset-tokens', (req, res) => {
  tokenTracker.resetTokens();
  res.json({ 
    success: true, 
    message: 'Token usage reset successfully',
    new_usage: tokenTracker.getTokenUsage()
  });
});

// Process next available book
app.post('/process', async (req, res) => {
  try {
    console.log('🔬 Enhanced Content Synthesizer: Looking for completed mapper research...');
    
    // Get books ready for synthesis (all other agents completed)
    const { data: booksReady, error: queryError } = await supabase
      .rpc('get_books_ready_for_agent', { agent_type: 'synthesis' });
    
    if (queryError || !booksReady || booksReady.length === 0) {
      return res.json({ message: 'No books ready for content synthesis', available: 0 });
    }
    
    console.log(`🧬 Found ${booksReady.length} books ready for library catalog synthesis`);
    
    const results = [];
    
    for (const book of booksReady) {
      try {
        console.log(`🎯 Synthesizing library fields: "${book.title}" by ${book.author_name}`);
        
        const synthesis = await synthesizeContent(book.title, book.author_name, book.reservoir_id);
        
        // Update reservoir with synthesis and mark complete
        const { error: updateError } = await supabase
          .from('book_enrichment_reservoir')
          .update({
            content_synthesis: synthesis,
            synthesis_completed: true,
            synthesis_completed_at: new Date().toISOString(),
            processing_stage: 'completed',
            agents_completed: [...(book.agents_completed || []), 'synthesis']
          })
          .eq('id', book.reservoir_id);
        
        if (updateError) {
          throw new Error(`Reservoir update failed: ${updateError.message}`);
        }
        
        processedBooks++;
        results.push({
          book_id: book.book_id,
          title: book.title,
          categories_count: synthesis.categories.length,
          keywords_count: synthesis.keywords.length,
          description_word_count: synthesis.description.split(' ').length,
          title_alias: synthesis.title_alias,
          success: true
        });
        
        console.log(`✅ Library catalog synthesis completed: ${book.title}`);
        
      } catch (error) {
        console.error(`❌ Content synthesis failed for ${book.title}:`, error.message);
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
      agent: 'Enhanced Content Synthesizer - Library Catalog Synthesis',
      processed: results.length,
      results,
      total_processed: processedBooks,
      total_errors: errors
    });
    
  } catch (error) {
    console.error('Enhanced Content Synthesizer processing error:', error);
    res.status(500).json({ error: error.message, agent: 'Enhanced Content Synthesizer' });
  }
});

// Synthesize mapper research into library catalog fields - UPGRADED TO CLAUDE CODE CLI
async function synthesizeContent(title, authorName, reservoirId) {
  console.log(`🔬 Synthesizing library catalog fields with Claude Code: ${title}`);
  
  try {
    // Get mapper research data from reservoir
    const mapperFindings = await getMapperFindings(reservoirId);
    
    // Define the system prompt for library catalog synthesis expertise
    const systemPrompt = `You are an expert library catalog synthesizer specializing in transforming Islamic scholarly research into user-friendly library catalog fields. Your expertise includes:

- Library science and catalog field optimization
- Islamic studies categorization and classification systems
- Keyword extraction and search optimization
- User-friendly description writing for academic texts
- Title translation and accessibility improvement
- Academic level assessment and audience targeting

Your mission is to transform mapper research into library catalog fields: categories, keywords, description, and title_alias.

Return structured JSON with these exact fields:
{
  "agent": "enhanced_content_synthesizer",
  "generated_at": "[ISO timestamp]",
  "synthesis_mission": "Spartan transformation of mapper research into library catalog fields",
  "analysis_method": "claude_code_library_synthesis",
  
  "categories": [
    "Primary Islamic Discipline",
    "Sub-Genre or Methodology",
    "Sectarian/School Classification",
    "Academic Level"
  ],
  
  "keywords": [
    "arabic_term_1", "arabic_term_2",
    "islamic_concept_1", "islamic_concept_2",
    "methodological_term_1", "comparative_term_1",
    "search_term_1", "academic_term_1"
  ],
  
  "description": "Brief user-friendly summary (50-150 words) for general library users",
  
  "title_alias": "English translation or alternative title for better accessibility",
  
  "synthesis_quality": {
    "categories_count": "Number of categories generated",
    "keywords_count": "Number of keywords generated",
    "description_word_count": "Word count of description",
    "title_alias_generated": "Boolean indicating if title alias was created"
  }
}

Focus on creating library catalog fields that are useful for both specialists and general users.`;

    // Create the synthesis prompt
    const synthesisPrompt = `Transform the following Islamic text mapper research into library catalog fields:

Title: ${title}
Author: ${authorName}

Flowchart Mapper Research:
${JSON.stringify(mapperFindings.flowchart, null, 2)}

Network Mapper Research:
${JSON.stringify(mapperFindings.network, null, 2)}

Please synthesize this research into:
1. Categories: 3-6 specific Islamic classifications from the research
2. Keywords: 15-30 searchable terms including Arabic terms, Islamic concepts, and methodological terms
3. Description: 50-150 word user-friendly summary for general library users
4. Title Alias: English translation or alternative title for better accessibility

Synthesis Guidelines:
- Extract categories from the intellectual tradition, genre, and methodology findings
- Generate keywords from central concepts, primary concepts, and Arabic terms
- Create descriptions that are accessible to both specialists and general users
- Produce title aliases that improve searchability and understanding
- Maintain scholarly accuracy while improving accessibility

Return comprehensive structured JSON synthesis suitable for Islamic digital library catalog systems.`;

    // Execute Claude Code CLI with library synthesis expertise
    const claudeResponse = await claudeExecutor.executeClaudeCode(
      synthesisPrompt,
      systemPrompt,
      { title, author_name: authorName, reservoir_id: reservoirId, mapper_findings: mapperFindings }
    );

    // Parse and validate the response
    if (claudeResponse.success && claudeResponse.content) {
      try {
        // Try to parse as JSON if it's not already parsed
        const synthesisResult = typeof claudeResponse.content === 'string' 
          ? JSON.parse(claudeResponse.content)
          : claudeResponse.content;

        // Ensure required fields are present
        if (synthesisResult && synthesisResult.categories && synthesisResult.keywords && synthesisResult.description) {
          console.log(`✅ Claude Code library synthesis completed: ${synthesisResult.categories.length} categories, ${synthesisResult.keywords.length} keywords`);
          return synthesisResult;
        } else {
          throw new Error('Claude Code response missing required library synthesis fields');
        }
      } catch (parseError) {
        console.error(`❌ Failed to parse Claude Code response as JSON:`, parseError.message);
        throw parseError;
      }
    } else {
      throw new Error('Claude Code execution failed or returned empty response');
    }
    
  } catch (error) {
    console.error(`❌ Claude Code library synthesis error for ${title}:`, error.message);
    
    // Fallback to basic synthesis using existing logic
    const mapperFindings = await getMapperFindings(reservoirId);
    const libraryFields = await synthesizeLibraryFields(mapperFindings.flowchart, mapperFindings.network, title);
    
    return {
      agent: 'enhanced_content_synthesizer',
      generated_at: new Date().toISOString(),
      synthesis_mission: 'Spartan transformation of mapper research into library catalog fields (fallback mode)',
      analysis_method: 'claude_code_error_fallback',
      
      // Library catalog fields from fallback
      categories: libraryFields.categories,
      keywords: libraryFields.keywords,
      description: libraryFields.description,
      title_alias: libraryFields.title_alias,
      
      // Quality metrics
      synthesis_quality: {
        categories_count: libraryFields.categories.length,
        keywords_count: libraryFields.keywords.length,
        description_word_count: libraryFields.description.split(' ').length,
        title_alias_generated: !!libraryFields.title_alias,
        fallback_used: true,
        error_encountered: error.message
      }
    };
  }
}

// Get mapper research data from reservoir
async function getMapperFindings(reservoirId) {
  try {
    const { data: reservoir, error } = await supabase
      .from('book_enrichment_reservoir')
      .select('flowchart_analysis, network_analysis')
      .eq('id', reservoirId)
      .single();
    
    if (error || !reservoir) {
      throw new Error('Could not retrieve mapper findings');
    }
    
    return {
      flowchart: reservoir.flowchart_analysis || {},
      network: reservoir.network_analysis || {}
    };
  } catch (error) {
    console.error('Error getting mapper findings:', error);
    return { flowchart: {}, network: {} };
  }
}

// Synthesize library fields from mapper research
async function synthesizeLibraryFields(flowchartData, networkData, title) {
  const categories = extractCategories(flowchartData, networkData);
  const keywords = generateKeywords(flowchartData, networkData);
  const description = createBriefDescription(flowchartData, networkData);
  const titleAlias = generateTitleAlias(title, flowchartData, networkData);
  
  return { categories, keywords, description, title_alias: titleAlias };
}

// Extract categories from mapper research
function extractCategories(flowchart, network) {
  const categories = [];
  
  // From Flowchart Mapper
  const primaryDiscipline = flowchart.concept?.genre || "Islamic Studies";
  const methodology = flowchart.intellectual_architecture?.methodological_approach;
  
  // From Network Mapper  
  const ideologicalStance = network.network_analysis?.ideological_stance;
  const intellectualTradition = network.network_analysis?.intellectual_tradition;
  
  // Combine into categories array
  const categoryList = [primaryDiscipline, methodology, ideologicalStance, intellectualTradition]
    .filter(cat => cat && cat !== "unknown");
  
  return categoryList.length > 0 ? categoryList : ["Islamic Studies"];
}

// Generate keywords from mapper research
function generateKeywords(flowchart, network) {
  const keywords = [];
  
  // Arabic terms from network central concepts
  const arabicTerms = network.primary_concepts?.map(c => extractArabicTerms(c.concept)) || [];
  keywords.push(...arabicTerms.flat().filter(term => term));
  
  // Islamic concepts from both mappers
  const islamicConcepts = [
    ...(flowchart.concept?.central_thesis?.match(/\b[A-Za-z]{3,}\b/g) || []),
    ...(network.central_node?.concept?.match(/\b[A-Za-z]{3,}\b/g) || [])
  ];
  keywords.push(...islamicConcepts);
  
  // Methodological terms from flowchart
  const methodTerms = flowchart.intellectual_architecture?.evidence_types || [];
  keywords.push(...methodTerms);
  
  // Central node concepts
  if (network.central_node?.concept) {
    keywords.push(network.central_node.concept);
  }
  
  // Remove duplicates and empty values
  const uniqueKeywords = [...new Set(keywords.filter(k => k && k.length > 2))];
  
  return uniqueKeywords.length > 0 ? uniqueKeywords : ["Islamic text", "religious studies"];
}

// Generate title alias (English translation or alternative title)
function generateTitleAlias(title, flowchart, network) {
  // If title is already in English, create a descriptive alias
  if (!title.match(/[\u0600-\u06FF]/)) {
    // Extract meaningful elements for alias
    const genre = flowchart.concept?.genre;
    const tradition = network.network_analysis?.intellectual_tradition;
    
    // For English titles, create descriptive alternative
    if (genre && tradition) {
      return `${genre} from ${tradition}`;
    }
    
    // Clean up existing title for alias
    return title.replace(/[_-]/g, ' ').replace(/\s+/g, ' ').trim();
  }
  
  // For Arabic titles, create English translation
  const commonTranslations = {
    'كتاب': 'The Book of',
    'شرح': 'Commentary on',
    'تفسير': 'Interpretation of', 
    'صحيح': 'Authentic Collection of',
    'جامع': 'Comprehensive Collection of',
    'مختصر': 'Summary of',
    'رسالة': 'Treatise on',
    'ديوان': 'Collection of',
    'تاريخ': 'History of',
    'طبقات': 'Biographical Dictionary of'
  };
  
  let alias = title;
  
  // Apply common translations
  for (const [arabic, english] of Object.entries(commonTranslations)) {
    if (title.includes(arabic)) {
      alias = title.replace(arabic, english);
      break;
    }
  }
  
  // If no translation found, use genre-based alias
  if (alias === title) {
    const genre = flowchart.concept?.genre || 'Islamic Text';
    const author = network.central_node?.concept || 'Islamic Scholar';
    alias = `${genre} by ${author}`;
  }
  
  return alias.trim();
}

// Create brief description from mapper research
function createBriefDescription(flowchart, network) {
  const genre = flowchart.concept?.genre || "Islamic text";
  const tradition = network.network_analysis?.intellectual_tradition || "Islamic scholarship";
  const complexity = flowchart.cataloging_synthesis?.complexity_assessment || "intermediate";
  const primaryDiscipline = flowchart.concept?.genre || "Islamic Studies";
  
  const description = `${genre} work from ${tradition}. ${complexity} level text contributing to ${primaryDiscipline}.`;
  
  return description.trim();
}

// Helper function to extract Arabic terms
function extractArabicTerms(text) {
  if (!text) return [];
  
  // Look for Arabic script or common Islamic terms
  const arabicMatches = text.match(/[\u0600-\u06FF]+/g) || [];
  const islamicTerms = text.match(/\b(hadith|sunnah|quran|fiqh|tafsir|aqidah|jihad|salah|zakat|hajj|umrah)\b/gi) || [];
  
  return [...arabicMatches, ...islamicTerms];
}

const PORT = process.env.PORT || 3004;
app.listen(PORT, () => {
  console.log(`🔬 Enhanced Content Synthesizer Agent (Library Catalog Specialist) running on port ${PORT}`);
  console.log(`📚 Mission: Spartan transformation of mapper research into library catalog fields`);
  console.log(`🎯 Output: categories, keywords, description, title_alias for production library`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`⚡ Process books: http://localhost:${PORT}/process`);
  console.log('🧬 Enhancement: Unfluffy synthesis from Flowchart + Network Mapper research');
});