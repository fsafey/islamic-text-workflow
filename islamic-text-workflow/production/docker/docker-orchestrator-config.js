// FIXED: Docker-Orchestrator Port Mapping Configuration
// Resolves port conflicts between containerized and native agents

module.exports = {
  // Docker container agents (running in containers)
  containerized_agents: {
    flowchart: {
      port: 3001,
      url: 'http://localhost:3001',
      type: 'containerized',
      agent_name: 'flowchart_mapper'
    }
  },
  
  // Native agents (running as Node processes) - use different ports to avoid conflicts
  native_agents: {
    network: {
      port: 3012,  // FIXED: Changed from 3002 to avoid conflict
      agent_name: 'network_mapper'
    },
    metadata: {
      port: 3013,  // FIXED: Changed from 3003 to avoid conflict
      agent_name: 'metadata_hunter'
    },
    synthesis: {
      port: 3014,  // FIXED: Changed from 3004 to avoid conflict
      agent_name: 'content_synthesizer'
    },
    pipeline: {
      port: 3015,  // FIXED: Changed from 3005 to avoid conflict
      agent_name: 'data_pipeline'
    }
  },
  
  // Processing workflow configuration
  processing_order: ['flowchart', 'network', 'metadata', 'synthesis', 'pipeline'],
  
  // Hybrid mode: Use containerized Flowchart Mapper + native other agents
  hybrid_mode: true,
  
  // Agent communication settings
  agent_timeout: 30000,
  max_retries: 3,
  
  // Environment detection
  detect_containerized_agents: () => {
    const http = require('http');
    const agents = {};
    
    // Check if containerized agents are running
    const checkAgent = (name, port) => {
      return new Promise((resolve) => {
        const req = http.get(`http://localhost:${port}/health`, (res) => {
          agents[name] = { available: true, port, type: 'containerized' };
          resolve(true);
        });
        
        req.on('error', () => {
          agents[name] = { available: false, port, type: 'containerized' };
          resolve(false);
        });
        
        req.setTimeout(1000, () => {
          agents[name] = { available: false, port, type: 'containerized' };
          req.destroy();
          resolve(false);
        });
      });
    };
    
    return Promise.all([
      checkAgent('flowchart', 3001),
      checkAgent('network', 3002),
      checkAgent('metadata', 3003),
      checkAgent('synthesis', 3004),
      checkAgent('pipeline', 3005)
    ]).then(() => agents);
  }
};