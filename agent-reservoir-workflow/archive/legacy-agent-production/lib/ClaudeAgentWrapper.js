/**
 * Claude Agent Wrapper - Integrates Anthropic Claude API with existing agent infrastructure
 * Replaces rule-based agents with actual LLM-powered agents while maintaining token tracking
 */

const Anthropic = require('@anthropic-ai/sdk');
const TokenTracker = require('./TokenTracker');

class ClaudeAgentWrapper {
  constructor(agentName, port, systemPrompt, anthropicApiKey = process.env.ANTHROPIC_API_KEY) {
    this.agentName = agentName;
    this.port = port;
    this.systemPrompt = systemPrompt;
    
    // Initialize Anthropic client
    this.anthropic = new Anthropic({
      apiKey: anthropicApiKey,
    });
    
    // Initialize token tracker (reuse existing infrastructure)
    this.tokenTracker = new TokenTracker(agentName);
    
    // Agent state
    this.isHealthy = true;
    this.processedBooks = 0;
    this.errors = 0;
    this.lastActivity = new Date().toISOString();
    
    console.log(`🤖 ${agentName}: Claude Agent initialized on port ${port}`);
  }

  /**
   * Process text using Claude API with automatic token tracking
   * @param {string} userPrompt - The user prompt for the agent
   * @param {Object} context - Additional context (book data, etc.)
   * @returns {Object} - Processed result with metadata
   */
  async processWithClaude(userPrompt, context = {}) {
    try {
      console.log(`🧠 ${this.agentName}: Processing with Claude API...`);
      
      const messages = [
        {
          role: "user",
          content: this.buildPrompt(userPrompt, context)
        }
      ];

      // Make API call with token tracking
      const response = await this.tokenTracker.trackApiCall(
        (params) => this.anthropic.messages.create(params),
        {
          model: "claude-3-5-sonnet-20241022",
          max_tokens: 4000,
          system: this.systemPrompt,
          messages: messages
        }
      );

      this.lastActivity = new Date().toISOString();
      this.processedBooks++;

      return {
        success: true,
        content: response.content[0].text,
        usage: response.usage,
        agent: this.agentName,
        processed_at: this.lastActivity,
        token_usage: this.tokenTracker.getTokenUsage()
      };

    } catch (error) {
      console.error(`❌ ${this.agentName}: Claude API error:`, error.message);
      this.errors++;
      this.isHealthy = false;
      
      throw new Error(`Claude API processing failed: ${error.message}`);
    }
  }

  /**
   * Build complete prompt with system context and user input
   * @param {string} userPrompt - Main prompt content
   * @param {Object} context - Additional context data
   * @returns {string} - Complete formatted prompt
   */
  buildPrompt(userPrompt, context) {
    let prompt = userPrompt;
    
    // Add context if provided
    if (context.book) {
      prompt += `\n\nBook Context:\n`;
      prompt += `Title: ${context.book.title}\n`;
      prompt += `Author: ${context.book.author_name || 'Unknown'}\n`;
      if (context.book.book_id) prompt += `Book ID: ${context.book.book_id}\n`;
    }
    
    // Add agent-specific instructions
    prompt += `\n\nAgent Role: ${this.agentName}`;
    prompt += `\nOutput Format: Return structured JSON data that can be stored in the database.`;
    
    return prompt;
  }

  /**
   * Health check endpoint data
   * @returns {Object} Health status with token usage
   */
  getHealthStatus() {
    const tokenUsage = this.tokenTracker.getTokenUsage();
    
    return {
      agent: this.agentName,
      port: this.port,
      status: this.isHealthy ? 'healthy' : 'error',
      processed: this.processedBooks,
      errors: this.errors,
      last_activity: this.lastActivity,
      token_usage: tokenUsage,
      restart_recommended: tokenUsage.restart_recommended,
      usage_percentage: tokenUsage.usage_percentage,
      tokens_remaining: this.tokenTracker.getTokensRemaining()
    };
  }

  /**
   * Reset agent state (for orchestrator restarts)
   */
  reset() {
    this.tokenTracker.resetTokens();
    this.processedBooks = 0;
    this.errors = 0;
    this.isHealthy = true;
    this.lastActivity = new Date().toISOString();
    
    console.log(`🔄 ${this.agentName}: Agent state reset`);
  }

  /**
   * Check if agent should restart based on token usage
   * @returns {boolean} True if restart needed
   */
  shouldRestart() {
    return this.tokenTracker.shouldRestart();
  }

  /**
   * Get current token usage for orchestrator monitoring
   * @returns {Object} Token usage statistics
   */
  getTokenUsage() {
    return this.tokenTracker.getTokenUsage();
  }
}

module.exports = ClaudeAgentWrapper;