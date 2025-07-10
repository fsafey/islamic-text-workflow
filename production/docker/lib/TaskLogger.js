/**
 * TaskLogger - Implements claude-docker style task execution logging
 * 
 * Based on claude-docker patterns from:
 * https://github.com/VishalJ99/claude-docker
 * 
 * Features:
 * - Generates task_log.md documenting agent's execution process
 * - Stores assumptions, insights, and challenges encountered
 * - Acts as a simple summary to quickly understand what the agent accomplished
 */

const fs = require('fs');
const path = require('path');

class TaskLogger {
  constructor(agentName, sessionId = null) {
    this.agentName = agentName;
    this.sessionId = sessionId || `session_${Date.now()}`;
    this.taskId = `task_${Date.now()}`;
    this.startTime = new Date();
    
    // Task execution state
    this.assumptions = [];
    this.insights = [];
    this.challenges = [];
    this.actions = [];
    this.outputs = [];
    this.metrics = {
      books_processed: 0,
      claude_calls: 0,
      tokens_used: 0,
      errors_encountered: 0
    };
    
    // Initialize logging directories
    this.logDir = `/app/logs/${this.agentName}`;
    this.sessionDir = `${this.logDir}/${this.sessionId}`;
    this.ensureDirectories();
    
    console.log(`📝 TaskLogger initialized for ${agentName} - Session: ${this.sessionId}`);
  }
  
  /**
   * Ensure logging directories exist
   */
  ensureDirectories() {
    try {
      if (!fs.existsSync(this.logDir)) {
        fs.mkdirSync(this.logDir, { recursive: true });
      }
      if (!fs.existsSync(this.sessionDir)) {
        fs.mkdirSync(this.sessionDir, { recursive: true });
      }
    } catch (error) {
      console.warn(`⚠️ TaskLogger: Could not create directories: ${error.message}`);
    }
  }
  
  /**
   * Log an assumption made during task execution
   */
  logAssumption(assumption, reasoning = '') {
    const entry = {
      timestamp: new Date().toISOString(),
      assumption,
      reasoning,
      task_phase: this.getCurrentPhase()
    };
    
    this.assumptions.push(entry);
    console.log(`🤔 [${this.agentName}] Assumption: ${assumption}`);
  }
  
  /**
   * Log an insight discovered during task execution
   */
  logInsight(insight, context = '') {
    const entry = {
      timestamp: new Date().toISOString(),
      insight,
      context,
      task_phase: this.getCurrentPhase()
    };
    
    this.insights.push(entry);
    console.log(`💡 [${this.agentName}] Insight: ${insight}`);
  }
  
  /**
   * Log a challenge encountered during task execution
   */
  logChallenge(challenge, impact = '', solution = '') {
    const entry = {
      timestamp: new Date().toISOString(),
      challenge,
      impact,
      solution,
      task_phase: this.getCurrentPhase()
    };
    
    this.challenges.push(entry);
    console.log(`⚡ [${this.agentName}] Challenge: ${challenge}`);
  }
  
  /**
   * Log an action taken during task execution
   */
  logAction(action, details = '', result = '') {
    const entry = {
      timestamp: new Date().toISOString(),
      action,
      details,
      result,
      task_phase: this.getCurrentPhase()
    };
    
    this.actions.push(entry);
    console.log(`🔧 [${this.agentName}] Action: ${action}`);
  }
  
  /**
   * Log task output or result
   */
  logOutput(output, type = 'analysis', metadata = {}) {
    const entry = {
      timestamp: new Date().toISOString(),
      type,
      output,
      metadata,
      task_phase: this.getCurrentPhase()
    };
    
    this.outputs.push(entry);
    console.log(`📊 [${this.agentName}] Output (${type}): ${typeof output === 'string' ? output.substring(0, 100) : 'JSON object'}`);
  }
  
  /**
   * Update metrics
   */
  updateMetrics(metricName, value) {
    if (this.metrics.hasOwnProperty(metricName)) {
      this.metrics[metricName] += value;
    } else {
      this.metrics[metricName] = value;
    }
    
    console.log(`📈 [${this.agentName}] Metric updated: ${metricName} = ${this.metrics[metricName]}`);
  }
  
  /**
   * Get current task phase (simplified)
   */
  getCurrentPhase() {
    const phases = ['initialization', 'data_retrieval', 'analysis', 'synthesis', 'output'];
    const elapsed = Date.now() - this.startTime.getTime();
    
    // Simple phase determination based on elapsed time
    if (elapsed < 5000) return 'initialization';
    if (elapsed < 15000) return 'data_retrieval';
    if (elapsed < 60000) return 'analysis';
    if (elapsed < 90000) return 'synthesis';
    return 'output';
  }
  
  /**
   * Generate task_log.md file
   */
  generateTaskLog() {
    const endTime = new Date();
    const duration = endTime.getTime() - this.startTime.getTime();
    
    const logContent = this.buildTaskLogContent(endTime, duration);
    
    try {
      const logPath = path.join(this.sessionDir, 'task_log.md');
      fs.writeFileSync(logPath, logContent);
      
      console.log(`📝 [${this.agentName}] Task log generated: ${logPath}`);
      return logPath;
    } catch (error) {
      console.error(`❌ [${this.agentName}] Failed to generate task log: ${error.message}`);
      return null;
    }
  }
  
