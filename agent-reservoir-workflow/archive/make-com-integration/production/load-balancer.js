#!/usr/bin/env node

// Load Balancer for Multiple Claude Desktop Bridge Instances
// Distributes requests across multiple bridge instances for parallel processing

import { createServer } from 'http';
import { createProxyServer } from 'http-proxy';

class LoadBalancer {
  constructor() {
    this.port = 3000; // Load balancer port
    this.instances = [
      'http://localhost:3002',
      'http://localhost:3003', 
      'http://localhost:3004'
    ];
    this.currentIndex = 0;
    this.proxy = createProxyServer({});
  }

  // Round-robin instance selection
  getNextInstance() {
    const instance = this.instances[this.currentIndex];
    this.currentIndex = (this.currentIndex + 1) % this.instances.length;
    return instance;
  }

  // Health check for instances
  async checkInstanceHealth(instance) {
    try {
      const response = await fetch(`${instance}/health`);
      return response.ok;
    } catch (error) {
      return false;
    }
  }

  // Get healthy instances
  async getHealthyInstances() {
    const healthChecks = await Promise.all(
      this.instances.map(async (instance) => ({
        instance,
        healthy: await this.checkInstanceHealth(instance)
      }))
    );
    
    return healthChecks
      .filter(check => check.healthy)
      .map(check => check.instance);
  }

  async start() {
    console.log('🔄 Starting Claude Desktop Load Balancer...');
    console.log(`📊 Target instances: ${this.instances.join(', ')}`);

    const server = createServer(async (req, res) => {
      // Enable CORS
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
      
      if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
      }

      // Health check endpoint
      if (req.url === '/health') {
        const healthyInstances = await this.getHealthyInstances();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          status: 'healthy',
          load_balancer: true,
          healthy_instances: healthyInstances.length,
          total_instances: this.instances.length,
          instances: this.instances
        }));
        return;
      }

      // Load balance requests
      try {
        const targetInstance = this.getNextInstance();
        console.log(`🔄 Routing ${req.method} ${req.url} → ${targetInstance}`);
        
        this.proxy.web(req, res, {
          target: targetInstance,
          changeOrigin: true
        });
      } catch (error) {
        console.error('❌ Load balancer error:', error);
        res.writeHead(502, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Load balancer failed' }));
      }
    });

    // Handle proxy errors
    this.proxy.on('error', (error, req, res) => {
      console.error('❌ Proxy error:', error.message);
      if (!res.headersSent) {
        res.writeHead(502, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Bridge instance unavailable' }));
      }
    });

    server.listen(this.port, () => {
      console.log(`✅ Load Balancer listening on port ${this.port}`);
      console.log(`🔗 Load Balancer URL: http://localhost:${this.port}`);
      console.log('📋 Endpoints:');
      console.log(`   GET  /health - Load balancer health`);
      console.log(`   POST /claude/hybrid-analysis - Distributed analysis`);
      console.log(`   POST /claude/enrichment-execution - Distributed enrichment`);
    });
  }
}

// Run load balancer
if (import.meta.url === `file://${process.argv[1]}`) {
  const balancer = new LoadBalancer();
  balancer.start().catch(error => {
    console.error('❌ Failed to start load balancer:', error);
    process.exit(1);
  });
}

export { LoadBalancer };