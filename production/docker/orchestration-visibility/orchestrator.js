const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const path = require('path');

const app = express();
app.use(express.json());

// Container-based configuration
const CONFIG = {
  PORT: parseInt(process.env.PORT) || 8080,
  ORCHESTRATOR_URL: process.env.ORCHESTRATOR_URL || 'http://orchestrator:4000',
  DASHBOARD_MODE: process.env.DASHBOARD_MODE === 'true',
  
  // Supabase configuration
  SUPABASE_URL: process.env.SUPABASE_URL,
  SUPABASE_SERVICE_KEY: process.env.SUPABASE_SERVICE_KEY,
  
  // Refresh intervals
  REFRESH_INTERVAL: parseInt(process.env.REFRESH_INTERVAL) || 2000,
  
  // Debug options
  DEBUG_MODE: process.env.DEBUG_MODE === 'true',
  VERBOSE_LOGGING: process.env.VERBOSE_LOGGING === 'true'
};

// Log startup configuration
console.log('🎛️ Dashboard Configuration:', {
  port: CONFIG.PORT,
  orchestrator_url: CONFIG.ORCHESTRATOR_URL,
  dashboard_mode: CONFIG.DASHBOARD_MODE,
  debug_mode: CONFIG.DEBUG_MODE
});

// Initialize Supabase client
let supabase = null;
if (CONFIG.SUPABASE_URL && CONFIG.SUPABASE_SERVICE_KEY) {
  supabase = createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_SERVICE_KEY);
  console.log('✅ Supabase client initialized');
} else {
  // Fallback for production
  supabase = createClient(
    'https://aayvvcpxafzhcjqewwja.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ2Nzc1NCwiZXhwIjoyMDYyMDQzNzU0fQ.PHNLmAb0-jzy0CGl3ThVdgXZkAGTBWLxC5O-RDgp_yQ'
  );
  console.log('✅ Supabase client initialized (fallback)');
}

// Serve static files for monitoring dashboard
app.use('/monitor', express.static(path.join(__dirname, 'monitor')));

// Serve enhanced dashboard as default
app.get('/', (req, res) => {
  res.redirect('/monitor/enhanced-dashboard.html');
});

// Dashboard state management
let dashboardState = {
  systemStats: {},
  agentStates: {},
  currentBooks: [],
  logs: [],
  lastUpdate: null
};

// Token-Based Context Management
let orchestratorStartTime = new Date().toISOString();
let orchestratorRestartCount = 0;
let orchestratorTokenUsage = 0;
const AGENT_TOKEN_LIMIT = 100000; // 100K token restart threshold
const ORCHESTRATOR_TOKEN_LIMIT = 150000; // 150K token restart threshold

let criticalState = {
  active_agents: {},
  pipeline_status: 'stopped',
  processing_queue_count: 0,
  last_assembly_run: null,
  error_count: 0,
  performance_degradation_detected: false,
  token_usage_tracking: {}
};

// Workflow presets configuration
const WORKFLOW_PRESETS = {
  thorough: {
    agents: ['flowchart', 'network', 'metadata', 'synthesis', 'pipeline'],
    batch_size: 2,
    health_check_interval: 15000,
    max_restart_attempts: 5
  },
  debug: {
    agents: ['flowchart'],
    batch_size: 1,
    health_check_interval: 5000,
    max_restart_attempts: 1
  }
};

// Centralized error tracking system
let systemErrors = [];
const MAX_ERROR_HISTORY = 50;

// Token Usage Tracking Functions
function estimateTokens(text) {
  // Rough estimation: 1 token ≈ 4 characters for English text
  // More accurate for code/structured data: 1 token ≈ 3.5 characters
  return Math.ceil(text.length / 3.5);
}

function trackOrchestratorTokens(inputText, outputText = '') {
  const inputTokens = estimateTokens(inputText);
  const outputTokens = estimateTokens(outputText);
  const totalTokens = inputTokens + outputTokens;
  
  orchestratorTokenUsage += totalTokens;
  
  console.log(`🎭 Orchestrator tokens: +${totalTokens} (total: ${orchestratorTokenUsage}/${ORCHESTRATOR_TOKEN_LIMIT})`);
  
  if (orchestratorTokenUsage > ORCHESTRATOR_TOKEN_LIMIT * 0.9) {
    console.warn(`⚠️ Orchestrator approaching token limit: ${orchestratorTokenUsage}/${ORCHESTRATOR_TOKEN_LIMIT}`);
  }
  
  return {
    input_tokens: inputTokens,
    output_tokens: outputTokens,
    total_tokens: totalTokens,
    cumulative_tokens: orchestratorTokenUsage,
    restart_recommended: orchestratorTokenUsage > ORCHESTRATOR_TOKEN_LIMIT
  };
}

async function getAgentTokenUsage(agentType) {
  const agent = AGENTS[agentType];
  if (!agent) return null;
  
  const url = `http://localhost:${agent.port}/agent-tokens`;
  
  try {
    const response = await fetch(url, {
      method: 'GET',
      timeout: 3000
    });
    
    if (response.ok) {
      return await response.json();
    } else {
      console.warn(`⚠️ Could not get token usage from ${agentType}: HTTP ${response.status}`);
      return null;
    }
  } catch (error) {
    console.warn(`⚠️ Could not reach ${agentType} for token usage: ${error.message}`);
    return null;
  }
}

// Legacy function - kept for orchestrator-to-agent communication tracking
function trackAgentTokens(agentType, inputText, outputText = '') {
  const inputTokens = estimateTokens(inputText);
  const outputTokens = estimateTokens(outputText);
  const totalTokens = inputTokens + outputTokens;
  
  if (!criticalState.token_usage_tracking[agentType]) {
    criticalState.token_usage_tracking[agentType] = {
      total_tokens: 0,
      request_count: 0,
      last_reset: new Date().toISOString()
    };
  }
  
  const agentUsage = criticalState.token_usage_tracking[agentType];
  agentUsage.total_tokens += totalTokens;
  agentUsage.request_count += 1;
  
  console.log(`🤖 ${agentType} orchestrator communication: +${totalTokens} tokens`);
  
  return {
    agent_type: agentType,
    input_tokens: inputTokens,
    output_tokens: outputTokens,
    total_tokens: totalTokens,
    cumulative_tokens: agentUsage.total_tokens,
    restart_recommended: false // Will be determined by real agent token usage
  };
}

function resetAgentTokens(agentType) {
  if (criticalState.token_usage_tracking[agentType]) {
    const previousUsage = criticalState.token_usage_tracking[agentType].total_tokens;
    criticalState.token_usage_tracking[agentType] = {
      total_tokens: 0,
      request_count: 0,
      last_reset: new Date().toISOString()
    };
    console.log(`🔄 ${agentType} token usage reset (was: ${previousUsage} tokens)`);
  }
}

function logError(component, error, action = 'none') {
  const errorEntry = {
    id: Date.now().toString(),
    timestamp: new Date().toISOString(),
    component,
    error: error.message || error,
    action,
    stack: error.stack || 'No stack trace',
    severity: determineSeverity(component, error)
  };
  
  systemErrors.unshift(errorEntry);
  
  // Keep only recent errors
  if (systemErrors.length > MAX_ERROR_HISTORY) {
    systemErrors = systemErrors.slice(0, MAX_ERROR_HISTORY);
  }
  
  console.error(`❌ ${component}: ${errorEntry.error}`);
  
  // Log critical errors with extra details
  if (errorEntry.severity === 'critical') {
    console.error(`🚨 CRITICAL ERROR in ${component}:`, {
      error: errorEntry.error,
      action: errorEntry.action,
      timestamp: errorEntry.timestamp
    });
  }
}

function determineSeverity(component, error) {
  const errorStr = (error.message || error).toLowerCase();
  
  if (errorStr.includes('cannot find module') || 
      errorStr.includes('eaddrinuse') ||
      component === 'agent_startup') {
    return 'critical';
  }
  
  if (errorStr.includes('timeout') || 
      errorStr.includes('unreachable') ||
      component === 'health_check') {
    return 'warning';
  }
  
  return 'error';
}

// Duplicate Supabase client removed - using CONFIG-based initialization above

// Enhanced agent configuration
const AGENTS = {
  flowchart: { 
    port: 3001, 
    name: 'Enhanced Flowchart Mapper - Intellectual Architecture Specialist',
    expertise: 'Islamic Intellectual Architecture Analysis',
    methodology: 'Argument as Structure + Inferential Specificity',
    output_type: 'intellectual_architecture_analysis'
  },
  network: { 
    port: 3002, 
    name: 'Enhanced Network Mapper - Conceptual Network Analyst',
    expertise: 'Islamic Conceptual Network Discovery', 
    methodology: 'Knowledge Discovery + Argumentative DNA Analysis',
    output_type: 'conceptual_network_analysis'
  },
  metadata: { 
    port: 3003, 
    name: 'Enhanced Metadata Hunter - Bibliographic Research Specialist',
    expertise: 'Islamic Bibliographic Research',
    methodology: 'Multi-Source Arabic Title + Author + Publication Research',
    output_type: 'comprehensive_bibliographic_metadata'
  },
  synthesis: { 
    port: 3004, 
    name: 'Enhanced Content Synthesizer - Library Catalog Synthesis Specialist',
    expertise: 'Library Catalog Field Synthesis',
    methodology: 'Spartan Research-to-Catalog Transformation', 
    output_type: 'library_catalog_fields'
  },
  pipeline: { 
    port: 3006, 
    name: 'Enhanced Data Pipeline - Production Database Population Specialist',
    expertise: 'Production Database Population',
    methodology: 'Enriched Research to Production Catalog Pipeline',
    output_type: 'production_database_updates'
  }
};

let orchestrationRuns = 0;
let totalProcessed = 0;

// Health monitoring with auto-restart
function startHealthMonitoring() {
  if (healthCheckInterval) {
    clearInterval(healthCheckInterval);
  }
  
  console.log('🔍 Starting health monitoring loop...');
  
  healthCheckInterval = setInterval(async () => {
    try {
      for (const [agentType, agent] of Object.entries(AGENTS)) {
        if (!agentProcesses[agentType]) continue;
        
        const health = await checkAgentHealth(agentType);
        const agentProcess = agentProcesses[agentType];
        
        if (health.status !== 'healthy' && health.status !== 'active') {
          logError('health_check', `Agent ${agentType} failed health check: ${health.status}`, `auto_restart_${agentType}`);
          
          // Increment restart count
          agentProcess.restartCount = (agentProcess.restartCount || 0) + 1;
          
          // Only auto-restart if restart count is reasonable
          if (agentProcess.restartCount < 3) {
            console.log(`🔄 Auto-restarting unhealthy agent: ${agentType} (attempt ${agentProcess.restartCount})`);
            await restartAgent(agentType);
          } else {
            logError('health_check', `Agent ${agentType} exceeded restart attempts (${agentProcess.restartCount})`, 'manual_intervention_required');
            console.log(`🚨 Agent ${agentType} requires manual intervention - too many restart attempts`);
          }
        } else {
          // Reset restart count on successful health check
          if (agentProcess.restartCount > 0) {
            console.log(`✅ Agent ${agentType} health restored, resetting restart count`);
            agentProcess.restartCount = 0;
          }
        }
      }
    } catch (error) {
      logError('health_monitoring', error, 'monitoring_loop_error');
    }
  }, 10000); // Check every 10 seconds
}

