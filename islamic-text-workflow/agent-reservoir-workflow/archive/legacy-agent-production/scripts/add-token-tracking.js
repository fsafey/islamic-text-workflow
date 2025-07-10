/**
 * Script to add token tracking to all agents
 * Adds TokenTracker imports and endpoints to agent files
 */

const fs = require('fs');
const path = require('path');

const agentsDir = path.join(__dirname, '../agents');
const agentFiles = [
  'enhanced-flowchart-mapper-agent.js',
  'enhanced-network-mapper-agent.js',
  'data-pipeline-agent.js'
];

function addTokenTrackingToAgent(filePath, agentName) {
  console.log(`Adding token tracking to ${filePath}...`);
  
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Add TokenTracker import if not already present
  if (!content.includes('TokenTracker')) {
    content = content.replace(
      /const express = require\('express'\);[\s\S]*?const app = express\(\);[\s\S]*?app\.use\(express\.json\(\)\);/,
      `const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');
const TokenTracker = require('../lib/TokenTracker');

const app = express();
app.use(express.json());

// Initialize token tracking for this agent
const tokenTracker = new TokenTracker('${agentName}');`
    );
  }
  
  // Add token endpoints before the first app.post if not already present
  if (!content.includes('/agent-tokens')) {
    const healthCheckEnd = content.indexOf('});', content.indexOf('app.get(\'/health\''));
    if (healthCheckEnd !== -1) {
      const insertPoint = healthCheckEnd + 3; // After the closing });
      
      const tokenEndpoints = `

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
});`;
      
      content = content.slice(0, insertPoint) + tokenEndpoints + content.slice(insertPoint);
    }
  }
  
  fs.writeFileSync(filePath, content);
  console.log(`✅ Token tracking added to ${path.basename(filePath)}`);
}

// Process each agent file
agentFiles.forEach(fileName => {
  const filePath = path.join(agentsDir, fileName);
  
  if (fs.existsSync(filePath)) {
    // Extract agent name from filename
    const agentName = fileName.replace('.js', '').replace('enhanced-', '').replace('-agent', '').replace(/-/g, '_');
    addTokenTrackingToAgent(filePath, agentName);
  } else {
    console.warn(`⚠️ Agent file not found: ${filePath}`);
  }
});

console.log('🎯 Token tracking setup complete for all agents');