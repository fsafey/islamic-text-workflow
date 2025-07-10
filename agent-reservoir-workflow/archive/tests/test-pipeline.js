const { createClient } = require('@supabase/supabase-js');

// Supabase client
const supabase = createClient(
  'https://aayvvcpxafzhcjqewwja.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ2Nzc1NCwiZXhwIjoyMDYyMDQzNzU0fQ.PHNLmAb0-jzy0CGl3ThVdgXZkAGTBWLxC5O-RDgp_yQ'
);

async function testPipeline() {
  console.log('🧪 Testing Agent Reservoir Pipeline...\n');
  
  try {
    // 1. Check if reservoir table exists and is ready
    console.log('1️⃣ Checking reservoir table...');
    const { data: reservoirTest, error: reservoirError } = await supabase
      .from('book_enrichment_reservoir')
      .select('count(*)')
      .limit(1);
    
    if (reservoirError) {
      console.log('❌ Reservoir table not found. Creating schema...');
      // You would need to run the create-reservoir-schema.sql first
      console.log('💡 Please run: psql < create-reservoir-schema.sql');
      return;
    }
    console.log('✅ Reservoir table ready\n');
    
    // 2. Initialize reservoir with sample books
    console.log('2️⃣ Initializing reservoir...');
    const response = await fetch('http://localhost:4000/initialize-reservoir', {
      method: 'POST'
    });
    
    if (response.ok) {
      const result = await response.json();
      console.log(`✅ ${result.message}`);
      console.log(`   📚 ${result.processed_count} books added to reservoir`);
      console.log(`   🏦 Total reservoir entries: ${result.reservoir_entries}\n`);
    } else {
      throw new Error(`Reservoir initialization failed: ${response.status}`);
    }
    
    // 3. Check agent health
    console.log('3️⃣ Checking agent health...');
    const healthResponse = await fetch('http://localhost:4000/agents-health');
    
    if (healthResponse.ok) {
      const health = await healthResponse.json();
      console.log(`🩺 Overall status: ${health.overall_status}`);
      
      for (const [agent, status] of Object.entries(health.agents)) {
        const icon = status.status === 'healthy' ? '✅' : '❌';
        console.log(`   ${icon} ${agent}: ${status.status}`);
      }
      console.log('');
    }
    
    // 4. Run assembly line
    console.log('4️⃣ Running assembly line...');
    const assemblyResponse = await fetch('http://localhost:4000/start-assembly', {
      method: 'POST'
    });
    
    if (assemblyResponse.ok) {
      const result = await assemblyResponse.json();
      console.log(`✅ Assembly line completed (Run #${result.run_number})`);
      console.log(`   🤖 Agents run: ${result.results.agents_run}`);
      console.log(`   📚 Books processed: ${result.results.books_processed}`);
      console.log(`   ❌ Errors: ${result.results.errors.length}\n`);
      
      // Show stage results
      if (result.results.stage_results) {
        console.log('📊 Stage Results:');
        for (const [stage, stageResult] of Object.entries(result.results.stage_results)) {
          if (stageResult.processed > 0) {
            console.log(`   ${stage}: ${stageResult.processed} books processed`);
          }
        }
        console.log('');
      }
    } else {
      throw new Error(`Assembly line failed: ${assemblyResponse.status}`);
    }
    
    // 5. Check reservoir status
    console.log('5️⃣ Checking final reservoir status...');
    const statusResponse = await fetch('http://localhost:4000/reservoir-status');
    
    if (statusResponse.ok) {
      const status = await statusResponse.json();
      console.log('📈 Reservoir Status:');
      for (const [stage, count] of Object.entries(status.reservoir_status)) {
        console.log(`   ${stage}: ${count} books`);
      }
      console.log(`   Total: ${status.total_books} books\n`);
    }
    
    console.log('🎉 Pipeline test completed successfully!');
    console.log('\n💡 Next steps:');
    console.log('   • Start continuous processing: POST http://localhost:4000/start-continuous');
    console.log('   • Monitor health: GET http://localhost:4000/agents-health');
    console.log('   • Check status: GET http://localhost:4000/reservoir-status');
    
  } catch (error) {
    console.error('❌ Pipeline test failed:', error.message);
    console.log('\n🔧 Troubleshooting:');
    console.log('   • Make sure all agents are running (ports 3001-3004)');
    console.log('   • Make sure orchestrator is running (port 4000)');
    console.log('   • Check database connection and schema');
  }
}

// Run the test
testPipeline();