const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');
const TokenTracker = require('../lib/TokenTracker');
const ClaudeCodeExecutor = require('../lib/ClaudeCodeExecutor');

const app = express();
app.use(express.json());

// Initialize token tracking for this agent
const tokenTracker = new TokenTracker('flowchart_mapper');

// Initialize Claude Code executor
const claudeExecutor = new ClaudeCodeExecutor('flowchart_mapper', tokenTracker);

// Supabase client with service role key
const supabase = createClient(
  'https://aayvvcpxafzhcjqewwja.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ2Nzc1NCwiZXhwIjoyMDYyMDQzNzU0fQ.PHNLmAb0-jzy0CGl3ThVdgXZkAGTBWLxC5O-RDgp_yQ'
);

let processedBooks = 0;
let errors = 0;

// Load methodology guidance on startup
let methodologyGuidance = '';
try {
  const guidancePath = path.join(__dirname, '../../guidance/FLOWCHART_MAPPER_GUIDANCE.md');
  methodologyGuidance = fs.readFileSync(guidancePath, 'utf8');
  console.log('📚 Loaded intellectual architecture analysis methodology');
} catch (error) {
  console.error('⚠️ Could not load methodology guidance:', error.message);
}

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    agent: 'Enhanced Flowchart Mapper - Intellectual Architecture Analyst',
    status: 'active',
    mission: 'Reverse-engineering the intellectual DNA of Islamic scholarship',
    methodology: 'Argument as Structure + Inferential Specificity + Logical Dependency',
    processed: processedBooks,
    errors,
    timestamp: new Date().toISOString() 
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
});

// Process next available book with intellectual architecture analysis
app.post('/process', async (req, res) => {
  try {
    console.log('🗺️ Intellectual Architecture Analyst: Deconstructing scholarly arguments...');
    
    // Get books ready for intellectual architecture analysis
    const { data: booksReady, error: queryError } = await supabase
      .rpc('get_books_ready_for_agent', { agent_type: 'flowchart' });
    
    if (queryError || !booksReady || booksReady.length === 0) {
      return res.json({ message: 'No books ready for intellectual architecture analysis', available: 0 });
    }
    
    console.log(`📚 Found ${booksReady.length} Islamic texts ready for architectural deconstruction`);
    
    const results = [];
    
    for (const book of booksReady) {
      try {
        console.log(`🔬 Analyzing intellectual architecture: "${book.title}" by ${book.author_name}`);
        console.log(`🎯 Mission: Reverse-engineering argumentative structure and scholarly methodology`);
        
        const architectureAnalysis = await analyzeIntellectualArchitecture(book.title, book.author_name);
        
        // Update reservoir with comprehensive intellectual architecture
        const { error: updateError } = await supabase
          .from('book_enrichment_reservoir')
          .update({
            flowchart_analysis: architectureAnalysis,
            flowchart_completed: true,
            flowchart_completed_at: new Date().toISOString(),
            agents_completed: [...(book.agents_completed || []), 'flowchart'],
            updated_at: new Date().toISOString()
          })
          .eq('id', book.reservoir_id);

        if (updateError) {
          console.error(`❌ Database update failed for ${book.title}:`, updateError);
          errors++;
          continue;
        }

        processedBooks++;
        results.push({
          book_id: book.book_id,
          title: book.title,
          concept_analysis: architectureAnalysis.concept?.central_thesis || 'Complex intellectual analysis',
          argument_pillars: architectureAnalysis.flowchart_map?.primary_divisions?.length || 0,
          scholarly_methodology: architectureAnalysis.concept?.methodology || 'Unknown',
          analysis_confidence: architectureAnalysis.research_quality?.confidence_level || 'preliminary',
          success: true
        });

        console.log(`✅ Intellectual architecture completed: ${book.title}`);
        console.log(`📋 Central thesis: ${architectureAnalysis.concept?.central_thesis?.substring(0, 100)}...`);
        console.log(`🏗️ Argument pillars: ${architectureAnalysis.flowchart_map?.primary_divisions?.length || 0}`);
        
      } catch (error) {
        console.error(`❌ Architecture analysis failed for ${book.title}:`, error.message);
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
      agent: 'Enhanced Flowchart Mapper - Intellectual Architecture',
      processed: results.length,
      results,
      total_processed: processedBooks,
      total_errors: errors
    });
    
  } catch (error) {
    console.error('❌ Processing error:', error);
    errors++;
    res.status(500).json({ error: error.message });
  }
});

