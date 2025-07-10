/**
 * Token Tracking Middleware for Anthropic Claude API
 * Implements proper token tracking using Anthropic's Messages API usage response data
 * Based on Anthropic's official documentation
 * Extended for Claude Code CLI integration
 */

class TokenTracker {
  constructor(agentName) {
    this.agentName = agentName;
    this.tokenUsage = {
      input_tokens: 0,
      output_tokens: 0,
      total_tokens: 0,
      api_calls: 0,
      last_reset: new Date().toISOString()
    };
    this.TOKEN_LIMIT = 100000; // 100K token restart threshold
  }

  /**
   * Track tokens from Anthropic's Messages API response
   * @param {Object} apiResponse - The response from Anthropic's Messages API
   * @param {Object} apiResponse.usage - The usage object from the API response
   * @param {number} apiResponse.usage.input_tokens - Exact input tokens from API
   * @param {number} apiResponse.usage.output_tokens - Exact output tokens from API
   */
  trackTokensFromApiResponse(apiResponse) {
    if (!apiResponse || !apiResponse.usage) {
      console.warn(`⚠️ ${this.agentName}: No usage data in API response`);
      return this.tokenUsage;
    }

    const { input_tokens, output_tokens } = apiResponse.usage;
    
    // Update cumulative tracking
    this.tokenUsage.input_tokens += input_tokens;
    this.tokenUsage.output_tokens += output_tokens;
    this.tokenUsage.total_tokens = this.tokenUsage.input_tokens + this.tokenUsage.output_tokens;
    this.tokenUsage.api_calls += 1;

    console.log(`🧠 ${this.agentName} tokens: +${input_tokens}/${output_tokens} (total: ${this.tokenUsage.total_tokens}/${this.TOKEN_LIMIT})`);
    
    // Check if restart is needed
    if (this.tokenUsage.total_tokens > this.TOKEN_LIMIT) {
      console.warn(`⚠️ ${this.agentName} exceeded token limit: ${this.tokenUsage.total_tokens}/${this.TOKEN_LIMIT} - restart recommended`);
    }

    return this.tokenUsage;
  }

  /**
   * Add tokens manually (for Claude Code CLI integration)
   * @param {number} inputTokens - Input tokens used
   * @param {number} outputTokens - Output tokens used
   */
  addTokens(inputTokens = 0, outputTokens = 0) {
    this.tokenUsage.input_tokens += inputTokens;
    this.tokenUsage.output_tokens += outputTokens;
    this.tokenUsage.total_tokens = this.tokenUsage.input_tokens + this.tokenUsage.output_tokens;
    this.tokenUsage.api_calls += 1;

    console.log(`🧠 ${this.agentName} tokens: +${inputTokens}/${outputTokens} (total: ${this.tokenUsage.total_tokens}/${this.TOKEN_LIMIT})`);
    
    // Check if restart is needed
    if (this.tokenUsage.total_tokens > this.TOKEN_LIMIT) {
      console.warn(`⚠️ ${this.agentName} exceeded token limit: ${this.tokenUsage.total_tokens}/${this.TOKEN_LIMIT} - restart recommended`);
    }

    return this.tokenUsage;
  }

  /**
   * Wrapper for Anthropic Messages API calls with automatic token tracking
   * @param {Function} apiCall - Function that makes the API call
   * @param {Object} params - Parameters for the API call
   * @returns {Object} - API response with token tracking applied
   */
  async trackApiCall(apiCall, params) {
    try {
      const response = await apiCall(params);
      
      // Track tokens from the response
      this.trackTokensFromApiResponse(response);
      
      return response;
    } catch (error) {
      console.error(`❌ ${this.agentName}: API call failed:`, error.message);
      throw error;
    }
  }

  /**
   * Get current token usage statistics
   * @returns {Object} Current token usage data
   */
  getTokenUsage() {
    return {
      agent: this.agentName,
      ...this.tokenUsage,
      restart_recommended: this.tokenUsage.total_tokens > this.TOKEN_LIMIT,
      usage_percentage: Math.round((this.tokenUsage.total_tokens / this.TOKEN_LIMIT) * 100)
    };
  }

  /**
   * Reset token tracking (for agent restarts)
   */
  resetTokens() {
    const previousUsage = this.tokenUsage.total_tokens;
    this.tokenUsage = {
      input_tokens: 0,
      output_tokens: 0,
      total_tokens: 0,
      api_calls: 0,
      last_reset: new Date().toISOString()
    };
    console.log(`🔄 ${this.agentName} token usage reset (was: ${previousUsage} tokens)`);
  }

  /**
   * Check if agent needs to restart based on token usage
   * @returns {boolean} True if restart is recommended
   */
  shouldRestart() {
    return this.tokenUsage.total_tokens > this.TOKEN_LIMIT;
  }

  /**
   * Get tokens remaining before restart
   * @returns {number} Tokens remaining
   */
  getTokensRemaining() {
    return Math.max(0, this.TOKEN_LIMIT - this.tokenUsage.total_tokens);
  }
}

module.exports = TokenTracker;