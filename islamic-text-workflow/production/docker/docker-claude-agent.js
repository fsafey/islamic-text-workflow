/**
 * Docker Claude Code Agent Wrapper
 * Integrates Claude Code CLI with existing orchestration infrastructure
 * Maintains compatibility with existing agent APIs while providing LLM capabilities
 */

const express = require('express');
const { spawn } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(require('child_process').exec);
const path = require('path');
const fs = require('fs');

// Import existing TokenTracker (maintains compatibility)
const TokenTracker = require('./lib/TokenTracker');

class DockerClaudeAgent {
  constructor() {
    // Environment configuration
    this.agentName = process.env.AGENT_NAME || 'claude_agent';
    this.port = parseInt(process.env.AGENT_PORT) || 3001;
    this.containerName = process.env.HOSTNAME || 'claude-agent';
    
    // System prompt will be loaded lazily when needed
    this.systemPrompt = null;
    
    // Initialize token tracker (reuse existing infrastructure)
    this.tokenTracker = new TokenTracker(this.agentName);
    
    // Agent state
    this.isHealthy = true;
    this.processedTasks = 0;
    this.errors = 0;
    this.lastActivity = new Date().toISOString();
    this.sessionId = null;
    
    console.log(`🤖 ${this.agentName}: Docker Claude Agent initialized on port ${this.port}`);
    console.log(`📝 System Prompt: Will be loaded dynamically from configuration`);
    
    this.setupExpress();
    this.setupErrorHandlers();  // FIXED: Add error handlers to prevent restarts
    this.setupGracefulShutdown();
  }

  loadSystemPromptFromConfig() {
    try {
      const claudeConfigPath = '/home/claude/.claude.json';
      console.log(`🔍 ${this.agentName}: Checking for Claude config at ${claudeConfigPath}`);
      
      if (fs.existsSync(claudeConfigPath)) {
        console.log(`✅ ${this.agentName}: Claude config file found, reading...`);
        const config = JSON.parse(fs.readFileSync(claudeConfigPath, 'utf8'));
        const projectConfig = config.projects && config.projects['/app'];
        
        if (projectConfig && projectConfig.context && projectConfig.context.system_prompt) {
          console.log(`🎯 ${this.agentName}: Loaded system prompt from config: ${projectConfig.context.system_prompt.substring(0, 80)}...`);
          return projectConfig.context.system_prompt;
        } else {
          console.log(`⚠️ ${this.agentName}: Config file found but no system prompt in expected location`);
        }
      } else {
        console.log(`❌ ${this.agentName}: Claude config file not found at ${claudeConfigPath}`);
      }
    } catch (error) {
      console.warn(`⚠️ ${this.agentName}: Could not load system prompt from config:`, error.message);
    }
    
    // Fallback to environment or default
    console.log(`🔄 ${this.agentName}: Using fallback system prompt`);
    return process.env.SYSTEM_PROMPT || 'You are a helpful assistant specializing in Islamic text analysis.';
  }