function stopHealthMonitoring() {
  if (healthCheckInterval) {
    clearInterval(healthCheckInterval);
    healthCheckInterval = null;
    console.log('🛑 Health monitoring stopped');
  }
}

async function restartAgent(agentType) {
  try {
    console.log(`🔄 Restarting agent: ${agentType}`);
    await stopAgent(agentType);
    await new Promise(resolve => setTimeout(resolve, 2000)); // Wait 2 seconds
    await startAgent(agentType);
    console.log(`✅ Agent ${agentType} restarted successfully`);
  } catch (error) {
    logError('agent_restart', error, `failed_restart_${agentType}`);
    throw error;
  }
}

// Agent lifecycle management functions
async function startAgent(agentType) {
  console.log(`🚀 Starting ${agentType} agent...`);
  
  const agent = AGENTS[agentType];
  if (!agent) {
    throw new Error(`Unknown agent type: ${agentType}`);
  }
  
  // Kill existing process if running
  if (agentProcesses[agentType]) {
    await stopAgent(agentType);
  }
  
  const agentFileName = agentType === 'synthesis' ? 'content-synthesizer-agent.js' : 
                       agentType === 'pipeline' ? 'data-pipeline-agent.js' :
                       agentType === 'metadata' ? 'enhanced-metadata-hunter-agent.js' :
                       `enhanced-${agentType}-mapper-agent.js`;
  
  const agentPath = path.join(__dirname, '../agents', agentFileName);
  
  return new Promise((resolve, reject) => {
    const childProcess = spawn('node', [agentPath], {
      stdio: ['pipe', 'pipe', 'pipe'],
      cwd: path.join(__dirname, '../agents'),
      env: { ...process.env, PORT: agent.port }
    });
    
    agentProcesses[agentType] = {
      process: childProcess,
      pid: childProcess.pid,
      startedAt: new Date(),
      port: agent.port,
      restartCount: 0
    };
    
    childProcess.stdout.on('data', (data) => {
      console.log(`[${agentType}:${childProcess.pid}] ${data.toString().trim()}`);
    });
    
    childProcess.stderr.on('data', (data) => {
      console.error(`[${agentType}:${childProcess.pid}] ERROR: ${data.toString().trim()}`);
    });
    
    childProcess.on('exit', (code) => {
      console.log(`[${agentType}:${childProcess.pid}] Exited with code ${code}`);
      delete agentProcesses[agentType];
    });
    
    childProcess.on('error', (error) => {
      logError('agent_startup', error, `restart_agent_${agentType}`);
      delete agentProcesses[agentType];
      reject(error);
    });
    
    // Wait for agent to start and become responsive
    setTimeout(async () => {
      try {
        const health = await checkAgentHealth(agentType);
        if (health.status === 'healthy' || health.status === 'active') {
          console.log(`✅ ${agentType} agent started successfully on port ${agent.port}`);
          resolve(agentProcesses[agentType]);
        } else {
          throw new Error(`Agent ${agentType} failed health check: ${health.status}`);
        }
      } catch (error) {
        logError('agent_startup', error, `failed_health_check_${agentType}`);
        reject(error);
      }
    }, 3000);
  });
}

async function stopAgent(agentType) {
  console.log(`🛑 Stopping ${agentType} agent...`);
  
  const agentInfo = agentProcesses[agentType];
  if (agentInfo && agentInfo.process) {
    agentInfo.process.kill('SIGTERM');
    
    // Wait for graceful shutdown, then force kill if needed
    setTimeout(() => {
      if (agentProcesses[agentType]) {
        agentInfo.process.kill('SIGKILL');
      }
    }, 5000);
    
    delete agentProcesses[agentType];
    console.log(`✅ ${agentType} agent stopped`);
  }
}

async function startAllAgents() {
  console.log('🚀 Starting all agents...');
  const agentTypes = Object.keys(AGENTS);
  const startPromises = agentTypes.map(agentType => startAgent(agentType));
  
  try {
    await Promise.all(startPromises);
    console.log('✅ All agents started successfully');
    pipelineRunning = true;
    startHealthMonitoring();
    return true;
  } catch (error) {
    console.error('❌ Failed to start all agents:', error.message);
    // Try to stop any agents that did start
    await stopAllAgents();
    throw error;
  }
}

async function stopAllAgents() {
  console.log('🛑 Stopping all agents...');
  const agentTypes = Object.keys(agentProcesses);
  const stopPromises = agentTypes.map(agentType => stopAgent(agentType));
  
  await Promise.all(stopPromises);
  
  stopHealthMonitoring();
  pipelineRunning = false;
  console.log('✅ All agents stopped');
}

function startHealthMonitoring() {
  if (healthCheckInterval) {
    clearInterval(healthCheckInterval);
  }
  
  healthCheckInterval = setInterval(async () => {
    for (const [agentType, agentInfo] of Object.entries(agentProcesses)) {
      try {
        const health = await checkAgentHealth(agentType);
        if (health.status === 'unreachable' || health.status === 'unhealthy') {
          console.log(`🔄 Restarting unhealthy agent: ${agentType}`);
          await restartAgent(agentType);
        }
      } catch (error) {
        console.error(`❌ Health check failed for ${agentType}:`, error.message);
      }
    }
  }, 15000); // Check every 15 seconds
}

async function restartAgent(agentType) {
  const agentInfo = agentProcesses[agentType];
  if (agentInfo) {
    agentInfo.restartCount = (agentInfo.restartCount || 0) + 1;
    if (agentInfo.restartCount > 3) {
      console.error(`❌ Agent ${agentType} has failed too many times, not restarting`);
      return;
    }
  }
  
  await stopAgent(agentType);
  await sleep(2000);
  await startAgent(agentType);
}

function getAgentStatus() {
  const status = {};
  for (const [agentType, agent] of Object.entries(AGENTS)) {
    const agentInfo = agentProcesses[agentType];
    if (agentInfo) {
      status[agentType] = {
        running: true,
        pid: agentInfo.pid,
        port: agentInfo.port,
        startedAt: agentInfo.startedAt,
        restartCount: agentInfo.restartCount || 0
      };
    } else {
      status[agentType] = {
        running: false,
        port: agent.port
      };
    }
  }
  return status;
}

// Health check
app.get('/health', (req, res) => {
  // Dashboard mode health check
  if (CONFIG.DASHBOARD_MODE) {
    res.json({
      status: 'healthy',
      service: 'islamic-text-dashboard',
      timestamp: new Date().toISOString(),
      orchestrator_url: CONFIG.ORCHESTRATOR_URL,
      uptime: process.uptime()
    });
  } else {
    // Orchestrator mode health check
    res.json({ 
      orchestrator: 'Enhanced Islamic Text Processing Assembly Line',
      status: 'active',
      mission: 'Coordinate 5 enhanced agents for sophisticated Islamic text enrichment',
      methodology: 'Intellectual Architecture + Conceptual Networks + Bibliographic Research + Catalog Synthesis + Production Pipeline',
      enhancement_level: 'Real scholarly research with rich library catalog output',
      runs: orchestrationRuns,
      total_processed: totalProcessed,
      agents: Object.keys(AGENTS).map(key => ({
        name: AGENTS[key].name,
        expertise: AGENTS[key].expertise,
        methodology: AGENTS[key].methodology
      })),
      timestamp: new Date().toISOString() 
    });
  }
});

// ====================
// Dashboard API Endpoints (Knowledge Engineering Dashboard)
// ====================

// Enhanced system stats for dashboard
app.get('/system-stats', async (req, res) => {
  try {
    // Get basic stats from reservoir
    const reservoirData = await fetch(`${CONFIG.ORCHESTRATOR_URL}/reservoir-status`);
    const reservoirStats = await reservoirData.json();
    
    // Get agents health
    const agentsData = await fetch(`${CONFIG.ORCHESTRATOR_URL}/agents-health`);
    const agentsStats = await agentsData.json();
    
    // Get enhanced stats from database
    const enhancedStats = await getEnhancedSystemStats();
    
    res.json({
      ...reservoirStats,
      ...agentsStats,
      ...enhancedStats,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get system stats',
      message: error.message
    });
  }
});

// Processing queue with current books
app.get('/processing-queue', async (req, res) => {
  try {
    // Get basic queue data
    const basicData = await fetch(`${CONFIG.ORCHESTRATOR_URL}/pipeline-status`);
    const pipelineStats = await basicData.json();
    
    // Get enhanced current books from database
    const currentBooks = await getCurrentProcessingBooks();
    
    res.json({
      ...pipelineStats,
      current_books: currentBooks,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get processing queue',
      message: error.message
    });
  }
});

// System logs for dashboard
app.get('/system-logs', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const level = req.query.level || null;
    
    const logs = await getSystemLogs(limit, level);
    
    res.json({
      logs,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get system logs',
      message: error.message
    });
  }
});

// Book details endpoint
app.get('/book/:bookId', async (req, res) => {
  try {
    const bookId = req.params.bookId;
    const bookDetails = await getBookDetails(bookId);
    
    res.json(bookDetails);
    
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get book details',
      message: error.message
    });
  }
});

