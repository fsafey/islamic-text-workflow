#!/usr/bin/env node

// Test Script for Streamlined 25-Field Implementation
// Validates agent responses match expected field structure

const testAnalysisRequest = {
  book_id: "test-uuid-123",
  title: "Test Islamic Book",
  author: "Test Author"
};

const testEnrichmentRequest = {
  book_id: "test-uuid-123",
  analysis_data: {
    central_node: "Test analysis",
    genre_classification: "Islamic scholarship",
    methodological_foundation: "Traditional sources",
    scholarly_perspective: "Classical tradition",
    network_description: "Test network description"
  },
  original_book: {
    title: "Test Islamic Book",
    author_name: "Test Author"
  }
};

// Expected response structures
const expectedAnalysisFields = [
  'central_node',
  'genre_classification', 
  'methodological_foundation',
  'scholarly_perspective',
  'network_description',
  'analysis_quality_score',
  'quality_gate_passed',
  'ready_for_stage2'
];

const expectedEnrichmentFields = [
  'final_title_alias',
  'transliteration_variations_count',
  'final_keywords',
  'core_concepts_count',
  'contextual_associations_count',
  'final_description',
  'description_word_count',
  'academic_tone_maintained',
  'enrichment_quality_score',
  'sql_executed',
  'execution_successful',
  'methodology_compliance_gate_passed',
  'execution_timestamp',
  'rows_affected',
  'execution_error',
  'books_updated_at',
  'overall_quality_gate_passed'
];

async function testEndpoint(endpoint, data, expectedFields) {
  try {
    console.log(`\n🧪 Testing ${endpoint}...`);
    
    const response = await fetch(`http://localhost:3002${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    
    if (!response.ok) {
      console.log(`❌ HTTP ${response.status}: ${response.statusText}`);
      return false;
    }
    
    const result = await response.json();
    const resultFields = Object.keys(result);
    
    console.log(`📊 Received ${resultFields.length} fields:`, resultFields);
    console.log(`🎯 Expected ${expectedFields.length} fields:`, expectedFields);
    
    // Check if all expected fields are present
    const missingFields = expectedFields.filter(field => !resultFields.includes(field));
    const extraFields = resultFields.filter(field => !expectedFields.includes(field));
    
    if (missingFields.length === 0 && extraFields.length === 0) {
      console.log(`✅ Perfect match! ${expectedFields.length} fields as expected`);
      return true;
    } else {
      if (missingFields.length > 0) {
        console.log(`❌ Missing fields:`, missingFields);
      }
      if (extraFields.length > 0) {
        console.log(`⚠️ Extra fields:`, extraFields);
      }
      return false;
    }
    
  } catch (error) {
    console.error(`❌ Test failed:`, error.message);
    return false;
  }
}

async function runTests() {
  console.log('🚀 Starting Streamlined Field Structure Tests');
  console.log('═'.repeat(60));
  
  // Test health endpoint first
  try {
    const healthResponse = await fetch('http://localhost:3002/health');
    if (healthResponse.ok) {
      console.log('✅ Agent server is running');
    } else {
      console.log('❌ Agent server not responding');
      return;
    }
  } catch (error) {
    console.log('❌ Agent server not accessible. Start with: node claude-desktop-agent.js');
    return;
  }
  
  // Test both endpoints
  const analysisResult = await testEndpoint('/claude/hybrid-analysis', testAnalysisRequest, expectedAnalysisFields);
  const enrichmentResult = await testEndpoint('/claude/enrichment-execution', testEnrichmentRequest, expectedEnrichmentFields);
  
  console.log('\n📋 Test Summary:');
  console.log('═'.repeat(40));
  console.log(`Analysis Endpoint: ${analysisResult ? '✅ PASS' : '❌ FAIL'} (8 fields)`);
  console.log(`Enrichment Endpoint: ${enrichmentResult ? '✅ PASS' : '❌ FAIL'} (17 fields)`);
  console.log(`Total Expected Fields: 25 (down from 155 - 83% reduction)`);
  
  if (analysisResult && enrichmentResult) {
    console.log('\n🎉 All tests passed! Agent ready for Make.com production use.');
  } else {
    console.log('\n⚠️ Some tests failed. Check agent implementation.');
  }
}

// Run tests if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  runTests().catch(console.error);
}

export { runTests };