  setupExpress() {
    this.app = express();
    this.app.use(express.json({ limit: '10mb' }));
    
    // Add request logging
    this.app.use((req, res, next) => {
      console.log(`📥 ${this.agentName}: ${req.method} ${req.path} from ${req.ip}`);
      next();
    });

    // Health check endpoint (maintains existing API)
    this.app.get('/health', (req, res) => {
      res.json(this.getHealthStatus());
    });

    // Process task endpoint (maintains existing API)
    this.app.post('/process', async (req, res) => {
      try {
        const { prompt, context = {} } = req.body;
        
        if (!prompt) {
          return res.status(400).json({ error: 'Prompt is required' });
        }

        console.log(`🧠 ${this.agentName}: Processing task...`);
        const result = await this.executeClaudeTask(prompt, context);
        
        res.json({
          success: true,
          agent: this.agentName,
          processed_at: new Date().toISOString(),
          ...result
        });
        
      } catch (error) {
        console.error(`❌ ${this.agentName}: Process error:`, error.message);
        this.errors++;
        this.isHealthy = false;
        
        res.status(500).json({ 
          success: false,
          error: error.message,
          agent: this.agentName,
          timestamp: new Date().toISOString()
        });
      }
    });

    // Token usage endpoint (maintains existing API)
    this.app.get('/agent-tokens', (req, res) => {
      res.json(this.getTokenUsage());
    });

    // Reset endpoint for orchestrator restarts
    this.app.post('/reset', (req, res) => {
      this.reset();
      res.json({ 
        success: true, 
        message: `${this.agentName} reset successfully`,
        timestamp: new Date().toISOString()
      });
    });

    // Session management endpoint
    this.app.get('/session', (req, res) => {
      res.json({
        session_id: this.sessionId,
        agent: this.agentName,
        active_since: this.lastActivity
      });
    });

    // Debug endpoint for authentication testing
    this.app.get('/debug', async (req, res) => {
      try {
        console.log(`🔍 ${this.agentName}: Debug endpoint called`);
        
        const debugInfo = {
          agent: this.agentName,
          timestamp: new Date().toISOString(),
          environment: {
            CLAUDE_HOME: process.env.CLAUDE_HOME,
            HOME: process.env.HOME,
            CI: process.env.CI,
            TERM: process.env.TERM
          },
          files: {}
        };

        // Check Claude configuration file
        const claudeConfigPath = '/home/claude/.claude.json';
        if (fs.existsSync(claudeConfigPath)) {
          try {
            const config = JSON.parse(fs.readFileSync(claudeConfigPath, 'utf8'));
            debugInfo.files.claude_config = {
              exists: true,
              size: fs.statSync(claudeConfigPath).size,
              has_userid: !!config.userID,
              has_projects: !!config.projects,
              project_app_exists: !!(config.projects && config.projects['/app']),
              permissions: fs.statSync(claudeConfigPath).mode.toString(8)
            };
            
            // Log project config for debugging
            if (config.projects && config.projects['/app']) {
              debugInfo.files.project_config = {
                allowed_tools: config.projects['/app'].allowedTools || [],
                disallowed_tools: config.projects['/app'].disallowedTools || [],
                context: config.projects['/app'].context || {}
              };
            }
          } catch (parseError) {
            debugInfo.files.claude_config = {
              exists: true,
              error: `Parse error: ${parseError.message}`
            };
          }
        } else {
          debugInfo.files.claude_config = { exists: false };
        }

        // Test Claude CLI auth status
        try {
          const authResult = await execAsync('claude auth status', {
            env: { 
              ...process.env,
              CLAUDE_HOME: '/home/claude/.claude',
              CI: 'true',
              TERM: 'dumb'
            }
          });
          
          debugInfo.claude_auth = {
            status: 'success',
            output: authResult.stdout,
            error: authResult.stderr
          };
        } catch (authError) {
          debugInfo.claude_auth = {
            status: 'failed',
            error: authError.message,
            code: authError.code,
            stdout: authError.stdout,
            stderr: authError.stderr
          };
        }

        // Test basic Claude CLI execution
        try {
          const testResult = await execAsync('claude --version', {
            env: { 
              ...process.env,
              CLAUDE_HOME: '/home/claude/.claude',
              CI: 'true',
              TERM: 'dumb'
            }
          });
          
          debugInfo.claude_version = {
            status: 'success',
            output: testResult.stdout,
            error: testResult.stderr
          };
        } catch (versionError) {
          debugInfo.claude_version = {
            status: 'failed',
            error: versionError.message,
            code: versionError.code,
            stdout: versionError.stdout,
            stderr: versionError.stderr
          };
        }

        res.json(debugInfo);
        
      } catch (error) {
        console.error(`❌ ${this.agentName}: Debug endpoint error:`, error.message);
        res.status(500).json({ 
          success: false,
          error: error.message,
          agent: this.agentName,
          timestamp: new Date().toISOString()
        });
      }
    });

    this.app.listen(this.port, () => {
      console.log(`🚀 ${this.agentName} listening on port ${this.port}`);
      console.log(`🔗 Health check: http://localhost:${this.port}/health`);
    });
  }

