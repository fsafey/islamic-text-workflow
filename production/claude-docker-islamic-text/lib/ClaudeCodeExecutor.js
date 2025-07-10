/**
 * Claude Code CLI Execution Helper
 * Provides Claude Code CLI integration for existing agents
 * Maintains compatibility with existing infrastructure
 */

const { spawn } = require('child_process');

class ClaudeCodeExecutor {
  constructor(agentName, tokenTracker) {
    this.agentName = agentName;
    this.tokenTracker = tokenTracker;
    this.sessionId = null;
  }

  /**
   * Execute Claude Code CLI with Islamic scholarship expertise
   * @param {string} prompt - The analysis prompt
   * @param {string} systemPrompt - Agent-specific system prompt  
   * @param {Object} context - Additional context (book data, etc.)
   * @returns {Object} - Claude Code response with structured data
   */
  async executeClaudeCode(prompt, systemPrompt, context = {}) {
    try {
      console.log(`🧠 ${this.agentName}: Executing Claude Code CLI...`);
      
      // Build complete prompt with context
      const fullPrompt = this.buildPrompt(prompt, context);
      
      // Build Claude command arguments
      const claudeArgs = [
        '-p', // Print mode (headless)
        '--output-format', 'json',
        '--system-prompt', systemPrompt,
        '--dangerously-skip-permissions',
        fullPrompt
      ];

      // Add session resumption if available
      if (this.sessionId && context.resume_session !== false) {
        claudeArgs.splice(-1, 0, '--resume', this.sessionId);
      }

      console.log(`🔧 ${this.agentName}: Claude CLI arguments prepared`);

      // Execute Claude Code CLI with environment variable workaround
      const child = spawn('claude', claudeArgs, {
        stdio: ['pipe', 'pipe', 'pipe'],
        env: { 
          ...process.env
          // ANTHROPIC_API_KEY removed - conflicts with claude-docker session-based authentication
        }
      });

      return new Promise((resolve, reject) => {
        let output = '';
        let error = '';
        
        child.stdout.on('data', (data) => {
          output += data;
          // Log progress for long-running operations
          process.stdout.write('.');
        });
        
        child.stderr.on('data', (data) => {
          error += data;
          if (error.includes('error') || error.includes('Error')) {
            console.error(`stderr: ${data}`);
          }
        });
        
        child.on('close', (code) => {
          console.log(`\n✅ ${this.agentName}: Claude CLI finished with code: ${code}`);
          
          if (code === 0) {
            try {
              const result = JSON.parse(output);
              
              // Track token usage using existing infrastructure
              this.tokenTracker.trackClaudeCodeResponse(result);
              
              // Update session ID for future requests
              if (result.session_id) {
                this.sessionId = result.session_id;
              }
              
              console.log(`📊 ${this.agentName}: Tokens used: ${result.usage?.input_tokens || 0} in, ${result.usage?.output_tokens || 0} out`);
              
              resolve({
                success: true,
                content: result.result,
                usage: result.usage,
                session_id: result.session_id,
                duration_ms: result.duration_ms,
                cost_usd: result.total_cost_usd,
                agent: this.agentName,
                timestamp: new Date().toISOString()
              });
              
            } catch (parseError) {
              console.error(`❌ ${this.agentName}: JSON parse error:`, parseError.message);
              console.error(`Raw output:`, output.substring(0, 500));
              reject(new Error(`JSON parse error: ${parseError.message}`));
            }
          } else {
            const errorMsg = error || `Claude CLI failed with code ${code}`;
            console.error(`❌ ${this.agentName}: Claude CLI error:`, errorMsg);
            reject(new Error(errorMsg));
          }
        });

        child.on('error', (err) => {
          console.error(`❌ ${this.agentName}: Process spawn error:`, err.message);
          reject(new Error(`Process spawn error: ${err.message}`));
        });

        // Timeout after 5 minutes (same as existing agents)
        setTimeout(() => {
          console.log(`⏰ ${this.agentName}: Claude CLI timeout`);
          child.kill('SIGKILL');
          reject(new Error('Claude CLI timeout after 5 minutes'));
        }, 300000);
      });

    } catch (error) {
      console.error(`❌ ${this.agentName}: Execution error:`, error.message);
      throw error;
    }
  }

  /**
   * Build complete prompt with context and formatting
   * @param {string} userPrompt - The main prompt
   * @param {Object} context - Additional context data
   * @returns {string} - Complete formatted prompt
   */
  buildPrompt(userPrompt, context) {
    let prompt = `${userPrompt}\n\n`;
    
    // Add book context if provided (maintain existing format)
    if (context.book || context.title) {
      prompt += `📚 Book Context:\n`;
      prompt += `Title: ${context.title || context.book?.title}\n`;
      prompt += `Author: ${context.author_name || context.book?.author_name || 'Unknown'}\n`;
      if (context.book_id || context.book?.book_id) {
        prompt += `Book ID: ${context.book_id || context.book?.book_id}\n`;
      }
      if (context.description || context.book?.description) {
        prompt += `Description: ${context.description || context.book?.description}\n`;
      }
      prompt += `\n`;
    }
    
    // Add agent-specific output requirements
    prompt += `🤖 Agent Role: ${this.agentName}\n`;
    prompt += `📋 Output Format: Return structured JSON data suitable for database storage.\n`;
    prompt += `🕌 Focus: Islamic text analysis with scholarly accuracy and cultural sensitivity.\n`;
    prompt += `🎯 Mission: Provide analysis that enhances Islamic digital library cataloging.\n`;
    
    return prompt;
  }

  /**
   * Get current session information
   * @returns {Object} Session data
   */
  getSessionInfo() {
    return {
      agent: this.agentName,
      session_id: this.sessionId,
      active: !!this.sessionId,
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Reset session state (for agent restarts)
   */
  resetSession() {
    this.sessionId = null;
    console.log(`🔄 ${this.agentName}: Session state reset`);
  }
}

module.exports = ClaudeCodeExecutor;