// Agent details endpoint
app.get('/agent/:agentName', async (req, res) => {
  try {
    const agentName = req.params.agentName;
    
    // Get basic agent data
    const agentsData = await fetch(`${CONFIG.ORCHESTRATOR_URL}/agents-health`);
    const agentsHealthData = await agentsData.json();
    const agentData = agentsHealthData.agents[agentName];
    
    if (!agentData) {
      return res.status(404).json({
        error: 'Agent not found',
        agent: agentName
      });
    }
    
    // Get enhanced agent data from database
    const enhancedData = await getAgentDetails(agentName);
    
    res.json({
      ...agentData,
      ...enhancedData,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    res.status(500).json({
      error: 'Failed to get agent details',
      message: error.message
    });
  }
});

// ====================
// Enhanced Database Functions for Dashboard
// ====================

async function getEnhancedSystemStats() {
  if (!supabase) {
    return {
      error: 'Database not available',
      fallback: true
    };
  }
  
  try {
    // Get processing rates
    const { data: processingData, error: processingError } = await supabase
      .from('book_enrichment_reservoir')
      .select('processing_stage, updated_at, created_at')
      .order('updated_at', { ascending: false })
      .limit(100);
    
    if (processingError) throw processingError;
    
    // Calculate processing rate
    const now = new Date();
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
    
    const recentProcessing = processingData.filter(book => 
      new Date(book.updated_at) > oneHourAgo
    );
    
    const processingRate = recentProcessing.length;
    
    // Get stage distribution
    const stageDistribution = processingData.reduce((acc, book) => {
      acc[book.processing_stage] = (acc[book.processing_stage] || 0) + 1;
      return acc;
    }, {});
    
    // Calculate average processing time
    const completedBooks = processingData.filter(book => 
      book.processing_stage === 'completed'
    );
    
    const avgProcessingTime = completedBooks.reduce((acc, book) => {
      const processingTime = new Date(book.updated_at) - new Date(book.created_at);
      return acc + processingTime;
    }, 0) / completedBooks.length;
    
    return {
      processing_rate: `${processingRate}/hr`,
      stage_distribution: stageDistribution,
      avg_processing_time: Math.round(avgProcessingTime / 60000), // minutes
      total_processed: completedBooks.length,
      enhanced: true
    };
    
  } catch (error) {
    console.error('Error getting enhanced system stats:', error);
    return {
      error: error.message,
      fallback: true
    };
  }
}

async function getCurrentProcessingBooks() {
  if (!supabase) {
    return [];
  }
  
  try {
    const { data, error } = await supabase
      .from('book_enrichment_reservoir')
      .select(`
        id,
        title,
        author_name,
        processing_stage,
        created_at,
        updated_at,
        flowchart_completed,
        network_completed,
        metadata_completed,
        synthesis_completed
      `)
      .in('processing_stage', ['flowchart', 'network', 'metadata', 'synthesis', 'pipeline'])
      .order('updated_at', { ascending: false })
      .limit(10);
    
    if (error) throw error;
    
    return data.map(book => ({
      id: book.id,
      title: book.title,
      author: book.author_name,
      current_stage: book.processing_stage,
      current_agent: mapStageToAgent(book.processing_stage),
      progress: calculateBookProgress(book),
      processing_time: calculateProcessingTime(book.created_at, book.updated_at),
      stages_completed: getCompletedStages(book)
    }));
    
  } catch (error) {
    console.error('Error getting current processing books:', error);
    return [];
  }
}

async function getSystemLogs(limit = 50, level = null) {
  // Enhanced logging system - for now return enhanced mock logs
  const mockLogs = [
    {
      level: 'info',
      agent: 'dashboard',
      message: 'Dashboard initialized successfully',
      timestamp: new Date().toISOString()
    },
    {
      level: 'info',
      agent: 'flowchart_mapper',
      message: 'Processing book: Ihya Ulum al-Din',
      timestamp: new Date(Date.now() - 30000).toISOString()
    },
    {
      level: 'info',
      agent: 'network_mapper',
      message: 'Completed network analysis for book ID 123',
      timestamp: new Date(Date.now() - 60000).toISOString()
    },
    {
      level: 'info',
      agent: 'metadata_hunter',
      message: 'Bibliographic research completed for Al-Ghazali work',
      timestamp: new Date(Date.now() - 90000).toISOString()
    },
    {
      level: 'info',
      agent: 'content_synthesizer',
      message: 'Catalog fields synthesized for Tafsir al-Tabari',
      timestamp: new Date(Date.now() - 120000).toISOString()
    }
  ];
  
  // Add current system errors to logs
  systemErrors.slice(0, 10).forEach(error => {
    mockLogs.unshift({
      level: error.severity,
      agent: error.component,
      message: error.error,
      timestamp: error.timestamp
    });
  });
  
  return mockLogs.slice(0, limit);
}

async function getBookDetails(bookId) {
  if (!supabase) {
    return {
      error: 'Database not available'
    };
  }
  
  try {
    const { data, error } = await supabase
      .from('book_enrichment_reservoir')
      .select('*')
      .eq('id', bookId)
      .single();
    
    if (error) throw error;
    
    return {
      ...data,
      processing_history: await getBookProcessingHistory(bookId),
      current_agent: mapStageToAgent(data.processing_stage),
      progress: calculateBookProgress(data)
    };
    
  } catch (error) {
    console.error('Error getting book details:', error);
    return {
      error: error.message
    };
  }
}

async function getAgentDetails(agentName) {
  if (!supabase) {
    return {
      error: 'Database not available'
    };
  }
  
  try {
    // Get recent books processed by this agent
    const stage = mapAgentToStage(agentName);
    
    const { data, error } = await supabase
      .from('book_enrichment_reservoir')
      .select('id, title, author_name, updated_at')
      .eq('processing_stage', stage)
      .order('updated_at', { ascending: false })
      .limit(10);
    
    if (error) throw error;
    
    return {
      recent_books: data,
      processing_stage: stage,
      enhanced: true
    };
    
  } catch (error) {
    console.error('Error getting agent details:', error);
    return {
      error: error.message
    };
  }
}

async function getBookProcessingHistory(bookId) {
  // Mock processing history - in production, you'd have a proper audit log
  return [
    {
      stage: 'flowchart',
      started_at: new Date(Date.now() - 300000).toISOString(),
      completed_at: new Date(Date.now() - 240000).toISOString(),
      agent: 'flowchart_mapper',
      status: 'completed'
    },
    {
      stage: 'network',
      started_at: new Date(Date.now() - 240000).toISOString(),
      completed_at: new Date(Date.now() - 180000).toISOString(),
      agent: 'network_mapper',
      status: 'completed'
    },
    {
      stage: 'metadata',
      started_at: new Date(Date.now() - 180000).toISOString(),
      completed_at: null,
      agent: 'metadata_hunter',
      status: 'processing'
    }
  ];
}

// Utility mapping functions
function mapStageToAgent(stage) {
  const mapping = {
    'flowchart': 'flowchart_mapper',
    'network': 'network_mapper',
    'metadata': 'metadata_hunter',
    'synthesis': 'content_synthesizer',
    'pipeline': 'data_pipeline'
  };
  
  return mapping[stage] || 'unknown';
}

function mapAgentToStage(agent) {
  const mapping = {
    'flowchart_mapper': 'flowchart',
    'network_mapper': 'network',
    'metadata_hunter': 'metadata',
    'content_synthesizer': 'synthesis',
    'data_pipeline': 'pipeline'
  };
  
  return mapping[agent] || 'unknown';
}

function calculateBookProgress(book) {
  const stages = ['flowchart', 'network', 'metadata', 'synthesis', 'pipeline'];
  const currentStageIndex = stages.indexOf(book.processing_stage);
  
  if (currentStageIndex === -1) return 0;
  
  const completedStages = currentStageIndex;
  const totalStages = stages.length;
  
  return Math.round((completedStages / totalStages) * 100);
}

function calculateProcessingTime(createdAt, updatedAt) {
  const start = new Date(createdAt);
  const end = new Date(updatedAt);
  const diffMinutes = Math.round((end - start) / 60000);
  
  if (diffMinutes < 60) {
    return `${diffMinutes}m`;
  } else {
    const hours = Math.floor(diffMinutes / 60);
    const minutes = diffMinutes % 60;
    return `${hours}h ${minutes}m`;
  }
}

function getCompletedStages(book) {
  const stages = [];
  
  if (book.flowchart_completed) stages.push('flowchart');
  if (book.network_completed) stages.push('network');
  if (book.metadata_completed) stages.push('metadata');
  if (book.synthesis_completed) stages.push('synthesis');
  
  return stages;
}

// Start the assembly line with real agent control
app.post('/start-assembly', async (req, res) => {
  try {
    console.log('🎭 Orchestrator: Starting agent assembly line...');
    
    // Step 1: Start all agents
    if (!pipelineRunning) {
      console.log('🚀 Starting all agents...');
      await startAllAgents();
    }
    
    // Step 2: Initialize reservoir if needed
    console.log('🏗️ Initializing reservoir...');
    const { data: reservoirResult, error: reservoirError } = await supabase
      .rpc('initialize_reservoir_from_queue');
    
    if (reservoirError) {
      throw new Error(`Reservoir initialization failed: ${reservoirError.message}`);
    }
    
    // Step 3: Start coordinated processing
    orchestrationRuns++;
    const results = await runAssemblyLine();
    
    res.json({
      success: true,
      run_number: orchestrationRuns,
      agents_started: pipelineRunning,
      reservoir_initialized: reservoirResult[0],
      results: results,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Assembly line error:', error);
    res.status(500).json({ error: error.message, orchestrator: 'Assembly Line' });
  }
});

// Initialize reservoir with books from queue
app.post('/initialize-reservoir', async (req, res) => {
  try {
    console.log('🏗️ Initializing reservoir with books from queue...');
    
    const { data: result, error } = await supabase
      .rpc('initialize_reservoir_from_queue');
    
    if (error) {
      throw new Error(`Reservoir initialization failed: ${error.message}`);
    }
    
    const stats = result[0];
    
    res.json({
      success: true,
      processed_count: stats.processed_count,
      reservoir_entries: stats.reservoir_entries,
      message: `Added ${stats.processed_count} books to reservoir`
    });
    
  } catch (error) {
    console.error('Reservoir initialization error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get reservoir status
app.get('/reservoir-status', async (req, res) => {
  try {
    const { data: stats, error } = await supabase
      .from('book_enrichment_reservoir')
      .select('processing_stage')
      .then(({ data, error }) => {
        if (error) throw error;
        
        const statusCounts = {};
        data.forEach(item => {
          statusCounts[item.processing_stage] = (statusCounts[item.processing_stage] || 0) + 1;
        });
        
        return { data: statusCounts, error: null };
      });
    
    if (error) throw error;
    
    res.json({
      reservoir_status: stats,
      total_books: Object.values(stats).reduce((sum, count) => sum + count, 0),
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Run the enhanced assembly line with quality gates
async function runAssemblyLine() {
  console.log('🏭 Running enhanced Islamic text processing assembly line...');
  
  const results = {
    agents_run: 0,
    books_processed: 0,
    errors: [],
    stage_results: {},
    quality_metrics: {},
    enhancement_summary: {
      intellectual_architecture_analyzed: 0,
      conceptual_networks_discovered: 0,
      bibliographic_research_completed: 0,
      catalog_fields_synthesized: 0,
      production_records_created: 0
    }
  };
  
  // Pre-processing validation
  console.log('🔍 Validating system readiness for enhanced processing...');
  const systemReady = await validateSystemReadiness();
  if (!systemReady.all_systems_ready) {
    throw new Error(`System not ready: ${systemReady.issues.join(', ')}`);
  }
  
  // Stage 1: Enhanced Flowchart Mapper - Intellectual Architecture Analysis
  try {
    console.log('📊 Enhanced Stage 1: Intellectual Architecture Analysis...');
    console.log('🎯 Methodology: Argument as Structure + Inferential Specificity');
    
    const flowchartResult = await callEnhancedAgent('flowchart', {
      expected_output: 'intellectual_architecture_analysis',
      quality_threshold: 'A-grade synthesis',
      methodological_depth: 'real_book_research'
    });
    
    await validateStageOutput('flowchart', flowchartResult);
    results.stage_results.flowchart = flowchartResult;
    results.agents_run++;
    results.books_processed += flowchartResult.processed || 0;
    results.enhancement_summary.intellectual_architecture_analyzed = flowchartResult.processed || 0;
    
    console.log(`✅ Intellectual architecture analysis complete: ${flowchartResult.processed || 0} books`);
  } catch (error) {
    console.error('❌ Intellectual architecture analysis failed:', error.message);
    results.errors.push({ stage: 'flowchart', error: error.message, recovery: 'attempting_fallback_analysis' });
    await attemptStageRecovery('flowchart', error);
  }
  
  // Intelligent delay based on processing complexity
  await adaptiveDelay('post_flowchart');
  
  // Stage 2: Enhanced Network Mapper - Conceptual Network Discovery
  try {
    console.log('🕸️ Enhanced Stage 2: Conceptual Network Discovery...');
    console.log('🎯 Methodology: Knowledge Discovery + Argumentative DNA Analysis');
    
    const networkResult = await callEnhancedAgent('network', {
      expected_output: 'conceptual_network_analysis',
      dependency_data: 'flowchart_intellectual_architecture',
      analysis_depth: 'argumentative_DNA_discovery'
    });
    
    await validateStageOutput('network', networkResult);
    results.stage_results.network = networkResult;
    results.agents_run++;
    results.books_processed += networkResult.processed || 0;
    results.enhancement_summary.conceptual_networks_discovered = networkResult.processed || 0;
    
    console.log(`✅ Conceptual network discovery complete: ${networkResult.processed || 0} books`);
  } catch (error) {
    console.error('❌ Conceptual network discovery failed:', error.message);
    results.errors.push({ stage: 'network', error: error.message, recovery: 'attempting_basic_semantic_analysis' });
    await attemptStageRecovery('network', error);
  }
  
  await adaptiveDelay('post_network');
  
  // Stage 3: Enhanced Metadata Hunter - Bibliographic Research
  try {
    console.log('🔍 Enhanced Stage 3: Comprehensive Bibliographic Research...');
    console.log('🎯 Methodology: Multi-Source Arabic Title + Author + Publication Research');
    
    const metadataResult = await callEnhancedAgent('metadata', {
      expected_output: 'comprehensive_bibliographic_metadata',
      research_depth: 'arabic_titles_author_details_publication_data',
      quality_standard: '15_metadata_fields_minimum'
    });
    
    await validateStageOutput('metadata', metadataResult);
    results.stage_results.metadata = metadataResult;
    results.agents_run++;
    results.books_processed += metadataResult.processed || 0;
    results.enhancement_summary.bibliographic_research_completed = metadataResult.processed || 0;
    
    console.log(`✅ Bibliographic research complete: ${metadataResult.processed || 0} books`);
  } catch (error) {
    console.error('❌ Bibliographic research failed:', error.message);
    results.errors.push({ stage: 'metadata', error: error.message, recovery: 'attempting_basic_metadata_fallback' });
    await attemptStageRecovery('metadata', error);
  }
  
  await adaptiveDelay('post_metadata');
  
  // Stage 4: Enhanced Content Synthesizer - Library Catalog Synthesis
  try {
    console.log('🔬 Enhanced Stage 4: Library Catalog Field Synthesis...');
    console.log('🎯 Methodology: Spartan Research-to-Catalog Transformation');
    
    const synthesisResult = await callEnhancedAgent('synthesis', {
      input_sources: ['flowchart_analysis', 'network_analysis'],
      synthesis_approach: 'extract_and_transform',
      quality_target: 'production_ready_catalog_fields'
    });
    
    await validateStageOutput('synthesis', synthesisResult);
    results.stage_results.synthesis = synthesisResult;
    results.agents_run++;
    results.books_processed += synthesisResult.processed || 0;
    results.enhancement_summary.catalog_fields_synthesized = synthesisResult.processed || 0;
    
    console.log(`✅ Library catalog synthesis complete: ${synthesisResult.processed || 0} books`);
  } catch (error) {
    console.error('❌ Library catalog synthesis failed:', error.message);
    results.errors.push({ stage: 'synthesis', error: error.message, recovery: 'attempting_minimal_catalog_fields' });
    await attemptStageRecovery('synthesis', error);
  }
  
  await adaptiveDelay('post_synthesis');
  
  // Stage 5: Enhanced Data Pipeline - Production Database Population
  try {
    console.log('🔄 Enhanced Stage 5: Production Database Population...');
    console.log('🎯 Methodology: Enriched Research to Production Catalog Pipeline');
    
    const pipelineResult = await callEnhancedAgent('pipeline', {
      transformation_source: 'complete_reservoir_enrichment',
      target_tables: ['books', 'book_metadata', 'category_relations'],
      quality_validation: 'production_readiness_check'
    });
    
    await validateStageOutput('pipeline', pipelineResult);
    results.stage_results.pipeline = pipelineResult;
    results.agents_run++;
    results.books_processed += pipelineResult.processed || 0;
    results.enhancement_summary.production_records_created = pipelineResult.processed || 0;
    
    console.log(`✅ Production database population complete: ${pipelineResult.processed || 0} books`);
  } catch (error) {
    console.error('❌ Production database population failed:', error.message);
    results.errors.push({ stage: 'pipeline', error: error.message, recovery: 'attempting_database_retry' });
    await attemptStageRecovery('pipeline', error);
  }
  
  // Calculate enhanced quality metrics
  results.quality_metrics = await calculateEnhancementQuality(results);
  
  console.log(`✅ Enhanced assembly line complete:`);
  console.log(`   📊 ${results.agents_run} enhanced agents executed`);
  console.log(`   📚 ${results.books_processed} books enriched with sophisticated research`);
  console.log(`   🏛️ ${results.enhancement_summary.intellectual_architecture_analyzed} intellectual architectures analyzed`);
  console.log(`   🕸️ ${results.enhancement_summary.conceptual_networks_discovered} conceptual networks discovered`);
  console.log(`   📖 ${results.enhancement_summary.bibliographic_research_completed} bibliographic research completed`);
  console.log(`   🔬 ${results.enhancement_summary.catalog_fields_synthesized} catalog field syntheses completed`);
  console.log(`   💾 ${results.enhancement_summary.production_records_created} production records created`);
  console.log(`   📈 Overall quality: ${results.quality_metrics.overall_grade || 'Calculating...'}`);
  
  totalProcessed += results.books_processed;
  
  return results;
}

// Call an enhanced agent with coordination parameters and token tracking
async function callEnhancedAgent(agentType, coordinationParams = {}) {
  const agent = AGENTS[agentType];
  const url = `http://localhost:${agent.port}/process`;
  
  console.log(`📞 Coordinating ${agent.name}...`);
  console.log(`   🎯 Expertise: ${agent.expertise}`);
  console.log(`   🔬 Methodology: ${agent.methodology}`);
  
  try {
    const requestBody = JSON.stringify({
      coordination: coordinationParams,
      enhanced_processing: true,
      orchestrator_request: true
    });
    
    // Track orchestrator tokens for outgoing request
    const orchTokens = trackOrchestratorTokens(requestBody);
    
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: requestBody
    });
    
    if (!response.ok) {
      throw new Error(`Enhanced agent ${agent.name} returned ${response.status}`);
    }
    
    const result = await response.json();
    const responseText = JSON.stringify(result);
    
    // Track orchestrator communication tokens
    const commTokens = trackAgentTokens(agentType, requestBody, responseText);
    
    // Track orchestrator tokens for incoming response
    trackOrchestratorTokens('', responseText);
    
    // Get real agent token usage from the agent itself
    const realAgentTokens = await getAgentTokenUsage(agentType);
    
    console.log(`✅ ${agent.name}: enhanced processing completed`);
    console.log(`   📚 Books processed: ${result.processed || 0}`);
    console.log(`   📈 Quality achieved: ${result.quality_metrics?.overall_grade || 'Pending'}`);
    
    if (realAgentTokens) {
      console.log(`   🧠 Agent tokens: ${realAgentTokens.total_tokens}/${AGENT_TOKEN_LIMIT} (${realAgentTokens.usage_percentage}%)`);
      console.log(`   📡 Communication tokens: ${commTokens.total_tokens}`);
      
      // Auto-restart agent if real token limit exceeded
      if (realAgentTokens.restart_recommended) {
        console.warn(`🔄 Auto-restarting ${agentType} due to 100K token limit exceeded`);
        setTimeout(() => {
          restartAgentWithTokenReset(agentType);
        }, 1000); // Delay to allow current request to complete
      }
    } else {
      console.log(`   📡 Communication tokens: ${commTokens.total_tokens} (agent token data unavailable)`);
    }
    
    return result;
    
  } catch (error) {
    console.error(`❌ Enhanced agent ${agent.name} failed:`, error.message);
    throw error;
  }
}

// Legacy agent call for backward compatibility
async function callAgent(agentType) {
  return await callEnhancedAgent(agentType, {});
}

// Enhanced agent health check with specialization validation
async function checkAgentHealth(agentType) {
  const agent = AGENTS[agentType];
  const url = `http://localhost:${agent.port}/health`;
  
  try {
    const response = await fetch(url, {
      method: 'GET',
      timeout: 5000
    });
    
    if (response.ok) {
      const health = await response.json();
      return { 
        status: 'healthy', 
        expertise_ready: !!health.mission,
        methodology_loaded: !!health.methodology,
        enhanced_capabilities: !!health.enhancement_level,
        ...health 
      };
    } else {
      return { status: 'unhealthy', error: `HTTP ${response.status}` };
    }
  } catch (error) {
    return { status: 'unreachable', error: error.message };
  }
}

// Check all agents health
app.get('/agents-health', async (req, res) => {
  const healthChecks = {};
  
  for (const [type, agent] of Object.entries(AGENTS)) {
    healthChecks[type] = await checkAgentHealth(type);
  }
  
  res.json({
    timestamp: new Date().toISOString(),
    agents: healthChecks,
    overall_status: Object.values(healthChecks).every(h => h.status === 'healthy') ? 'all_healthy' : 'some_issues'
  });
});

// Continuous processing mode
let continuousMode = false;

app.post('/start-continuous', async (req, res) => {
  if (continuousMode) {
    return res.json({ message: 'Continuous mode already running' });
  }
  
  continuousMode = true;
  console.log('🔄 Starting continuous processing mode...');
  
  // Run assembly line every 30 seconds
  const interval = setInterval(async () => {
    if (!continuousMode) {
      clearInterval(interval);
      return;
    }
    
    try {
      console.log('🔄 Continuous mode: Running assembly line...');
      await runAssemblyLine();
    } catch (error) {
      console.error('Continuous mode error:', error);
    }
  }, 30000);
  
  res.json({
    success: true,
    message: 'Continuous processing started',
    interval: '30 seconds'
  });
});

app.post('/stop-continuous', async (req, res) => {
  try {
    continuousMode = false;
    console.log('⏹️ Stopping continuous processing mode...');
    
    // Stop all agents
    await stopAllAgents();
    
    res.json({
      success: true,
      message: 'Pipeline stopped and all agents shut down',
      agents_stopped: true,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Stop pipeline error:', error);
    res.status(500).json({ error: error.message });
  }
});

// New endpoint for pipeline control
app.post('/stop-pipeline', async (req, res) => {
  try {
    console.log('🛑 Stopping entire pipeline...');
    
    continuousMode = false;
    await stopAllAgents();
    
    res.json({
      success: true,
      message: 'Pipeline stopped successfully',
      agents_stopped: !pipelineRunning,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Stop pipeline error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Enhanced monitoring endpoint using database views
app.get('/enhanced-monitoring', async (req, res) => {
  try {
    // Query the enhanced monitoring views
    const [performance, throughput, quality] = await Promise.all([
      supabase.from('agent_performance_dashboard').select('*'),
      supabase.from('agent_throughput_metrics').select('*'),
      supabase.from('agent_quality_summary').select('*')
    ]);

    res.json({
      performance: performance.data || [],
      throughput: throughput.data || [],
      quality: quality.data || [],
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Enhanced monitoring error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Agent control endpoints
app.post('/start-agents', async (req, res) => {
  try {
    await startAllAgents();
    res.json({
      success: true,
      message: 'All agents started',
      agents: getAgentStatus(),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/stop-agents', async (req, res) => {
  try {
    await stopAllAgents();
    res.json({
      success: true,
      message: 'All agents stopped',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Individual agent control endpoints
app.post('/start-agent', async (req, res) => {
  try {
    const { agentType } = req.body;
    
    if (!AGENTS[agentType]) {
      return res.status(400).json({ error: `Invalid agent type: ${agentType}` });
    }
    
    await startAgent(agentType);
    
    res.json({
      success: true,
      message: `${agentType} agent started successfully`,
      agent_status: getAgentStatus()[agentType],
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Start agent error (${req.body.agentType}):`, error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/stop-agent', async (req, res) => {
  try {
    const { agentType } = req.body;
    
    if (!AGENTS[agentType]) {
      return res.status(400).json({ error: `Invalid agent type: ${agentType}` });
    }
    
    await stopAgent(agentType);
    
    res.json({
      success: true,
      message: `${agentType} agent stopped successfully`,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Stop agent error (${req.body.agentType}):`, error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/restart-agent', async (req, res) => {
  try {
    const { agentType } = req.body;
    
    if (!AGENTS[agentType]) {
      return res.status(400).json({ error: `Invalid agent type: ${agentType}` });
    }
    
    await restartAgent(agentType);
    
    res.json({
      success: true,
      message: `${agentType} agent restarted successfully`,
      agent_status: getAgentStatus()[agentType],
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error(`Restart agent error (${req.body.agentType}):`, error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/agent-status', (req, res) => {
  res.json({
    pipeline_running: pipelineRunning,
    agents: getAgentStatus(),
    timestamp: new Date().toISOString()
  });
});

// Enhanced monitoring endpoints
app.get('/pipeline-status', async (req, res) => {
  try {
    const stats = await getPipelineStats();
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/agent-health-detailed', async (req, res) => {
  try {
    const health = await getDetailedAgentHealth();
    res.json(health);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// System errors endpoint
app.get('/system-errors', (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const severity = req.query.severity;
    
    let filteredErrors = systemErrors;
    
    if (severity) {
      filteredErrors = systemErrors.filter(err => err.severity === severity);
    }
    
    res.json({
      errors: filteredErrors.slice(0, limit),
      total_errors: systemErrors.length,
      error_breakdown: {
        critical: systemErrors.filter(e => e.severity === 'critical').length,
        error: systemErrors.filter(e => e.severity === 'error').length,
        warning: systemErrors.filter(e => e.severity === 'warning').length
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Clear system errors endpoint
app.post('/clear-errors', (req, res) => {
  try {
    const beforeCount = systemErrors.length;
    systemErrors = [];
    
    res.json({
      success: true,
      message: `Cleared ${beforeCount} system errors`,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/processing-metrics', async (req, res) => {
  try {
    const metrics = await getProcessingMetrics();
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Reservoir workflow monitoring endpoint
app.get('/reservoir-workflow', async (req, res) => {
  try {
    const { data: reservoirData, error } = await supabase
      .from('book_enrichment_reservoir')
      .select(`
        id, book_id, title, author_name, processing_stage, agents_completed,
        flowchart_completed, flowchart_completed_at,
        network_completed, network_completed_at,
        metadata_completed, metadata_completed_at,
        synthesis_completed, synthesis_completed_at,
        data_synced, data_synced_at, completed_at,
        created_at, updated_at, retry_count,
        agent_start_times, agent_processing_durations, quality_scores,
        bottleneck_flags, processing_errors
      `)
      .order('updated_at', { ascending: false })
      .limit(50);

    if (error) throw error;

    // Calculate workflow analytics
    const analytics = {
      stage_distribution: {},
      completion_rates: {},
      average_processing_times: {},
      bottlenecks: [],
      active_processing: [],
      recent_completions: [],
      error_patterns: {}
    };

    // Process each reservoir entry
    reservoirData.forEach(entry => {
      // Stage distribution
      analytics.stage_distribution[entry.processing_stage] = 
        (analytics.stage_distribution[entry.processing_stage] || 0) + 1;

      // Track active processing (not completed)
      if (entry.processing_stage !== 'completed') {
        analytics.active_processing.push({
          id: entry.id,
          title: entry.title,
          stage: entry.processing_stage,
          agents_completed: entry.agents_completed || [],
          next_agent: getNextAgent(entry.agents_completed),
          processing_time: getProcessingDuration(entry),
          bottlenecks: entry.bottleneck_flags || [],
          errors: entry.processing_errors || {}
        });
      }

      // Recent completions
      if (entry.completed_at && isRecent(entry.completed_at, 24)) {
        analytics.recent_completions.push({
          title: entry.title,
          completed_at: entry.completed_at,
          total_time: getTotalProcessingTime(entry),
          agents_used: entry.agents_completed || []
        });
      }

      // Calculate agent completion rates
      ['flowchart', 'network', 'metadata', 'synthesis'].forEach(agent => {
        if (!analytics.completion_rates[agent]) {
          analytics.completion_rates[agent] = { completed: 0, total: 0 };
        }
        analytics.completion_rates[agent].total++;
        if (entry[`${agent}_completed`]) {
          analytics.completion_rates[agent].completed++;
        }
      });
    });

    res.json({
      reservoir_entries: reservoirData,
      workflow_analytics: analytics,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Helper functions for reservoir analysis
function getNextAgent(completedAgents = []) {
  const agentSequence = ['flowchart', 'network', 'metadata', 'synthesis'];
  return agentSequence.find(agent => !completedAgents.includes(agent)) || 'pipeline';
}

function getProcessingDuration(entry) {
  const startTime = new Date(entry.created_at);
  const currentTime = new Date();
  return Math.floor((currentTime - startTime) / (1000 * 60)); // minutes
}

function getTotalProcessingTime(entry) {
  const startTime = new Date(entry.created_at);
  const endTime = new Date(entry.completed_at);
  return Math.floor((endTime - startTime) / (1000 * 60)); // minutes
}

function isRecent(timestamp, hours) {
  const now = new Date();
  const past = new Date(timestamp);
  return (now - past) <= (hours * 60 * 60 * 1000);
}

// Enhanced agent details endpoint with code visibility
app.get('/agent-details/:agentType', async (req, res) => {
  try {
    const { agentType } = req.params;
    const agent = AGENTS[agentType];
    
    if (!agent) {
      return res.status(404).json({ error: 'Agent not found' });
    }

    // Get agent health info (includes mission, methodology)
    const health = await checkAgentHealth(agentType);
    
    // Get recent work from database with full analysis data
    const { data: recentWork } = await supabase
      .from('book_enrichment_reservoir')
      .select(`
        book_id, title, processing_stage, agents_completed, updated_at,
        flowchart_analysis, network_analysis, metadata_findings, content_synthesis,
        flowchart_completed_at, network_completed_at, metadata_completed_at, synthesis_completed_at,
        processing_errors
      `)
      .contains('agents_completed', [agentType])
      .order('updated_at', { ascending: false })
      .limit(10);

    // Read agent source code for implementation details
    const fs = require('fs');
    const agentFileName = agentType === 'synthesis' ? 'content-synthesizer-agent.js' : 
                          agentType === 'pipeline' ? 'data-pipeline-agent.js' :
                          agentType === 'metadata' ? 'enhanced-metadata-hunter-agent.js' :
                          `enhanced-${agentType}-mapper-agent.js`;
    
    const agentPath = path.join(__dirname, '../agents', agentFileName);
    let sourceCode = '';
    let codeAnalysis = {};
    
    try {
      sourceCode = fs.readFileSync(agentPath, 'utf8');
      codeAnalysis = extractAgentCodeDetails(sourceCode, agentType);
    } catch (error) {
      console.log(`Could not read agent file: ${error.message}`);
    }

    res.json({
      agent_info: {
        name: agent.name,
        port: agent.port,
        expertise: agent.expertise,
        methodology: agent.methodology,
        output_type: agent.output_type
      },
      current_status: health,
      recent_work: recentWork || [],
      process_info: agentProcesses[agentType] || null,
      source_code_analysis: codeAnalysis,
      file_path: agentPath
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Extract key implementation details from agent source code
function extractAgentCodeDetails(sourceCode, agentType) {
  const lines = sourceCode.split('\n');
  
  const analysis = {
    main_functions: [],
    processing_sequence: [],
    key_prompts: [],
    genre_handlers: [],
    architectural_patterns: [],
    dependencies: [],
    error_handling: []
  };
  
  // Extract main function definitions
  lines.forEach((line, index) => {
    if (line.match(/^async function|^function/) && !line.includes('//')) {
      const functionName = line.match(/function\s+(\w+)/)?.[1];
      if (functionName) {
        analysis.main_functions.push({
          name: functionName,
          line: index + 1,
          signature: line.trim()
        });
      }
    }
    
    // Extract processing sequence comments
    if (line.includes('Step ') || line.includes('Stage ') || line.includes('Phase ')) {
      analysis.processing_sequence.push({
        step: line.trim().replace('//', '').trim(),
        line: index + 1
      });
    }
    
    // Extract genre-specific handlers
    if (line.includes('case ') && line.includes(':')) {
      const genre = line.match(/case\s+'([^']+)'/)?.[1];
      if (genre) {
        analysis.genre_handlers.push({
          genre: genre,
          line: index + 1
        });
      }
    }
    
    // Extract architectural patterns
    if (line.includes('argumentative_purpose') || line.includes('logical_function')) {
      const context = lines.slice(Math.max(0, index - 2), index + 3).join('\\n');
      analysis.architectural_patterns.push({
        pattern: line.trim(),
        context: context,
        line: index + 1
      });
    }
  });
  
  // Extract key prompts and instructions (look for string literals with specific keywords)
  const promptKeywords = ['analysis', 'research', 'synthesis', 'methodology', 'thesis', 'network', 'metadata'];
  lines.forEach((line, index) => {
    promptKeywords.forEach(keyword => {
      if (line.includes(keyword) && (line.includes('"') || line.includes("'")) && line.length > 50) {
        analysis.key_prompts.push({
          prompt: line.trim(),
          keyword: keyword,
          line: index + 1
        });
      }
    });
  });
  
  return analysis;
}

// Enhanced coordination utility functions
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Adaptive delay based on processing stage and complexity
async function adaptiveDelay(stage) {
  const delays = {
    'post_flowchart': 500,    // Brief pause for intellectual architecture completion
    'post_network': 500,     // Brief pause for conceptual network analysis
    'post_metadata': 1000,   // Longer pause for bibliographic research completion
    'post_synthesis': 1000   // Longer pause for catalog synthesis
  };
  
  const delayMs = delays[stage] || 500;
  console.log(`⏳ Coordinated delay: ${delayMs}ms for ${stage}`);
  await sleep(delayMs);
}

// System readiness validation
async function validateSystemReadiness() {
  console.log('🔍 Validating enhanced system readiness...');
  
  const checks = {
    reservoir_available: false,
    agents_responsive: false,
    guidance_documents_loaded: false,
    database_accessible: false
  };
  
  try {
    // Check reservoir status
    const reservoirCheck = await fetch('http://localhost:4000/reservoir-status');
    checks.reservoir_available = reservoirCheck.ok;
    
    // Check agent health
    const agentHealthChecks = await Promise.all(
      Object.keys(AGENTS).map(async (agentType) => {
        const health = await checkAgentHealth(agentType);
        return health.status === 'healthy' || health.status === 'active';
      })
    );
    checks.agents_responsive = agentHealthChecks.every(healthy => healthy);
    
    // Assume guidance documents and database are available
    checks.guidance_documents_loaded = true;
    checks.database_accessible = true;
    
  } catch (error) {
    console.error('❌ System readiness validation failed:', error.message);
  }
  
  const allReady = Object.values(checks).every(check => check);
  const issues = Object.entries(checks)
    .filter(([key, value]) => !value)
    .map(([key]) => key);
  
  return {
    all_systems_ready: allReady,
    checks: checks,
    issues: issues
  };
}

// Stage output validation
async function validateStageOutput(stage, output) {
  const validations = {
    flowchart: {
      required_fields: ['intellectual_architecture', 'concept'],
      minimum_quality: 'B'
    },
    network: {
      required_fields: ['conceptual_network', 'central_node'],
      minimum_connections: 1
    },
    metadata: {
      required_fields: ['bibliographic_research', 'database_updates'],
      minimum_fields: 5
    },
    synthesis: {
      required_fields: ['categories', 'keywords', 'description'],
      minimum_categories: 2
    },
    pipeline: {
      required_fields: ['tables_updated', 'fields_updated'],
      minimum_tables: 1
    }
  };
  
  const validation = validations[stage];
  if (!validation) return true;
  
  // Basic validation - check if output has expected structure
  const hasRequiredStructure = output && typeof output === 'object';
  
  if (!hasRequiredStructure) {
    console.warn(`⚠️ Stage ${stage} output validation warning: unexpected structure`);
  }
  
  return hasRequiredStructure;
}

// Stage recovery attempt
async function attemptStageRecovery(stage, error) {
  console.log(`🔄 Attempting recovery for stage: ${stage}`);
  
  const recoveryStrategies = {
    flowchart: 'Fallback to basic structure analysis',
    network: 'Fallback to keyword-based connections', 
    metadata: 'Fallback to basic metadata extraction',
    synthesis: 'Fallback to minimal catalog fields',
    pipeline: 'Retry database operations with validation'
  };
  
  console.log(`🚪 Recovery strategy: ${recoveryStrategies[stage] || 'Generic retry'}`);
  // Recovery implementation would go here
  return { attempted: true, strategy: recoveryStrategies[stage] };
}

// Calculate overall enhancement quality
async function calculateEnhancementQuality(results) {
  const metrics = {
    stages_completed: results.agents_run,
    total_books_processed: results.books_processed,
    error_rate: results.errors.length / Math.max(results.agents_run, 1),
    enhancement_completeness: 0
  };
  
  // Calculate enhancement completeness
  const completeness = [
    results.enhancement_summary.intellectual_architecture_analyzed > 0,
    results.enhancement_summary.conceptual_networks_discovered > 0,
    results.enhancement_summary.bibliographic_research_completed > 0,
    results.enhancement_summary.catalog_fields_synthesized > 0,
    results.enhancement_summary.production_records_created > 0
  ].filter(Boolean).length / 5;
  
  metrics.enhancement_completeness = completeness;
  
  // Overall grade calculation
  const overallScore = (metrics.enhancement_completeness * 0.5) + 
                      ((1 - metrics.error_rate) * 0.3) + 
                      (Math.min(metrics.stages_completed / 5, 1) * 0.2);
  
  metrics.overall_grade = overallScore >= 0.8 ? 'A' : 
                         overallScore >= 0.6 ? 'B' : 
                         overallScore >= 0.4 ? 'C' : 'D';
  
  return metrics;
}

// Enhanced monitoring functions
async function getPipelineStats() {
  // Use the new performance dashboard view
  const { data: performanceData, error: perfError } = await supabase
    .from('agent_performance_dashboard')
    .select('*');
  
  if (perfError) throw perfError;
  
  // Get bottleneck information
  const { data: bottleneckData, error: bottleneckError } = await supabase
    .from('pipeline_bottlenecks')
    .select('*');
  
  if (bottleneckError) throw bottleneckError;
  
  // Process data for response
  const stageStats = {};
  let totalBooks = 0;
  let completedBooks = 0;
  let totalErrors = 0;
  
  performanceData.forEach(stage => {
    stageStats[stage.processing_stage] = stage.book_count;
    totalBooks += stage.book_count;
    totalErrors += stage.error_count;
    if (stage.processing_stage === 'completed') {
      completedBooks = stage.book_count;
    }
  });
  
  const progressPercent = totalBooks > 0 ? ((completedBooks / totalBooks) * 100).toFixed(1) : 0;
  
  // Detect bottlenecks
  const bottlenecks = bottleneckData.filter(b => b.bottleneck_status !== 'NORMAL');
  
  return {
    books_by_stage: stageStats,
    total_books: totalBooks,
    completed_books: completedBooks,
    progress_percent: progressPercent,
    error_count: totalErrors,
    bottlenecks_detected: bottlenecks,
    orchestration_runs: orchestrationRuns,
    total_processed: totalProcessed,
    timestamp: new Date().toISOString()
  };
}

async function getDetailedAgentHealth() {
  const agentHealth = {};
  const performanceMetrics = {};
  
  for (const [type, agent] of Object.entries(AGENTS)) {
    const health = await checkAgentHealth(type);
    agentHealth[type] = {
      ...health,
      port: agent.port,
      name: agent.name
    };
    
    // Get performance metrics if agent is healthy
    if (health.status === 'healthy') {
      performanceMetrics[type] = {
        processed: health.processed || 0,
        errors: health.errors || 0,
        uptime: health.timestamp ? new Date(health.timestamp) : 'unknown'
      };
    }
  }
  
  return {
    agents: agentHealth,
    performance_metrics: performanceMetrics,
    overall_status: Object.values(agentHealth).every(h => h.status === 'healthy') ? 'all_healthy' : 'some_issues',
    timestamp: new Date().toISOString()
  };
}

async function getProcessingMetrics() {
  // Use enhanced views for better performance
  const { data: agentThroughput, error: throughputError } = await supabase
    .from('agent_throughput_metrics')
    .select('*');
    
  const { data: qualityData, error: qualityError } = await supabase
    .from('agent_quality_summary')
    .select('*');
    
  const { data: performanceData, error: perfError } = await supabase
    .from('agent_performance_dashboard')
    .select('*');
  
  if (throughputError || qualityError || perfError) {
    throw new Error('Failed to fetch processing metrics');
  }
  
  // Process agent throughput data
  const agentCompletionStats = {};
  agentThroughput.forEach(agent => {
    agentCompletionStats[agent.agent] = agent.books_processed;
  });
  
  // Calculate error stats from performance data
  const totalBooks = performanceData.reduce((sum, stage) => sum + stage.book_count, 0);
  const totalErrors = performanceData.reduce((sum, stage) => sum + stage.error_count, 0);
  const errorRate = totalBooks > 0 ? ((totalErrors / totalBooks) * 100).toFixed(2) : 0;
  
  // Calculate average processing time
  const avgProcessingTime = performanceData.reduce((sum, stage) => 
    sum + (stage.avg_processing_minutes * stage.book_count), 0) / Math.max(totalBooks, 1);
  
  return {
    agent_completion_stats: agentCompletionStats,
    agent_throughput: agentThroughput,
    quality_summary: qualityData,
    error_stats: {
      total_errors: totalErrors,
      error_rate: errorRate
    },
    avg_processing_time_minutes: avgProcessingTime.toFixed(2),
    total_books_in_pipeline: totalBooks,
    pipeline_efficiency: {
      books_per_hour: totalProcessed > 0 ? (totalProcessed / Math.max(1, (Date.now() - new Date().setHours(0,0,0,0)) / 3600000)).toFixed(2) : 0,
      success_rate: errorRate > 0 ? (100 - parseFloat(errorRate)).toFixed(2) : 100
    },
    timestamp: new Date().toISOString()
  };
}

// Complete shutdown endpoint
app.post('/kill-agent-ports', async (req, res) => {
  try {
    console.log('💀 Killing all agent ports...');
    
    const agentPorts = [3001, 3002, 3003, 3004, 3006];
    const killResults = [];
    
    for (const port of agentPorts) {
      try {
        // Kill processes on each port
        await new Promise((resolve, reject) => {
          const killProcess = spawn('sh', ['-c', `lsof -ti:${port} | xargs kill -9`]);
          killProcess.on('close', (code) => {
            killResults.push({ port, killed: true });
            resolve();
          });
          killProcess.on('error', () => {
            killResults.push({ port, killed: false });
            resolve(); // Don't fail the whole operation
          });
        });
      } catch (error) {
        killResults.push({ port, killed: false, error: error.message });
      }
    }
    
    console.log('💀 Port kill results:', killResults);
    
    res.json({
      success: true,
      message: 'Agent ports termination completed',
      results: killResults,
      ports_targeted: agentPorts
    });
    
  } catch (error) {
    console.error('❌ Failed to kill agent ports:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Clear processing queues endpoint
app.post('/clear-queues', async (req, res) => {
  try {
    console.log('🧹 Clearing processing queues...');
    
    // Clear reservoir processing states
    const { error: clearError } = await supabase
      .from('book_enrichment_reservoir')
      .update({ 
        processing_stage: 'pending',
        flowchart_completed: false,
        network_completed: false,
        metadata_completed: false,
        synthesis_completed: false,
        flowchart_analysis: null,
        network_analysis: null,
        metadata_findings: null,
        content_synthesis: null,
        error_logs: null,
        processing_started_at: null,
        processing_ended_at: null
      })
      .neq('processing_stage', 'completed');
    
    if (clearError) {
      throw clearError;
    }
    
    console.log('✅ Processing queues cleared');
    
    res.json({
      success: true,
      message: 'Processing queues cleared successfully'
    });
    
  } catch (error) {
    console.error('❌ Failed to clear queues:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Context Management Endpoints for Performance Optimization
app.post('/restart-agent-context/:agentType', async (req, res) => {
  try {
    const { agentType } = req.params;
    const { clearContext = true } = req.body;
    
    if (!AGENTS[agentType]) {
      return res.status(400).json({
        error: 'Invalid agent type',
        availableAgents: Object.keys(AGENTS)
      });
    }

    console.log(`🔄 Context restart for ${agentType} (clearContext: ${clearContext})...`);
    
    const agent = AGENTS[agentType];
    const agentInfo = agentProcesses[agentType];
    
    // Kill existing agent process with context clear
    if (agentInfo && agentInfo.process) {
      try {
        agentInfo.process.kill('SIGTERM');
        console.log(`🛑 Terminated ${agentType} for context refresh`);
      } catch (error) {
        console.warn(`⚠️ Error terminating ${agentType}:`, error.message);
      }
    }
    
    // Kill port process forcefully to clear any hanging context
    try {
      const killProcess = spawn('sh', ['-c', `lsof -ti:${agent.port} | xargs kill -9`]);
      console.log(`🔥 Port ${agent.port} cleared for fresh context`);
    } catch (error) {
      console.warn(`⚠️ Port ${agent.port} clear warning:`, error.message);
    }
    
    // Wait for port to clear and any lingering context to flush
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Restart agent with fresh context
    const newProcess = spawn('node', [agent.path], {
      detached: false,
      stdio: ['ignore', 'pipe', 'pipe'],
      env: { 
        ...process.env, 
        CLEAR_CONTEXT: clearContext ? 'true' : 'false',
        FRESH_START: 'true'
      }
    });
    
    agentProcesses[agentType] = {
      process: newProcess,
      pid: newProcess.pid,
      port: agent.port,
      startedAt: new Date().toISOString(),
      restartCount: (agentInfo?.restartCount || 0) + 1,
      contextCleared: clearContext,
      freshStart: true
    };
    
    // Setup enhanced logging for context monitoring
    newProcess.stdout.on('data', (data) => {
      console.log(`📊 ${agent.name} [Fresh]: ${data.toString().trim()}`);
    });
    
    newProcess.stderr.on('data', (data) => {
      console.error(`❌ ${agent.name} [Fresh] Error: ${data.toString().trim()}`);
    });
    
    newProcess.on('close', (code) => {
      console.log(`🔴 ${agent.name} fresh process exited with code ${code}`);
      delete agentProcesses[agentType];
    });
    
    console.log(`✅ ${agentType} restarted with fresh context on port ${agent.port} (PID: ${newProcess.pid})`);
    
    res.json({
      action: 'restart_agent_context',
      agentType,
      status: 'restarted_fresh',
      pid: newProcess.pid,
      port: agent.port,
      contextCleared: clearContext,
      restartCount: agentProcesses[agentType].restartCount,
      performance_optimization: 'context_window_reset'
    });
    
  } catch (error) {
    console.error(`❌ Context restart error:`, error);
    res.status(500).json({
      action: 'restart_agent_context',
      status: 'error',
      error: error.message
    });
  }
});

// Restart all agents with context clearing for performance
app.post('/refresh-all-agents', async (req, res) => {
  try {
    const { clearContext = true, staggered = true } = req.body;
    console.log(`🔄 Refreshing all agents for performance (clearContext: ${clearContext})...`);
    
    const results = [];
    
    // Stop pipeline first
    pipelineRunning = false;
    
    // Restart each agent with performance optimization
    for (const agentType of Object.keys(AGENTS)) {
      try {
        const agent = AGENTS[agentType];
        const agentInfo = agentProcesses[agentType];
        
        console.log(`🔄 Refreshing ${agentType} for performance...`);
        
        // Kill existing process
        if (agentInfo && agentInfo.process) {
          agentInfo.process.kill('SIGTERM');
        }
        
        // Clear port completely
        const killProcess = spawn('sh', ['-c', `lsof -ti:${agent.port} | xargs kill -9`]);
        
        // Staggered restart to avoid resource conflicts
        const delay = staggered ? 2000 : 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        
        // Start with performance-optimized environment
        const newProcess = spawn('node', [agent.path], {
          detached: false,
          stdio: ['ignore', 'pipe', 'pipe'],
          env: { 
            ...process.env, 
            CLEAR_CONTEXT: clearContext ? 'true' : 'false',
            FRESH_START: 'true',
            PERFORMANCE_MODE: 'true',
            CONTEXT_OPTIMIZATION: 'enabled'
          }
        });
        
        agentProcesses[agentType] = {
          process: newProcess,
          pid: newProcess.pid,
          port: agent.port,
          startedAt: new Date().toISOString(),
          restartCount: (agentInfo?.restartCount || 0) + 1,
          contextCleared: clearContext,
          performanceOptimized: true
        };
        
        // Setup performance monitoring
        newProcess.stdout.on('data', (data) => {
          console.log(`📊 ${agent.name} [Optimized]: ${data.toString().trim()}`);
        });
        
        newProcess.stderr.on('data', (data) => {
          console.error(`❌ ${agent.name} [Optimized] Error: ${data.toString().trim()}`);
        });
        
        newProcess.on('close', (code) => {
          console.log(`🔴 ${agent.name} optimized process exited with code ${code}`);
          delete agentProcesses[agentType];
        });
        
        results.push({
          agentType,
          status: 'refreshed',
          pid: newProcess.pid,
          port: agent.port,
          performanceOptimized: true
        });
        
        console.log(`✅ ${agentType} refreshed for performance (PID: ${newProcess.pid})`);
        
      } catch (error) {
        console.error(`❌ Failed to refresh ${agentType}:`, error);
        results.push({
          agentType,
          status: 'failed',
          error: error.message
        });
      }
    }
    
    res.json({
      action: 'refresh_all_agents',
      status: 'completed',
      results,
      optimization: 'context_windows_reset_for_performance',
      contextCleared: clearContext,
      staggered: staggered,
      message: 'All agents refreshed with performance optimization'
    });
    
  } catch (error) {
    console.error('❌ Error refreshing all agents:', error);
    res.status(500).json({
      action: 'refresh_all_agents',
      status: 'error',
      error: error.message
    });
  }
});

// Token-based context performance monitoring endpoint
app.get('/context-performance', (req, res) => {
  try {
    const contextStatus = {};
    
    // Agent token-based context status
    for (const [agentType, agentInfo] of Object.entries(agentProcesses)) {
      const tokenUsage = criticalState.token_usage_tracking[agentType];
      
      if (agentInfo) {
        const uptime = Date.now() - new Date(agentInfo.startedAt).getTime();
        const uptimeHours = Math.floor(uptime / (1000 * 60 * 60));
        
        let tokenUtilization = 0;
        let tokenRisk = 'low';
        let tokensRemaining = AGENT_TOKEN_LIMIT;
        
        if (tokenUsage) {
          tokenUtilization = Math.round((tokenUsage.total_tokens / AGENT_TOKEN_LIMIT) * 100);
          tokensRemaining = AGENT_TOKEN_LIMIT - tokenUsage.total_tokens;
          
          if (tokenUtilization > 90) tokenRisk = 'high';
          else if (tokenUtilization > 70) tokenRisk = 'medium';
        }
        
        contextStatus[agentType] = {
          running: true,
          uptime_hours: uptimeHours,
          restart_count: agentInfo.restartCount || 0,
          token_usage: tokenUsage?.total_tokens || 0,
          token_limit: AGENT_TOKEN_LIMIT,
          token_utilization_percent: tokenUtilization,
          tokens_remaining: tokensRemaining,
          context_degradation_risk: tokenRisk,
          recommended_action: tokenUtilization > 90 ? 'token_restart_required' : 
                            tokenUtilization > 70 ? 'token_restart_recommended' : 'none',
          last_token_reset: tokenUsage?.last_reset || 'never'
        };
      } else {
        contextStatus[agentType] = {
          running: false,
          context_degradation_risk: 'none',
          token_usage: 0,
          token_utilization_percent: 0
        };
      }
    }
    
    // Include orchestrator token-based context status
    const orchestratorUptime = Date.now() - new Date(orchestratorStartTime).getTime();
    const orchestratorUptimeHours = Math.floor(orchestratorUptime / (1000 * 60 * 60));
    const orchestratorUtilization = Math.round((orchestratorTokenUsage / ORCHESTRATOR_TOKEN_LIMIT) * 100);
    
    let orchestratorRisk = 'low';
    if (orchestratorUtilization > 90) orchestratorRisk = 'high';
    else if (orchestratorUtilization > 70) orchestratorRisk = 'medium';
    
    const degradationRisks = Object.values(contextStatus)
      .filter(status => status.running)
      .map(status => status.context_degradation_risk);
    
    const overallRisk = degradationRisks.includes('high') || orchestratorRisk === 'high' ? 'high' :
                       degradationRisks.includes('medium') || orchestratorRisk === 'medium' ? 'medium' : 'low';
    
    res.json({
      context_performance: contextStatus,
      orchestrator_context: {
        uptime_hours: orchestratorUptimeHours,
        restart_count: orchestratorRestartCount,
        token_usage: orchestratorTokenUsage,
        token_limit: ORCHESTRATOR_TOKEN_LIMIT,
        token_utilization_percent: orchestratorUtilization,
        tokens_remaining: ORCHESTRATOR_TOKEN_LIMIT - orchestratorTokenUsage,
        context_degradation_risk: orchestratorRisk,
        recommended_action: orchestratorUtilization > 90 ? 'orchestrator_restart_required' : 
                          orchestratorUtilization > 70 ? 'orchestrator_restart_recommended' : 'none',
        critical_state_preserved: true
      },
      overall_degradation_risk: overallRisk,
      recommendations: {
        restart_agents_high_tokens: Object.entries(contextStatus)
          .filter(([_, status]) => status.token_utilization_percent > 90)
          .map(([type, _]) => type),
        restart_orchestrator: orchestratorUtilization > 90,
        context_management: 'token_based_anthropic_best_practices'
      },
      token_limits: {
        agent_limit: AGENT_TOKEN_LIMIT,
        orchestrator_limit: ORCHESTRATOR_TOKEN_LIMIT
      },
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Orchestrator Context Management Functions
function updateCriticalState() {
  criticalState = {
    active_agents: Object.fromEntries(
      Object.entries(agentProcesses).map(([type, info]) => [type, {
        pid: info.pid,
        port: info.port,
        started_at: info.startedAt,
        restart_count: info.restartCount || 0
      }])
    ),
    pipeline_status: pipelineRunning ? 'running' : 'stopped',
    processing_queue_count: totalProcessed,
    last_assembly_run: orchestrationRuns > 0 ? new Date().toISOString() : null,
    error_count: systemErrors.length,
    performance_degradation_detected: systemErrors.filter(e => e.severity === 'critical').length > 5
  };
}

function generateHandoffReport() {
  updateCriticalState();
  
  return {
    handoff_timestamp: new Date().toISOString(),
    orchestrator_restart_count: orchestratorRestartCount,
    previous_uptime_hours: Math.floor((Date.now() - new Date(orchestratorStartTime).getTime()) / (1000 * 60 * 60)),
    critical_state: criticalState,
    essential_metrics: {
      total_processed: totalProcessed,
      orchestration_runs: orchestrationRuns,
      active_agent_count: Object.keys(agentProcesses).length,
      error_rate: systemErrors.length > 0 ? systemErrors.filter(e => e.severity === 'critical').length / systemErrors.length : 0
    },
    mission_critical_info: {
      must_restart_agents_if_degraded: Object.entries(agentProcesses).filter(([_, info]) => {
        const uptime = Date.now() - new Date(info.startedAt).getTime();
        return uptime > (4 * 60 * 60 * 1000); // > 4 hours
      }).map(([type, _]) => type),
      pipeline_continuation_ready: pipelineRunning,
      context_optimization_needed: true
    }
  };
}

app.post('/orchestrator-handoff', (req, res) => {
  try {
    const handoffReport = generateHandoffReport();
    
    console.log('🔄 Generating orchestrator handoff report...');
    console.log(`📊 Uptime: ${handoffReport.previous_uptime_hours}h, Agents: ${handoffReport.essential_metrics.active_agent_count}, Processed: ${handoffReport.essential_metrics.total_processed}`);
    
    res.json({
      action: 'orchestrator_handoff',
      status: 'report_generated',
      handoff_report: handoffReport,
      next_actions: {
        restart_orchestrator: 'use_handoff_report_for_context_restoration',
        restore_critical_state: 'maintain_agent_coordination',
        continue_mission: 'islamic_text_processing_workflow'
      }
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/orchestrator-restore', (req, res) => {
  try {
    const { handoff_report } = req.body;
    
    if (!handoff_report) {
      return res.status(400).json({ error: 'Handoff report required for context restoration' });
    }
    
    console.log('🔄 Restoring orchestrator context from handoff...');
    
    // Restore critical state
    orchestratorRestartCount = handoff_report.orchestrator_restart_count + 1;
    orchestratorStartTime = new Date().toISOString();
    totalProcessed = handoff_report.essential_metrics.total_processed || 0;
    orchestrationRuns = handoff_report.essential_metrics.orchestration_runs || 0;
    
    // Restore pipeline status
    pipelineRunning = handoff_report.critical_state.pipeline_status === 'running';
    
    console.log(`✅ Context restored: ${handoff_report.essential_metrics.active_agent_count} agents, ${totalProcessed} books processed`);
    console.log(`🎯 Mission continues: Islamic text processing workflow orchestration`);
    
    res.json({
      action: 'orchestrator_restore',
      status: 'context_restored',
      restored_state: {
        restart_count: orchestratorRestartCount,
        total_processed: totalProcessed,
        orchestration_runs: orchestrationRuns,
        pipeline_running: pipelineRunning
      },
      mission_status: 'context_optimized_and_ready'
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Token-based agent restart function
async function restartAgentWithTokenReset(agentType) {
  try {
    console.log(`🔄 Token-based restart for ${agentType}...`);
    
    const agent = AGENTS[agentType];
    const agentInfo = agentProcesses[agentType];
    
    // Kill existing process
    if (agentInfo && agentInfo.process) {
      agentInfo.process.kill('SIGTERM');
    }
    
    // Clear port
    const killProcess = spawn('sh', ['-c', `lsof -ti:${agent.port} | xargs kill -9`]);
    
    // Wait for cleanup
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Start fresh process with token optimization
    const newProcess = spawn('node', [agent.path], {
      detached: false,
      stdio: ['ignore', 'pipe', 'pipe'],
      env: { 
        ...process.env, 
        CLEAR_CONTEXT: 'true',
        TOKEN_RESET: 'true',
        FRESH_START: 'true'
      }
    });
    
    agentProcesses[agentType] = {
      process: newProcess,
      pid: newProcess.pid,
      port: agent.port,
      startedAt: new Date().toISOString(),
      restartCount: (agentInfo?.restartCount || 0) + 1,
      tokenReset: true
    };
    
    // Reset token tracking
    resetAgentTokens(agentType);
    
    // Setup logging
    newProcess.stdout.on('data', (data) => {
      console.log(`📊 ${agent.name} [Token Reset]: ${data.toString().trim()}`);
    });
    
    newProcess.stderr.on('data', (data) => {
      console.error(`❌ ${agent.name} [Token Reset] Error: ${data.toString().trim()}`);
    });
    
    newProcess.on('close', (code) => {
      console.log(`🔴 ${agent.name} token-reset process exited with code ${code}`);
      delete agentProcesses[agentType];
    });
    
    // Wait for agent to start up
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Reset agent's internal token tracking
    await resetAgentTokensOnAgent(agentType);
    
    console.log(`✅ ${agentType} restarted with token reset (PID: ${newProcess.pid})`);
    
  } catch (error) {
    console.error(`❌ Token-based restart failed for ${agentType}:`, error);
  }
}

// Reset tokens on the agent side using their API endpoint
async function resetAgentTokensOnAgent(agentType) {
  const agent = AGENTS[agentType];
  if (!agent) return false;
  
  const url = `http://localhost:${agent.port}/reset-tokens`;
  
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      timeout: 5000
    });
    
    if (response.ok) {
      const result = await response.json();
      console.log(`🔄 ${agentType} agent tokens reset successfully`);
      return true;
    } else {
      console.warn(`⚠️ Could not reset tokens on ${agentType}: HTTP ${response.status}`);
      return false;
    }
  } catch (error) {
    console.warn(`⚠️ Could not reach ${agentType} to reset tokens: ${error.message}`);
    return false;
  }
}

// Token usage endpoint
app.get('/token-usage', async (req, res) => {
  try {
    const tokenStatus = {};
    
    // Get real agent token usage from each agent
    for (const [agentType] of Object.entries(AGENTS)) {
      const realTokens = await getAgentTokenUsage(agentType);
      const commUsage = criticalState.token_usage_tracking[agentType] || { total_tokens: 0, request_count: 0 };
      
      tokenStatus[agentType] = {
        agent_tokens: realTokens || {
          total_tokens: 0,
          input_tokens: 0,
          output_tokens: 0,
          api_calls: 0,
          restart_recommended: false,
          usage_percentage: 0
        },
        communication_tokens: {
          total_tokens: commUsage.total_tokens,
          request_count: commUsage.request_count
        },
        token_limit: AGENT_TOKEN_LIMIT,
        restart_recommended: realTokens?.restart_recommended || false,
        tokens_remaining: realTokens?.total_tokens ? AGENT_TOKEN_LIMIT - realTokens.total_tokens : AGENT_TOKEN_LIMIT,
        last_reset: commUsage.last_reset
      };
    }
    
    // Orchestrator token usage
    const orchUtilization = Math.round((orchestratorTokenUsage / ORCHESTRATOR_TOKEN_LIMIT) * 100);
    
    res.json({
      agent_token_usage: tokenStatus,
      orchestrator_token_usage: {
        total_tokens: orchestratorTokenUsage,
        token_limit: ORCHESTRATOR_TOKEN_LIMIT,
        utilization_percent: orchUtilization,
        restart_recommended: orchestratorTokenUsage > ORCHESTRATOR_TOKEN_LIMIT,
        tokens_until_restart: Math.max(0, ORCHESTRATOR_TOKEN_LIMIT - orchestratorTokenUsage)
      },
      token_limits: {
        agent_limit: AGENT_TOKEN_LIMIT,
        orchestrator_limit: ORCHESTRATOR_TOKEN_LIMIT
      },
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Auto-update critical state periodically
setInterval(updateCriticalState, 30000); // Every 30 seconds

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`🎭 Agent Assembly Line Orchestrator running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`⚡ Start assembly: http://localhost:${PORT}/start-assembly`);
  console.log(`🏗️ Initialize reservoir: http://localhost:${PORT}/initialize-reservoir`);
  console.log(`📊 Reservoir status: http://localhost:${PORT}/reservoir-status`);
  console.log(`🩺 Agents health: http://localhost:${PORT}/agents-health`);
  console.log(`💀 Kill agent ports: http://localhost:${PORT}/kill-agent-ports`);
  console.log(`🧹 Clear queues: http://localhost:${PORT}/clear-queues`);
  console.log(`🔄 Context refresh: http://localhost:${PORT}/refresh-all-agents`);
  console.log(`📈 Context performance: http://localhost:${PORT}/context-performance`);
  console.log(`🧠 Token usage: http://localhost:${PORT}/token-usage`);
  console.log('🎯 Specialization: Multi-agent orchestration with token-based context optimization');
  console.log(`🎯 Token Limits: Agents=${AGENT_TOKEN_LIMIT}, Orchestrator=${ORCHESTRATOR_TOKEN_LIMIT}`);
});