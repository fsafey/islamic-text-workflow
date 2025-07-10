const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');
const TokenTracker = require('../lib/TokenTracker');
const ClaudeCodeExecutor = require('../lib/ClaudeCodeExecutor');

const app = express();
app.use(express.json());

// Initialize token tracking for this agent
const tokenTracker = new TokenTracker('network_mapper');

// Initialize Claude Code executor
const claudeExecutor = new ClaudeCodeExecutor('network_mapper', tokenTracker);

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
  const guidancePath = path.join(__dirname, '../../guidance/NETWORK_MAPPER_GUIDANCE.md');
  methodologyGuidance = fs.readFileSync(guidancePath, 'utf8');
  console.log('🕸️ Loaded conceptual network analysis methodology');
} catch (error) {
  console.error('⚠️ Could not load methodology guidance:', error.message);
}

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    agent: 'Enhanced Network Mapper - Conceptual Network Analyst',
    status: 'active',
    mission: 'Mapping the intellectual DNA of arguments - revealing how authors think and connect ideas',
    methodology: 'Conceptual Network Analysis: Central Node + Primary Concepts + Logical Relationships',
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

// Process next available book with conceptual network analysis
app.post('/process', async (req, res) => {
  try {
    console.log('🕸️ Conceptual Network Analyst: Mapping argumentative structures...');
    
    // Get books ready for conceptual network analysis
    const { data: booksReady, error: queryError } = await supabase
      .rpc('get_books_ready_for_agent', { agent_type: 'network' });
    
    if (queryError || !booksReady || booksReady.length === 0) {
      return res.json({ message: 'No books ready for conceptual network analysis', available: 0 });
    }
    
    console.log(`📚 Found ${booksReady.length} texts ready for conceptual network mapping`);
    
    const results = [];
    
    for (const book of booksReady) {
      try {
        console.log(`🗺️ Mapping conceptual network: "${book.title}" by ${book.author_name}`);
        console.log(`🎯 Mission: Transitioning from WHAT to HOW and WHY - revealing argumentative DNA`);
        
        const networkAnalysis = await analyzeConceptualNetwork(book.title, book.author_name);
        
        // Update reservoir with conceptual network findings
        const { error: updateError } = await supabase
          .from('book_enrichment_reservoir')
          .update({
            network_analysis: networkAnalysis,
            network_completed: true,
            network_completed_at: new Date().toISOString(),
            agents_completed: [...(book.agents_completed || []), 'network'],
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
          central_node: networkAnalysis.central_node?.concept || 'Complex conceptual analysis',
          primary_concepts: networkAnalysis.primary_concepts?.length || 0,
          network_density: networkAnalysis.network_analysis?.conceptual_density || 'moderate',
          ideological_stance: networkAnalysis.network_analysis?.ideological_stance || 'unknown',
          success: true
        });

        console.log(`✅ Conceptual network mapped: ${book.title}`);
        console.log(`🎯 Central Node: ${networkAnalysis.central_node?.concept}`);
        console.log(`🔗 Primary Concepts: ${networkAnalysis.primary_concepts?.length || 0}`);
        console.log(`🧠 Ideological Stance: ${networkAnalysis.network_analysis?.ideological_stance}`);
        
      } catch (error) {
        console.error(`❌ Network analysis failed for ${book.title}:`, error.message);
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
      agent: 'Enhanced Network Mapper - Conceptual Networks',
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

// Core conceptual network analysis function - UPGRADED TO CLAUDE CODE CLI
async function analyzeConceptualNetwork(title, author) {
  console.log(`🧠 Conducting conceptual network analysis with Claude Code: ${title} by ${author}`);
  
  try {
    // Define the system prompt for Islamic conceptual network analysis expertise
    const systemPrompt = `You are an expert Islamic conceptual network analyst specializing in argumentative DNA discovery and intellectual relationship mapping. Your expertise includes:

- Theological argument structure analysis across Islamic schools
- Sectarian perspective identification and intellectual lineage mapping
- Conceptual relationship discovery between Islamic ideas and scholars
- Ideological stance detection and comparative analysis frameworks
- Islamic philosophical polemic and refutation pattern recognition
- Knowledge discovery vs information retrieval methodologies

Your mission is to reveal HOW the author connects concepts and WHY they structure arguments.

Return structured JSON with these exact fields:
{
  "agent": "enhanced_network_mapper",
  "generated_at": "[ISO timestamp]",
  "analysis_method": "claude_code_conceptual_network_analysis",
  "research_mission": "Transitioning from information retrieval to knowledge discovery",
  
  "central_node": {
    "concept": "The book's core thesis or primary concept",
    "significance": "Why this concept is central to the author's project",
    "conceptual_weight": 1.0,
    "derivation_method": "Explanation of how this was identified"
  },
  
  "primary_concepts": [
    {
      "concept": "Main idea supporting the central thesis",
      "relationship_to_central": "How this concept relates to the central node",
      "significance": "Importance of this concept in the argument",
      "conceptual_weight": 0.8
    }
  ],
  
  "secondary_concepts": [
    {
      "concept": "Supporting context and evidence",
      "relationship_type": "Type of relationship to primary concepts",
      "connected_to": ["List of primary concepts this connects to"],
      "conceptual_weight": 0.3
    }
  ],
  
  "network_analysis": {
    "argumentative_strategy": "How concepts connect to build the argument",
    "ideological_stance": "Author's theological/sectarian perspective",
    "intellectual_tradition": "School/tradition affiliation",
    "polemical_targets": ["What the author argues against"],
    "conceptual_density": "high|moderate|low",
    "logical_coherence": "Assessment of argument structure"
  },
  
  "comparative_potential": {
    "similar_networks": ["Works with similar conceptual structures"],
    "contrasting_approaches": ["Alternative treatments of the topic"],
    "research_applications": ["How this work relates to similar texts"]
  },
  
  "network_synthesis": {
    "conceptual_framework": "Summary of the book's conceptual approach",
    "argumentative_approach": "How the author builds their case",
    "intellectual_tradition": "Scholarly tradition and school affiliation",
    "research_utility": "Value for comparative Islamic studies"
  }
}

Focus on argumentative DNA and conceptual relationships, not surface keywords.`;

    // Create the analysis prompt
    const analysisPrompt = `Conduct comprehensive conceptual network analysis for this Islamic text:

Title: ${title}
Author: ${author}

Please analyze:
1. The central organizing concept or thesis of the work
2. Primary concepts that support and develop the central thesis
3. Secondary concepts that provide context and evidence
4. The network structure and argumentative strategy
5. Comparative potential and research applications

Provide detailed analysis following Islamic scholarly traditions with particular attention to:
- Theological argument structures across Islamic schools (Sunni, Shia, Sufi)
- Sectarian perspectives and intellectual lineage mapping
- Conceptual relationships between Islamic ideas and scholars
- Ideological stance detection and comparative frameworks
- Argumentative DNA and how concepts connect to build arguments

Return comprehensive structured JSON analysis suitable for Islamic intellectual history research.`;

    // Execute Claude Code CLI with Islamic conceptual network expertise
    const claudeResponse = await claudeExecutor.executeClaudeCode(
      analysisPrompt,
      systemPrompt,
      { title, author_name: author }
    );

    // Parse and validate the response
    if (claudeResponse.success && claudeResponse.content) {
      try {
        // Try to parse as JSON if it's not already parsed
        const networkResult = typeof claudeResponse.content === 'string' 
          ? JSON.parse(claudeResponse.content)
          : claudeResponse.content;

        // Ensure required fields are present
        if (networkResult && networkResult.central_node && networkResult.network_analysis) {
          console.log(`✅ Claude Code conceptual network analysis completed: ${networkResult.central_node?.concept?.substring(0, 100)}...`);
          return networkResult;
        } else {
          throw new Error('Claude Code response missing required conceptual network analysis fields');
        }
      } catch (parseError) {
        console.error(`❌ Failed to parse Claude Code response as JSON:`, parseError.message);
        throw parseError;
      }
    } else {
      throw new Error('Claude Code execution failed or returned empty response');
    }
    
  } catch (error) {
    console.error(`❌ Claude Code conceptual network analysis error for ${title}:`, error.message);
    
    // Return basic error response for database consistency
    return {
      agent: 'enhanced_network_mapper',
      generated_at: new Date().toISOString(),
      analysis_method: 'claude_code_error_fallback',
      research_mission: 'Conceptual network analysis (error state)',
      
      central_node: {
        concept: inferCentralConcept(title, author),
        significance: 'Error occurred during Claude Code analysis',
        conceptual_weight: 1.0,
        derivation_method: 'claude_code_cli_error_fallback'
      },
      
      primary_concepts: [
        {
          concept: 'Scriptural Foundation',
          relationship_to_central: 'supports',
          significance: 'Error state - manual review required',
          conceptual_weight: 0.8
        }
      ],
      
      secondary_concepts: [],
      
      network_analysis: {
        argumentative_strategy: 'Error state - Claude Code CLI processing failed',
        ideological_stance: identifyIntellectualTradition(title, author, { concept: inferCentralConcept(title, author) }),
        intellectual_tradition: 'Error state - manual classification required',
        polemical_targets: [],
        conceptual_density: 'unknown',
        logical_coherence: 'failed'
      },
      
      comparative_potential: {
        similar_networks: [],
        contrasting_approaches: [],
        research_applications: []
      },
      
      network_synthesis: {
        conceptual_framework: `Error occurred during Claude Code analysis of ${title}`,
        argumentative_approach: 'Error state - manual review required',
        intellectual_tradition: 'Error state',
        research_utility: 'Error state - manual intervention needed'
      },
      
      error_encountered: error.message
    };
  }
}

// Step 1: Identify the central node (the book's primary organizing principle)
async function identifyCentralNode(title, author) {
  console.log(`🎯 Identifying central node for: ${title}`);
  
  // Analyze title and author to infer the central organizing principle
  const centralConcept = inferCentralConcept(title, author);
  const significance = analyzeCentralSignificance(title, author, centralConcept);
  
  return {
    concept: centralConcept,
    significance: significance,
    conceptual_weight: 1.0,
    derivation_method: 'inferential_analysis_from_title_author_context'
  };
}

// Step 2: Map primary concepts that build the argument around the central node
async function mapPrimaryConcepts(title, author, centralNode) {
  console.log(`🔗 Mapping primary concepts for: ${title}`);
  
  const primaryConcepts = [];
  const potentialConcepts = generatePotentialConcepts(title, author, centralNode.concept);
  
  // Select the most relevant 3-5 concepts that support the central thesis
  for (const concept of potentialConcepts.slice(0, 5)) {
    const relationship = inferRelationshipToCentral(concept, centralNode.concept);
    const significance = assessConceptSignificance(concept, centralNode.concept, title);
    
    primaryConcepts.push({
      concept: concept,
      relationship_to_central: relationship,
      significance: significance,
      conceptual_weight: calculateConceptualWeight(concept, centralNode.concept)
    });
  }
  
  return primaryConcepts;
}

// Step 3: Identify secondary concepts that provide context and support
async function identifySecondaryConcepts(title, author, centralNode, primaryConcepts) {
  console.log(`📚 Identifying secondary concepts for: ${title}`);
  
  const secondaryConcepts = [];
  const contextualConcepts = generateContextualConcepts(title, author, centralNode.concept);
  
  for (const concept of contextualConcepts.slice(0, 8)) {
    const relationshipType = inferRelationshipType(concept, primaryConcepts);
    const connectedConcepts = findConnectedConcepts(concept, primaryConcepts);
    
    secondaryConcepts.push({
      concept: concept,
      relationship_type: relationshipType,
      connected_to: connectedConcepts,
      conceptual_weight: 0.3
    });
  }
  
  return secondaryConcepts;
}

// Step 4: Analyze the overall network structure
async function analyzeNetworkStructure(title, author, centralNode, primaryConcepts, secondaryConcepts) {
  console.log(`🧠 Analyzing network structure for: ${title}`);
  
  const argumentativeStrategy = inferArgumentativeStrategy(centralNode, primaryConcepts);
  const ideologicalStance = revealIdeologicalStance(title, author, centralNode, primaryConcepts);
  const intellectualTradition = identifyIntellectualTradition(title, author, centralNode);
  const polemicalTargets = identifyPolemicalTargets(title, author, centralNode, primaryConcepts);
  const conceptualDensity = calculateConceptualDensity(primaryConcepts, secondaryConcepts);
  const logicalCoherence = assessLogicalCoherence(centralNode, primaryConcepts);
  
  return {
    argumentative_strategy: argumentativeStrategy,
    ideological_stance: ideologicalStance,
    intellectual_tradition: intellectualTradition,
    polemical_targets: polemicalTargets,
    conceptual_density: conceptualDensity,
    logical_coherence: logicalCoherence
  };
}

// Step 5: Assess comparative potential for research
async function assessComparativePotential(title, author, centralNode, networkAnalysis) {
  console.log(`🔍 Assessing comparative potential for: ${title}`);
  
  return {
    similar_networks: generateSimilarNetworkSuggestions(centralNode, networkAnalysis),
    contrasting_approaches: generateContrastingApproaches(centralNode, networkAnalysis),
    research_applications: generateResearchApplications(centralNode, networkAnalysis)
  };
}

// Central concept inference based on Islamic scholarly patterns
function inferCentralConcept(title, author) {
  // Shia-specific concepts
  if (title.match(/حسين|Husayn|Hussein/i) && title.match(/وارث|Warith|Inheritor/i)) {
    return 'Spiritual Inheritance (Warith)';
  }
  if (title.match(/أمان|Aman|Security/i) && title.match(/غيبة|Ghaybah|Occultation/i)) {
    return 'Seeking Security (Aman) during the Occultation';
  }
  if (title.match(/متحول|Mutahawil|Convert|Transform/i)) {
    return 'Religious Conversion (Tahawwul)';
  }
  if (title.match(/غدير|Ghadir/i)) {
    return 'Divine Succession and Guardianship (Wilayah)';
  }
  if (title.match(/ولاية|Wilayah|Guardianship/i)) {
    return 'Divine Authority and Spiritual Guardianship';
  }
  if (title.match(/إمامة|Imamate/i)) {
    return 'Divine Leadership through Appointed Imams';
  }
  if (title.match(/راجعة|Raj\'a|Return/i)) {
    return 'Eschatological Return and Divine Justice';
  }
  
  // Sunni-specific concepts
  if (title.match(/صحيح|Sahih/i) && title.match(/شرح|Sharh|Commentary/i)) {
    return 'Hadith Authentication and Legal Derivation';
  }
  if (title.match(/تفسير|Tafsir/i)) {
    return 'Quranic Interpretation and Divine Guidance';
  }
  if (title.match(/عقيدة|Aqidah|Creed/i)) {
    return 'Orthodox Belief System and Theological Doctrine';
  }
  if (title.match(/جهاد|Jihad/i)) {
    return 'Struggle in the Path of Allah';
  }
  if (title.match(/خلافة|Khilafah|Caliphate/i)) {
    return 'Legitimate Political and Religious Authority';
  }
  
  // Philosophical concepts
  if (title.match(/تهافت|Tahafut|Incoherence/i)) {
    return 'Critique of Philosophical Speculation';
  }
  if (title.match(/حكمة|Hikmah|Wisdom/i)) {
    return 'Divine Wisdom and Rational Understanding';
  }
  
  // Historical concepts
  if (title.match(/تاريخ|Tarikh|History/i)) {
    return 'Historical Development and Divine Providence';
  }
  if (title.match(/فتوح|Futuh|Conquests/i)) {
    return 'Islamic Expansion and Divine Mission';
  }
  
  // Literary concepts
  if (title.match(/ديوان|Diwan/i)) {
    return 'Poetic Expression of Islamic Ideals';
  }
  
  // Legal concepts
  if (title.match(/فقه|Fiqh/i)) {
    return 'Islamic Legal Framework and Divine Law';
  }
  if (title.match(/أصول|Usul/i)) {
    return 'Methodological Foundations of Islamic Law';
  }
  
  // Sufi concepts
  if (title.match(/طريقة|Tariqah|Path/i) || title.match(/صوفي|Sufi/i)) {
    return 'Spiritual Purification and Divine Proximity';
  }
  
  // Generic Islamic concepts
  if (title.match(/إسلام|Islam/i)) {
    return 'Islamic Way of Life and Divine Submission';
  }
  if (title.match(/قرآن|Quran/i)) {
    return 'Divine Revelation and Scriptural Authority';
  }
  
  // Fallback based on author tradition
  if (isShiaAuthor(author)) {
    return 'Divinely Guided Leadership and Community';
  }
  if (isSunniAuthor(author)) {
    return 'Prophetic Tradition and Community Consensus';
  }
  
  return 'Islamic Knowledge and Spiritual Guidance';
}

function analyzeCentralSignificance(title, author, centralConcept) {
  // Explain why this concept is central to the author's project
  if (centralConcept.includes('Spiritual Inheritance')) {
    return 'This concept bridges the Imam with the entire prophetic tradition, making his martyrdom a cosmic affirmation of divine succession rather than a historical tragedy';
  }
  if (centralConcept.includes('Security during Occultation')) {
    return 'This addresses the fundamental Shia dilemma of maintaining connection with divine guidance while the Imam is hidden, providing practical spiritual solutions';
  }
  if (centralConcept.includes('Religious Conversion')) {
    return 'This validates the intellectual and spiritual superiority of the destination creed by demonstrating the transformation process through reasoned conviction';
  }
  if (centralConcept.includes('Hadith Authentication')) {
    return 'This establishes the methodological foundation for deriving Islamic law and theology from Prophetic traditions, serving as the cornerstone of Sunni jurisprudence';
  }
  if (centralConcept.includes('Quranic Interpretation')) {
    return 'This provides the systematic framework for understanding divine revelation and applying its guidance to all aspects of Muslim life';
  }
  if (centralConcept.includes('Philosophical Speculation')) {
    return 'This defends the primacy of revelation over unaided reason in ultimate matters, reasserting orthodox Islamic epistemology against Hellenistic influence';
  }
  
  return `This concept serves as the organizing principle around which the author builds their Islamic scholarly argument and worldview`;
}

function generatePotentialConcepts(title, author, centralConcept) {
  const concepts = [];
  
  // Generate concepts based on central concept
  if (centralConcept.includes('Spiritual Inheritance')) {
    concepts.push(
      'Imam al-Husayn (The Inheritor)',
      'Prophet Adam (Origin of Legacy)',
      'Martyrdom (Shahada - Act of Affirmation)',
      'Prophetic Lineage Chain',
      'Divine Covenant Continuity'
    );
  } else if (centralConcept.includes('Security during Occultation')) {
    concepts.push(
      'The 12th Imam, Al-Mahdi (Source of Security)',
      'Major Occultation (Ghaybah - Context of Insecurity)',
      'Supplication (Du\'a) and Intercession (Tawassul)',
      'Spiritual Connection with Hidden Imam',
      'Eschatological Hope and Patience'
    );
  } else if (centralConcept.includes('Religious Conversion')) {
    concepts.push(
      'Original Sectarian Identity (Starting Point)',
      'Intellectual Proof (Daleel) and Conviction',
      'Personal Testimony and Narrative',
      'Transformed Religious Understanding',
      'Community and Family Impact'
    );
  } else if (centralConcept.includes('Hadith Authentication')) {
    concepts.push(
      'Isnad (Chain of Transmission) Analysis',
      'Narrator Reliability Assessment',
      'Textual Criticism and Variants',
      'Legal Derivation from Hadith',
      'Cross-Reference with Other Collections'
    );
  } else if (centralConcept.includes('Quranic Interpretation')) {
    concepts.push(
      'Linguistic and Grammatical Analysis',
      'Historical Context of Revelation',
      'Legal Implications and Rulings',
      'Theological Insights and Doctrine',
      'Practical Application for Muslims'
    );
  } else {
    // Generic Islamic concepts
    concepts.push(
      'Scriptural Foundation (Quran and Hadith)',
      'Theological Framework',
      'Legal and Ethical Implications',
      'Historical Context and Development',
      'Community Practice and Application'
    );
  }
  
  return concepts;
}

function generateContextualConcepts(title, author, centralConcept) {
  const concepts = [];
  
  // Add contextual concepts based on Islamic scholarly tradition
  if (isShiaContext(title, author, centralConcept)) {
    concepts.push(
      'Event of Karbala',
      'Imamate Doctrine',
      'Ahl al-Bayt Special Status',
      'Shia Eschatology',
      'Taqiyya (Protective Dissimulation)',
      'Marja\'iyyah (Religious Authority)',
      'Azadari (Mourning Rituals)',
      'Ziyarah (Pilgrimage to Shrines)'
    );
  } else if (isSunniContext(title, author, centralConcept)) {
    concepts.push(
      'Companions of the Prophet',
      'Four Rightly-Guided Caliphs',
      'Ijma (Scholarly Consensus)',
      'Qiyas (Analogical Reasoning)',
      'Madhab (School of Law)',
      'Ahl al-Sunnah wa al-Jama\'ah',
      'Bid\'ah (Innovation) Avoidance',
      'Sunnah Preservation'
    );
  } else {
    // Generic Islamic concepts
    concepts.push(
      'Tawhid (Divine Unity)',
      'Prophethood (Nubuwwah)',
      'Afterlife (Akhirah)',
      'Divine Justice (Adl)',
      'Islamic Community (Ummah)',
      'Spiritual Purification (Tazkiyah)',
      'Divine Mercy and Forgiveness',
      'Islamic Ethics (Akhlaq)'
    );
  }
  
  return concepts;
}

// Relationship analysis functions
function inferRelationshipToCentral(concept, centralConcept) {
  // Determine how the concept relates to the central node
  const relationshipTypes = {
    proves: 'used as evidence for',
    supports: 'reinforces and strengthens', 
    exemplifies: 'serves as specific example of',
    contextualizes: 'provides historical/theological context for',
    fulfills: 'represents the realization of',
    originates_from: 'derives its authority from'
  };
  
  // Logic for determining relationships
  if (concept.includes('Imam') && centralConcept.includes('Inheritance')) {
    return 'exemplifies';
  }
  if (concept.includes('Martyrdom') && centralConcept.includes('Inheritance')) {
    return 'proves';
  }
  if (concept.includes('Analysis') && centralConcept.includes('Authentication')) {
    return 'supports';
  }
  if (concept.includes('Context') || concept.includes('Historical')) {
    return 'contextualizes';
  }
  
  return 'supports';
}

function inferRelationshipType(concept, primaryConcepts) {
  // Determine how secondary concepts relate to primary ones
  if (concept.includes('Event') || concept.includes('Historical')) {
    return 'contextualizes';
  }
  if (concept.includes('Doctrine') || concept.includes('Framework')) {
    return 'supports';
  }
  if (concept.includes('Practice') || concept.includes('Application')) {
    return 'exemplifies';
  }
  
  return 'supports';
}

function findConnectedConcepts(concept, primaryConcepts) {
  // Find which primary concepts this secondary concept connects to
  const connections = [];
  
  for (const primary of primaryConcepts) {
    if (hasConceptualConnection(concept, primary.concept)) {
      connections.push(primary.concept);
    }
  }
  
  return connections.length > 0 ? connections : [primaryConcepts[0]?.concept || 'central_thesis'];
}

function hasConceptualConnection(secondaryConcept, primaryConcept) {
  // Determine if two concepts are logically connected
  const conceptWords = secondaryConcept.toLowerCase().split(' ');
  const primaryWords = primaryConcept.toLowerCase().split(' ');
  
  // Check for overlapping keywords
  return conceptWords.some(word => primaryWords.includes(word)) ||
         thematicallyRelated(secondaryConcept, primaryConcept);
}

function thematicallyRelated(concept1, concept2) {
  // Check for thematic relationships between concepts
  const shiaThemes = ['imam', 'husayn', 'karbala', 'occultation', 'mahdi'];
  const sunniThemes = ['hadith', 'companion', 'caliph', 'consensus'];
  const theologicalThemes = ['divine', 'revelation', 'prophecy', 'afterlife'];
  
  const isShia1 = shiaThemes.some(theme => concept1.toLowerCase().includes(theme));
  const isShia2 = shiaThemes.some(theme => concept2.toLowerCase().includes(theme));
  
  const isSunni1 = sunniThemes.some(theme => concept1.toLowerCase().includes(theme));
  const isSunni2 = sunniThemes.some(theme => concept2.toLowerCase().includes(theme));
  
  const isTheological1 = theologicalThemes.some(theme => concept1.toLowerCase().includes(theme));
  const isTheological2 = theologicalThemes.some(theme => concept2.toLowerCase().includes(theme));
  
  return (isShia1 && isShia2) || (isSunni1 && isSunni2) || (isTheological1 && isTheological2);
}

// Network analysis functions
function inferArgumentativeStrategy(centralNode, primaryConcepts) {
  if (centralNode.concept.includes('Inheritance') && primaryConcepts.some(c => c.concept.includes('Martyrdom'))) {
    return 'Historical Events as Theological Proof: Uses specific historical events to demonstrate cosmic spiritual principles';
  }
  if (centralNode.concept.includes('Authentication') && primaryConcepts.some(c => c.concept.includes('Analysis'))) {
    return 'Systematic Critical Methodology: Applies rigorous analytical techniques to establish textual reliability';
  }
  if (centralNode.concept.includes('Conversion') && primaryConcepts.some(c => c.concept.includes('Proof'))) {
    return 'Intellectual Conviction through Evidence: Demonstrates superiority through rational argumentation';
  }
  if (centralNode.concept.includes('Security') && primaryConcepts.some(c => c.concept.includes('Supplication'))) {
    return 'Spiritual Practice as Divine Connection: Provides practical methods for maintaining religious relationship';
  }
  
  return 'Systematic Integration of Evidence and Application';
}

function revealIdeologicalStance(title, author, centralNode, primaryConcepts) {
  if (isShiaContext(title, author, centralNode.concept)) {
    if (centralNode.concept.includes('Inheritance') || centralNode.concept.includes('Guardianship')) {
      return 'Shia Imami: Divine appointment and spiritual inheritance through Ahl al-Bayt';
    }
    return 'Shia Theological Framework: Emphasis on divinely guided leadership';
  }
  
  if (isSunniContext(title, author, centralNode.concept)) {
    if (centralNode.concept.includes('Authentication') || centralNode.concept.includes('Consensus')) {
      return 'Sunni Orthodox: Community consensus and textual preservation primacy';
    }
    return 'Sunni Theological Framework: Emphasis on prophetic tradition and community agreement';
  }
  
  if (centralNode.concept.includes('Philosophical') || centralNode.concept.includes('Critique')) {
    return 'Islamic Orthodox Response: Defending revelation primacy against philosophical speculation';
  }
  
  return 'Islamic Scholarly Tradition: Integration of textual sources with rational methodology';
}

function identifyIntellectualTradition(title, author, centralNode) {
  if (isShiaAuthor(author) || centralNode.concept.includes('Imamate') || centralNode.concept.includes('Husayn')) {
    return 'Shia Scholarly Tradition';
  }
  if (isSunniAuthor(author) || centralNode.concept.includes('Hadith') || centralNode.concept.includes('Consensus')) {
    return 'Sunni Scholarly Tradition';
  }
  if (centralNode.concept.includes('Philosophy') || centralNode.concept.includes('Wisdom')) {
    return 'Islamic Philosophical Tradition';
  }
  if (centralNode.concept.includes('Spiritual') || centralNode.concept.includes('Path')) {
    return 'Islamic Spiritual/Sufi Tradition';
  }
  
  return 'Classical Islamic Scholarship';
}

function identifyPolemicalTargets(title, author, centralNode, primaryConcepts) {
  const targets = [];
  
  if (isShiaContext(title, author, centralNode.concept)) {
    targets.push('Sunni Caliphate Legitimacy', 'Historical Succession Narrative');
    if (centralNode.concept.includes('Conversion')) {
      targets.push('Sunni Theological Arguments', 'Traditional Sectarian Boundaries');
    }
  }
  
  if (isSunniContext(title, author, centralNode.concept)) {
    if (centralNode.concept.includes('Authentication')) {
      targets.push('Hadith Skepticism', 'Legal Methodology Deviation');
    }
    if (title.match(/رد|Radd|Refutation/i)) {
      targets.push('Shia Claims', 'Deviant Interpretations');
    }
  }
  
  if (centralNode.concept.includes('Philosophical')) {
    targets.push('Hellenistic Philosophy', 'Rational Speculation', 'Metaphysical Claims');
  }
  
  return targets;
}

function calculateConceptualDensity(primaryConcepts, secondaryConcepts) {
  const totalConcepts = primaryConcepts.length + secondaryConcepts.length;
  
  if (totalConcepts >= 12) return 'high';
  if (totalConcepts >= 8) return 'moderate';
  return 'low';
}

function assessLogicalCoherence(centralNode, primaryConcepts) {
  // Assess how well the primary concepts support the central thesis
  const relevantConcepts = primaryConcepts.filter(concept => 
    concept.relationship_to_central === 'proves' || 
    concept.relationship_to_central === 'supports'
  );
  
  const coherenceRatio = relevantConcepts.length / primaryConcepts.length;
  
  if (coherenceRatio >= 0.8) return 'high';
  if (coherenceRatio >= 0.6) return 'moderate';
  return 'developing';
}

function calculateConceptualWeight(concept, centralConcept) {
  // Calculate the importance of this concept to the central argument
  if (concept.toLowerCase().includes(centralConcept.toLowerCase().split(' ')[0])) {
    return 0.9; // Directly related to central concept
  }
  if (concept.includes('Proof') || concept.includes('Evidence')) {
    return 0.8; // Critical supporting evidence
  }
  if (concept.includes('Analysis') || concept.includes('Method')) {
    return 0.7; // Methodological support
  }
  if (concept.includes('Context') || concept.includes('Historical')) {
    return 0.5; // Contextual support
  }
  
  return 0.6; // Default moderate weight
}

// Comparative analysis functions
function generateSimilarNetworkSuggestions(centralNode, networkAnalysis) {
  const suggestions = [];
  
  if (centralNode.concept.includes('Inheritance') || centralNode.concept.includes('Husayn')) {
    suggestions.push(
      'Other works on Imamate succession',
      'Books on prophetic lineage and spiritual inheritance',
      'Texts on Karbala significance and martyrdom'
    );
  }
  
  if (centralNode.concept.includes('Authentication') || centralNode.concept.includes('Hadith')) {
    suggestions.push(
      'Other hadith commentary works',
      'Books on Islamic legal methodology',
      'Texts on narrator criticism and chain analysis'
    );
  }
  
  if (centralNode.concept.includes('Security') || centralNode.concept.includes('Occultation')) {
    suggestions.push(
      'Works on Shia eschatology and Mahdi',
      'Books on spiritual practices during waiting',
      'Texts on divine guidance in absence'
    );
  }
  
  return suggestions;
}

function generateContrastingApproaches(centralNode, networkAnalysis) {
  const contrasts = [];
  
  if (networkAnalysis.intellectual_tradition.includes('Shia')) {
    contrasts.push(
      'Sunni treatments of succession and authority',
      'Historical narratives from orthodox perspective',
      'Community-based vs. appointment-based leadership models'
    );
  }
  
  if (networkAnalysis.intellectual_tradition.includes('Sunni')) {
    contrasts.push(
      'Shia alternative interpretations',
      'Rationalist vs. traditionalist approaches',
      'Individual vs. community authority models'
    );
  }
  
  if (centralNode.concept.includes('Philosophical')) {
    contrasts.push(
      'Pro-philosophy integration works',
      'Mystical vs. rational approaches',
      'Revelation-reason synthesis attempts'
    );
  }
  
  return contrasts;
}

function generateResearchApplications(centralNode, networkAnalysis) {
  const applications = [];
  
  applications.push(
    'Comparative sectarian theology analysis',
    'Historical development of Islamic thought',
    'Methodological approaches in Islamic scholarship'
  );
  
  if (centralNode.concept.includes('Authority') || centralNode.concept.includes('Leadership')) {
    applications.push(
      'Political theology in Islamic thought',
      'Legitimacy theories in Islamic history',
      'Authority structures across Islamic traditions'
    );
  }
  
  if (networkAnalysis.argumentative_strategy.includes('Evidence')) {
    applications.push(
      'Epistemology in Islamic scholarship',
      'Evidence evaluation methodologies',
      'Rationality and revelation in Islamic thought'
    );
  }
  
  return applications;
}

// Utility functions for context identification
function isShiaContext(title, author, centralConcept) {
  return title.match(/شيعي|Shia|حسين|Husayn|ولاية|Wilayah|إمامة|Imamate|غدير|Ghadir/i) ||
         isShiaAuthor(author) ||
         centralConcept.includes('Inheritance') ||
         centralConcept.includes('Guardianship') ||
         centralConcept.includes('Occultation');
}

function isSunniContext(title, author, centralConcept) {
  return title.match(/سني|Sunni|صحيح|Sahih|خلافة|Khilafah|إجماع|Ijma/i) ||
         isSunniAuthor(author) ||
         centralConcept.includes('Authentication') ||
         centralConcept.includes('Consensus') ||
         centralConcept.includes('Caliphate');
}

function isShiaAuthor(author) {
  const shiaAuthors = ['طوسي', 'مجلسي', 'طبطبائي', 'خوئي', 'سيستاني', 'خامنئي'];
  return shiaAuthors.some(shiaName => author && author.includes(shiaName));
}

function isSunniAuthor(author) {
  const sunniAuthors = ['بخاري', 'مسلم', 'طبري', 'ابن كثير', 'نووي', 'ابن حجر', 'غزالي'];
  return sunniAuthors.some(sunniName => author && author.includes(sunniName));
}

// Fallback analysis when detailed analysis fails
async function generateConceptualFallbackAnalysis(title, author, errorMessage) {
  return {
    agent: 'enhanced_network_mapper',
    generated_at: new Date().toISOString(),
    analysis_method: 'conceptual_fallback_analysis',
    research_mission: 'Basic conceptual network mapping (fallback mode)',
    
    central_node: {
      concept: inferCentralConcept(title, author),
      significance: 'Primary organizing principle of the work',
      conceptual_weight: 1.0
    },
    
    primary_concepts: [
      {
        concept: 'Scriptural Foundation',
        relationship_to_central: 'supports',
        significance: 'Provides religious authority base',
        conceptual_weight: 0.8
      },
      {
        concept: 'Theological Framework',
        relationship_to_central: 'contextualizes',
        significance: 'Situates argument within Islamic doctrine',
        conceptual_weight: 0.7
      },
      {
        concept: 'Practical Application',
        relationship_to_central: 'exemplifies',
        significance: 'Shows real-world implementation',
        conceptual_weight: 0.6
      }
    ],
    
    network_analysis: {
      argumentative_strategy: 'Traditional Islamic methodology with scriptural and rational integration',
      ideological_stance: identifyIntellectualTradition(title, author, { concept: inferCentralConcept(title, author) }),
      intellectual_tradition: 'Classical Islamic Scholarship',
      conceptual_density: 'moderate',
      logical_coherence: 'developing'
    },
    
    research_quality: {
      analysis_depth: 'basic_conceptual_mapping',
      confidence_level: 'preliminary',
      fallback_used: true,
      error_encountered: errorMessage
    }
  };
}

const PORT = 3002;
app.listen(PORT, () => {
  console.log(`🕸️ Enhanced Network Mapper (Conceptual Network Analyst) running on port ${PORT}`);
  console.log(`🧠 Mission: Mapping the intellectual DNA of arguments - revealing how authors think`);
  console.log(`🎯 Methodology: Central Node + Primary Concepts + Logical Relationships + Ideological Analysis`);
  console.log(`🔬 Objective: Transitioning from WHAT to HOW and WHY in Islamic scholarship`);
});