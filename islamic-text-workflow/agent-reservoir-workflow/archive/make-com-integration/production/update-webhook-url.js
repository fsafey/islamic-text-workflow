#!/usr/bin/env node

// Update Make.com Scenarios with Current ngrok URL
// Updates webhook URLs to point to current ngrok tunnel

import config from './config.js';

class WebhookUpdater {
  constructor() {
    this.apiToken = config.makeApi.token;
    this.organizationId = config.makeApi.organizationId;
    this.baseUrl = config.makeApi.baseUrl;
  }

  async getCurrentNgrokUrl() {
    try {
      const response = await fetch('http://localhost:4040/api/tunnels');
      const data = await response.json();
      // Get the first tunnel (should be our port 3002 tunnel)
      const tunnel = data.tunnels?.[0];
      return tunnel?.public_url;
    } catch (error) {
      console.error('❌ Failed to get ngrok URL:', error.message);
      return null;
    }
  }

  async getScenarioDetails(scenarioId) {
    const url = `${this.baseUrl}/scenarios/${scenarioId}`;
    
    try {
      const response = await fetch(url, {
        headers: {
          'Authorization': `Token ${this.apiToken}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.ok) {
        return await response.json();
      } else {
        console.error(`❌ Failed to get scenario ${scenarioId}:`, await response.text());
        return null;
      }
    } catch (error) {
      console.error(`❌ Error getting scenario ${scenarioId}:`, error.message);
      return null;
    }
  }

  async updateScenarioWebhook(scenarioId, webhookUrl) {
    console.log(`🔄 Updating scenario ${scenarioId}...`);
    
    // Get current scenario details
    const scenario = await this.getScenarioDetails(scenarioId);
    if (!scenario) {
      return false;
    }

    // Parse the current blueprint
    let blueprint;
    try {
      blueprint = JSON.parse(scenario.blueprint);
    } catch (error) {
      console.error(`❌ Failed to parse blueprint for scenario ${scenarioId}`);
      return false;
    }

    // Update webhook URLs in modules
    let updated = false;
    if (blueprint.modules) {
      for (const module of blueprint.modules) {
        if (module.module === 'http:ActionMakeAnHTTPRequest') {
          // Update URL parameters
          if (module.parameters && module.parameters.url) {
            if (module.parameters.url.includes('/claude/hybrid-analysis')) {
              module.parameters.url = `${webhookUrl}/claude/hybrid-analysis`;
              updated = true;
            } else if (module.parameters.url.includes('/claude/enrichment-execution')) {
              module.parameters.url = `${webhookUrl}/claude/enrichment-execution`;
              updated = true;
            }
          }
          
          // Update mapper URLs
          if (module.mapper && module.mapper.url) {
            if (module.mapper.url.includes('/claude/hybrid-analysis')) {
              module.mapper.url = `${webhookUrl}/claude/hybrid-analysis`;
              updated = true;
            } else if (module.mapper.url.includes('/claude/enrichment-execution')) {
              module.mapper.url = `${webhookUrl}/claude/enrichment-execution`;
              updated = true;
            }
          }
        }
      }
    }

    if (!updated) {
      console.log(`ℹ️  No webhook URLs found to update in scenario ${scenarioId}`);
      return true;
    }

    // Update the scenario
    const url = `${this.baseUrl}/scenarios/${scenarioId}`;
    try {
      const response = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Authorization': `Token ${this.apiToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          blueprint: JSON.stringify(blueprint)
        })
      });

      if (response.ok) {
        console.log(`✅ Updated scenario ${scenarioId} with webhook: ${webhookUrl}`);
        return true;
      } else {
        const error = await response.text();
        console.error(`❌ Failed to update scenario ${scenarioId}:`, error);
        return false;
      }
    } catch (error) {
      console.error(`❌ Error updating scenario ${scenarioId}:`, error.message);
      return false;
    }
  }

  async updateAllScenarios() {
    console.log('🔄 Updating Make.com scenarios with current ngrok URL...');
    
    const ngrokUrl = await this.getCurrentNgrokUrl();
    if (!ngrokUrl) {
      console.error('❌ Cannot get ngrok URL. Make sure ngrok is running on port 3002');
      return false;
    }

    console.log(`🌐 Current ngrok URL: ${ngrokUrl}`);

    // Islamic Text Processing scenarios to update
    const scenarios = [
      2350731, // Islamic Text Processing - Claude Desktop
      2350757  // Islamic-Text-Minimal-Test
    ];

    let success = true;
    for (const scenarioId of scenarios) {
      const result = await this.updateScenarioWebhook(scenarioId, ngrokUrl);
      if (!result) success = false;
    }

    if (success) {
      console.log('✅ All scenarios updated successfully!');
      console.log('🎯 Islamic Text Processing Pipeline now connected to Claude Desktop');
    } else {
      console.log('⚠️  Some scenarios failed to update');
    }

    return success;
  }
}

// Run the updater
if (import.meta.url === `file://${process.argv[1]}`) {
  const updater = new WebhookUpdater();
  updater.updateAllScenarios().catch(error => {
    console.error('❌ Failed to update scenarios:', error);
    process.exit(1);
  });
}

export { WebhookUpdater };