  async executeClaudeTask(prompt, context = {}) {
    try {
      console.log(`🧠 ${this.agentName}: Executing Claude Code CLI...`);
      
      // Build complete prompt with context
      const fullPrompt = this.buildPrompt(prompt, context);
      
      // Load system prompt dynamically if not already loaded
      if (!this.systemPrompt) {
        this.systemPrompt = this.loadSystemPromptFromConfig();
      }

      // Build Claude command arguments for containerized environment
      const claudeArgs = ['--dangerously-skip-permissions', '--print'];
      
      // Add continue flag if available from environment (claude-docker pattern)
      const continueFlag = process.env.CLAUDE_CONTINUE_FLAG;
      if (continueFlag) {
        claudeArgs.push(continueFlag);
      }
      
      // Add the prompt as direct input (claude-docker session pattern)
      claudeArgs.push(fullPrompt);

      console.log(`🔧 ${this.agentName}: Claude session-based execution (claude-docker pattern)`);

      // Execute Claude CLI using claude-docker session pattern - clean approach
      const child = spawn('claude', claudeArgs, {
        stdio: ['pipe', 'pipe', 'pipe'],
        env: { 
          ...process.env,
          // Claude-docker environment configuration
          CLAUDE_HOME: '/home/claude/.claude',
          CI: 'true',
          TERM: 'dumb'
        },
        cwd: '/workspace'
      });

      return new Promise((resolve, reject) => {
        let output = '';
        let error = '';
        
        child.stdout.on('data', (data) => {
          output += data;
          // Log partial output for debugging
          process.stdout.write('.');
        });
        
        child.stderr.on('data', (data) => {
          error += data;
          console.error(`🔍 Claude CLI stderr: ${data}`);
          // Log each line separately for better debugging
          data.toString().split('\n').filter(line => line.trim()).forEach(line => {
            console.error(`   >>> ${line.trim()}`);
          });
        });
        
        child.on('close', (code) => {
          console.log(`\n🏁 Claude CLI finished with exit code: ${code}`);
          console.log(`📝 Output length: ${output.length} characters`);
          console.log(`❌ Error length: ${error.length} characters`);
          
          if (error.length > 0) {
            console.error(`🔍 Full stderr output:\n${error}`);
          }
          
          if (code === 0) {
            try {
              // Claude-docker session pattern: output is direct Claude response
              let claudeResponse = output.trim();
              
              // Try to extract JSON from the response (Claude should return only JSON)
              let analysisContent;
              try {
                analysisContent = JSON.parse(claudeResponse);
              } catch (jsonError) {
                // If not pure JSON, try to extract JSON from markdown or mixed content
                const jsonMatch = claudeResponse.match(/\{[\s\S]*\}/);
                if (jsonMatch) {
                  analysisContent = JSON.parse(jsonMatch[0]);
                } else {
                  throw new Error('No valid JSON found in Claude response');
                }
              }
              
              // Update agent state
              this.lastActivity = new Date().toISOString();
              this.processedTasks++;
              this.isHealthy = true;
              
              console.log(`✅ Claude session completed successfully`);
              console.log(`📊 Response type: ${typeof analysisContent}`);
              
              resolve({
                content: analysisContent,
                session_based: true,
                agent: this.agentName,
                timestamp: this.lastActivity
              });
              
            } catch (parseError) {
              console.error(`❌ Claude response parse error:`, parseError.message);
              console.error(`Raw output (first 500 chars):`, output.substring(0, 500));
              console.error(`Raw output (last 500 chars):`, output.substring(Math.max(0, output.length - 500)));
              reject(new Error(`Claude response parse error: ${parseError.message}`));
            }
          } else {
            this.errors++;
            const errorMsg = error || `Claude CLI failed with code ${code}`;
            console.error(`❌ Claude CLI error:`, errorMsg);
            reject(new Error(errorMsg));
          }
        });

        child.on('error', (err) => {
          console.error(`❌ Process spawn error:`, err.message);
          reject(new Error(`Process spawn error: ${err.message}`));
        });

        // Timeout after 30 seconds for debugging
        setTimeout(() => {
          console.log(`⏰ ${this.agentName}: Claude CLI timeout after 30 seconds`);
          child.kill('SIGKILL');
          reject(new Error('Claude CLI timeout after 30 seconds'));
        }, 30000);
      });

    } catch (error) {
      console.error(`❌ ${this.agentName}: Execution error:`, error.message);
      throw error;
    }
  }