// Core intellectual architecture analysis function - UPGRADED TO CLAUDE CODE CLI
async function analyzeIntellectualArchitecture(title, author) {
  console.log(`🔍 Conducting intellectual architecture analysis with Claude Code: ${title} by ${author}`);
  
  try {
    // Define the system prompt for Islamic scholarship expertise
    const systemPrompt = `You are an expert Islamic scholar specializing in intellectual architecture analysis of classical Islamic texts. Your expertise includes:

- Hadith sciences and commentary methodologies
- Quranic exegesis (tafsir) traditions
- Islamic jurisprudence (fiqh) frameworks
- Theological treatise structures
- Philosophical polemics and refutations
- Historical chronicle methodologies
- Biographical collection patterns

Your mission is to reverse-engineer the intellectual DNA of Islamic scholarly works by analyzing their argumentative architecture, logical progression, and scholarly apparatus.

For each text, provide comprehensive analysis in structured JSON format with these exact fields:

{
  "agent": "enhanced_flowchart_mapper",
  "generated_at": "[ISO timestamp]",
  "analysis_method": "claude_code_intellectual_architecture",
  "research_mission": "AI-powered Islamic scholarly architecture analysis",
  
  "concept": {
    "central_thesis": "Detailed analysis of the work's main argument and contribution",
    "genre": "Islamic text classification (hadith_commentary, quranic_commentary, philosophical_polemic, etc.)",
    "perspective": "Scholarly tradition and school affiliation",
    "methodology": "Academic approach and analytical framework used",
    "intellectual_context": "Historical and scholarly milieu"
  },
  
  "flowchart_map": {
    "primary_divisions": [
      {
        "section": "Major structural division name",
        "argumentative_purpose": "Why this section exists in the argument",
        "sub_divisions": [
          {
            "chapter": "Chapter or subsection name", 
            "logical_function": "Role in overall argument",
            "specific_evidence": ["Type of evidence used", "Sources referenced"],
            "analytical_depth": "Level of scholarly treatment"
          }
        ]
      }
    ],
    "argumentative_strategy": "Overall approach to building the argument",
    "logical_progression": "How the argument unfolds systematically"
  },
  
  "intellectual_architecture": {
    "logical_flow": "Description of argument's logical progression",
    "evidence_types": ["Primary source types", "Analytical methods", "Supporting authorities"],
    "argumentative_strategy": "How evidence builds toward conclusions",
    "scholarly_apparatus": "Research methodology and citation patterns",
    "methodological_innovation": "Unique contributions to Islamic scholarship"
  },
  
  "research_quality": {
    "analysis_depth": "comprehensive_claude_code_analysis",
    "confidence_level": "high_llm_analysis", 
    "complexity_level": "advanced_scholarly|intermediate_scholarly|introductory",
    "scholarly_significance": "Importance within Islamic intellectual tradition"
  },
  
  "cataloging_synthesis": {
    "argumentative_classification": "Genre classification for library systems",
    "intellectual_tradition": "School/tradition affiliation",
    "scholarly_apparatus": "Research methodology summary",
    "complexity_assessment": "Difficulty level for readers"
  }
}

Focus on authentic Islamic scholarly traditions and provide culturally sensitive, academically rigorous analysis.`;

    // Create the analysis prompt
    const analysisPrompt = `Conduct comprehensive intellectual architecture analysis for this Islamic text:

Title: ${title}
Author: ${author}

Please analyze:
1. The work's central thesis and Islamic scholarly genre
2. Its argumentative architecture and structural logic
3. The intellectual framework and evidence patterns
4. Research quality and scholarly significance

Provide detailed analysis following Islamic scholarly traditions with particular attention to:
- Classical Islamic methodologies (hadith sciences, tafsir, fiqh, kalam)
- Historical scholarly context and school affiliations
- Argumentative strategies specific to Islamic intellectual traditions
- Integration within the broader corpus of Islamic knowledge

Return comprehensive structured JSON analysis suitable for Islamic digital library cataloging.`;

    // Execute Claude Code CLI with Islamic scholarship expertise
    const claudeResponse = await claudeExecutor.executeClaudeCode(
      analysisPrompt,
      systemPrompt,
      { title, author_name: author }
    );

    // Parse and validate the response
    if (claudeResponse.success && claudeResponse.content) {
      try {
        // Try to parse as JSON if it's not already parsed
        const analysisResult = typeof claudeResponse.content === 'string' 
          ? JSON.parse(claudeResponse.content)
          : claudeResponse.content;

        // Ensure required fields are present
        if (analysisResult && analysisResult.concept && analysisResult.flowchart_map) {
          console.log(`✅ Claude Code analysis completed: ${analysisResult.concept?.central_thesis?.substring(0, 100)}...`);
          return analysisResult;
        } else {
          throw new Error('Claude Code response missing required analysis fields');
        }
      } catch (parseError) {
        console.error(`❌ Failed to parse Claude Code response as JSON:`, parseError.message);
        throw parseError;
      }
    } else {
      throw new Error('Claude Code execution failed or returned empty response');
    }
    
  } catch (error) {
    console.error(`❌ Claude Code intellectual architecture analysis error for ${title}:`, error.message);
    
    // Return basic error response for database consistency
    return {
      agent: 'enhanced_flowchart_mapper',
      generated_at: new Date().toISOString(),
      analysis_method: 'claude_code_error_fallback',
      research_mission: 'Islamic text intellectual architecture (error state)',
      
      concept: {
        central_thesis: `Error occurred during Claude Code analysis of ${title} by ${author}`,
        genre: 'islamic_scholarly_text',
        perspective: 'Islamic Scholarly Tradition',
        methodology: 'Claude Code CLI analysis failed'
      },
      
      flowchart_map: {
        primary_divisions: [
          {
            section: "Analysis Error",
            argumentative_purpose: "Claude Code CLI processing failed"
          }
        ],
        argumentative_strategy: "Error state - manual review required"
      },
      
      research_quality: {
        analysis_depth: 'error_state',
        confidence_level: 'failed',
        error_encountered: error.message
      }
    };
  }
}

























const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🗺️ Enhanced Flowchart Mapper (Intellectual Architecture Analyst) running on port ${PORT}`);
  console.log(`📚 Mission: Reverse-engineering the intellectual DNA of Islamic scholarship`);
  console.log(`🎯 Methodology: Argument as Structure + Inferential Specificity + Logical Dependency Analysis`);
  console.log(`🔬 Objective: Deconstructing scholarly arguments to reveal their intellectual architecture`);
});