  /**
   * Build task log content in markdown format
   */
  buildTaskLogContent(endTime, duration) {
    const durationStr = this.formatDuration(duration);
    
    return `# 📋 Task Execution Log

**Agent**: ${this.agentName}
**Session ID**: ${this.sessionId}
**Task ID**: ${this.taskId}
**Started**: ${this.startTime.toISOString()}
**Completed**: ${endTime.toISOString()}
**Duration**: ${durationStr}

## 🎯 Task Summary

This log documents the execution process of the ${this.agentName} agent during Islamic text processing. The agent's mission is to enhance Islamic digital library cataloging through specialized analysis.

## 📊 Execution Metrics

- **Books Processed**: ${this.metrics.books_processed}
- **Claude API Calls**: ${this.metrics.claude_calls}
- **Tokens Used**: ${this.metrics.tokens_used}
- **Errors Encountered**: ${this.metrics.errors_encountered}

## 🤔 Assumptions Made

${this.assumptions.length > 0 ? this.assumptions.map(a => `
### ${a.task_phase.toUpperCase()} Phase
**Timestamp**: ${a.timestamp}
**Assumption**: ${a.assumption}
**Reasoning**: ${a.reasoning}
`).join('\n') : '_No assumptions logged during this session._'}

## 💡 Insights Discovered

${this.insights.length > 0 ? this.insights.map(i => `
### ${i.task_phase.toUpperCase()} Phase
**Timestamp**: ${i.timestamp}
**Insight**: ${i.insight}
**Context**: ${i.context}
`).join('\n') : '_No insights logged during this session._'}

## ⚡ Challenges Encountered

${this.challenges.length > 0 ? this.challenges.map(c => `
### ${c.task_phase.toUpperCase()} Phase
**Timestamp**: ${c.timestamp}
**Challenge**: ${c.challenge}
**Impact**: ${c.impact}
**Solution**: ${c.solution}
`).join('\n') : '_No challenges logged during this session._'}

## 🔧 Actions Taken

${this.actions.length > 0 ? this.actions.map(a => `
### ${a.task_phase.toUpperCase()} Phase
**Timestamp**: ${a.timestamp}
**Action**: ${a.action}
**Details**: ${a.details}
**Result**: ${a.result}
`).join('\n') : '_No actions logged during this session._'}

## 📊 Outputs Generated

${this.outputs.length > 0 ? this.outputs.map(o => `
### ${o.task_phase.toUpperCase()} Phase - ${o.type.toUpperCase()}
**Timestamp**: ${o.timestamp}
**Output**: ${typeof o.output === 'string' ? o.output.substring(0, 500) + (o.output.length > 500 ? '...' : '') : JSON.stringify(o.output, null, 2).substring(0, 500) + '...'}
**Metadata**: ${JSON.stringify(o.metadata)}
`).join('\n') : '_No outputs logged during this session._'}

## 🎯 What This Agent Accomplished

Based on the execution log above, the ${this.agentName} agent:

1. **Processed ${this.metrics.books_processed} Islamic text(s)** through specialized analysis
2. **Made ${this.metrics.claude_calls} Claude API calls** for LLM-powered insights
3. **Used ${this.metrics.tokens_used} tokens** for analysis processing
4. **Generated ${this.outputs.length} structured outputs** for Islamic library cataloging
5. **Encountered ${this.metrics.errors_encountered} errors** during processing

${this.insights.length > 0 ? `
### Key Insights from This Session:
${this.insights.map(i => `- ${i.insight}`).join('\n')}
` : ''}

${this.challenges.length > 0 ? `
### Main Challenges Resolved:
${this.challenges.map(c => `- ${c.challenge} (Solution: ${c.solution})`).join('\n')}
` : ''}

---

*This task log was automatically generated by the TaskLogger system based on claude-docker patterns for autonomous agent operation.*
`;
  }
  
  /**
   * Format duration in human-readable format
   */
  formatDuration(milliseconds) {
    const seconds = Math.floor(milliseconds / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    
    if (hours > 0) return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
    if (minutes > 0) return `${minutes}m ${seconds % 60}s`;
    return `${seconds}s`;
  }
  
  /**
   * Generate final summary and clean up
   */
  finalize() {
    const logPath = this.generateTaskLog();
    
    // Also generate a JSON summary for programmatic access
    const summaryPath = this.generateJSONSummary();
    
    console.log(`✅ [${this.agentName}] Task logging finalized:`);
    console.log(`   📄 Markdown log: ${logPath}`);
    console.log(`   📊 JSON summary: ${summaryPath}`);
    
    return { logPath, summaryPath };
  }
  
  /**
   * Generate JSON summary for programmatic access
   */
  generateJSONSummary() {
    const summary = {
      agent_name: this.agentName,
      session_id: this.sessionId,
      task_id: this.taskId,
      execution_time: {
        start: this.startTime.toISOString(),
        end: new Date().toISOString(),
        duration_ms: Date.now() - this.startTime.getTime()
      },
      metrics: this.metrics,
      execution_summary: {
        assumptions_count: this.assumptions.length,
        insights_count: this.insights.length,
        challenges_count: this.challenges.length,
        actions_count: this.actions.length,
        outputs_count: this.outputs.length
      },
      assumptions: this.assumptions,
      insights: this.insights,
      challenges: this.challenges,
      actions: this.actions,
      outputs: this.outputs
    };
    
    try {
      const summaryPath = path.join(this.sessionDir, 'task_summary.json');
      fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2));
      return summaryPath;
    } catch (error) {
      console.error(`❌ [${this.agentName}] Failed to generate JSON summary: ${error.message}`);
      return null;
    }
  }
}

module.exports = TaskLogger;