  buildPrompt(userPrompt, context) {
    // Build complete prompt with system instructions (claude-docker session pattern)
    let prompt = `You are an expert Islamic scholar and digital humanities specialist. Your expertise includes:

- Classical Islamic text analysis and scholarly methodologies
- Hadith sciences, Quranic exegesis (tafsir), Islamic jurisprudence (fiqh)
- Digital library cataloging and metadata standards
- JSON data structure generation for database systems
- Cultural sensitivity in Islamic academic contexts

Your mission is to provide accurate, scholarly, and culturally sensitive analysis of Islamic texts for digital library enhancement.

TASK: ${userPrompt}

`;
    
    // Add book context if provided
    if (context.book_data) {
      prompt += `📚 Book Details:\n`;
      prompt += `Title: ${context.book_data.title}\n`;
      prompt += `Author: ${context.book_data.author}\n`;
      if (context.book_data.arabic_title) prompt += `Arabic Title: ${context.book_data.arabic_title}\n`;
      if (context.book_data.description) prompt += `Description: ${context.book_data.description}\n`;
      if (context.book_data.subject_areas) prompt += `Subject Areas: ${context.book_data.subject_areas.join(', ')}\n`;
      prompt += `\n`;
    }
    
    // Add agent-specific instructions
    prompt += `🤖 Agent Specialization: ${this.agentName}\n`;
    prompt += `📋 Output Requirements: Return ONLY valid JSON data suitable for database storage.\n`;
    prompt += `🕌 Standards: Maintain Islamic scholarly accuracy and cultural sensitivity.\n`;
    
    // Add specific field requirements based on agent type
    if (this.agentName.includes('flowchart')) {
      prompt += `\n📊 Required JSON Structure:
{
  "flowchart_analysis": {
    "conceptual_architecture": "...",
    "content_flow_design": "...",
    "reader_journey_structure": "..."
  },
  "conceptual_architecture": "...",
  "content_flow_design": "..."
}\n`;
    } else if (this.agentName.includes('network')) {
      prompt += `\n🕸️ Required JSON Structure:
{
  "network_analysis": {
    "scholar_connections": "...",
    "concept_relationships": "...",
    "influence_patterns": "..."
  }
}\n`;
    } else if (this.agentName.includes('metadata')) {
      prompt += `\n🔍 Required JSON Structure:
{
  "metadata_findings": {
    "arabic_title_research": "...",
    "author_research": "...",
    "publication_research": "...",
    "scholarly_classification": "..."
  }
}\n`;
    } else if (this.agentName.includes('synthesis')) {
      prompt += `\n⚗️ Required JSON Structure:
{
  "synthesis_results": {
    "combined_analysis": "...",
    "categorization": "...",
    "keywords": [...],
    "description": "...",
    "quality_assessment": "..."
  }
}\n`;
    } else if (this.agentName.includes('pipeline')) {
      prompt += `\n🔄 Required JSON Structure:
{
  "pipeline_results": {
    "database_updates": "...",
    "processing_status": "...",
    "next_steps": "...",
    "validation_results": "..."
  }
}\n`;
    }
    
    prompt += `\nReturn ONLY the JSON object, no additional text or formatting.\n`;
    
    return prompt;
  }

  trackTokenUsage(result) {
    if (result.usage) {
      this.tokenTracker.addTokens(
        result.usage.input_tokens || 0,
        result.usage.output_tokens || 0
      );
      
      // Check if restart is needed based on token usage
      if (this.tokenTracker.shouldRestart()) {
        console.log(`⚠️ ${this.agentName}: Token limit approaching, restart recommended`);
      }
    }
  }

  getHealthStatus() {
    const tokenUsage = this.tokenTracker.getTokenUsage();
    
    return {
      agent: this.agentName,
      container: this.containerName,
      port: this.port,
      status: this.isHealthy ? 'healthy' : 'error',
      processed: this.processedTasks,
      errors: this.errors,
      last_activity: this.lastActivity,
      session_id: this.sessionId,
      token_usage: tokenUsage,
      restart_recommended: tokenUsage.restart_recommended,
      usage_percentage: tokenUsage.usage_percentage,
      uptime_ms: Date.now() - new Date(this.lastActivity).getTime()
    };
  }

  getTokenUsage() {
    return {
      ...this.tokenTracker.getTokenUsage(),
      agent: this.agentName,
      session_id: this.sessionId,
      timestamp: new Date().toISOString()
    };
  }

  reset() {
    console.log(`🔄 ${this.agentName}: Resetting agent state`);
    this.tokenTracker.resetTokens();
    this.processedTasks = 0;
    this.errors = 0;
    this.isHealthy = true;
    this.lastActivity = new Date().toISOString();
    this.sessionId = null;
    
    console.log(`✅ ${this.agentName}: Agent state reset complete`);
  }

  // FIXED: Add comprehensive error handlers to prevent container restarts
  setupErrorHandlers() {
    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
      console.error(`❌ ${this.agentName}: Uncaught Exception:`, error.message);
      console.error('Stack:', error.stack);
      this.errors++;
      this.isHealthy = false;
      // Don't exit - log and continue
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason, promise) => {
      console.error(`❌ ${this.agentName}: Unhandled Rejection at:`, promise, 'reason:', reason);
      this.errors++;
      this.isHealthy = false;
      // Don't exit - log and continue
    });

    // Handle warnings
    process.on('warning', (warning) => {
      console.warn(`⚠️ ${this.agentName}: Warning:`, warning.name, warning.message);
    });

    console.log(`🛡️ ${this.agentName}: Error handlers installed to prevent restarts`);
  }

  setupGracefulShutdown() {
    // Handle graceful shutdown
    const shutdown = (signal) => {
      console.log(`\n🛑 ${this.agentName}: Received ${signal}, shutting down gracefully...`);
      
      // Log final stats
      const status = this.getHealthStatus();
      console.log(`📊 Final stats: ${status.processed} processed, ${status.errors} errors`);
      
      process.exit(0);
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));
  }
}

// Start the agent
new DockerClaudeAgent();