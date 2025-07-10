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

  async updateScenarioWebhook(scenarioId, webhookUrl) {
    const url = `${this.baseUrl}/scenarios/${scenarioId}`;
    
    // Islamic Text Processing scenario blueprint
    const blueprint = {
      "modules": [
        {
          "id": 1,
          "module": "http:ActionMakeAnHTTPRequest",
          "version": 3,
          "parameters": {
            "url": `${webhookUrl}/claude/hybrid-analysis`,
            "method": "post",
            "headers": [
              {
                "name": "Content-Type",
                "value": "application/json"
              }
            ],
            "qs": [],
            "bodyType": "raw",
            "parseResponse": true,
            "authUser": "",
            "authPass": "",
            "timeout": "",
            "shareCookies": false,
            "ca": "",
            "rejectUnauthorized": true,
            "followRedirect": true,
            "useQuerystring": false,
            "gzip": true,
            "useMtls": false
          },
          "mapper": {
            "url": `${webhookUrl}/claude/hybrid-analysis`,
            "data": "{{1.book_data}}"
          },
          "metadata": {
            "designer": {
              "x": 0,
              "y": 0
            },
            "restore": {},
            "parameters": [
              {
                "name": "url",
                "type": "url",
                "label": "URL",
                "required": true
              }
            ],
            "name": "Stage 1: Hybrid Analysis"
          }
        },
        {
          "id": 2,
          "module": "http:ActionMakeAnHTTPRequest",
          "version": 3,
          "parameters": {
            "url": `${webhookUrl}/claude/enrichment-execution`,
            "method": "post",
            "headers": [
              {
                "name": "Content-Type",
                "value": "application/json"
              }
            ],
            "qs": [],
            "bodyType": "raw",
            "parseResponse": true,
            "authUser": "",
            "authPass": "",
            "timeout": "",
            "shareCookies": false,
            "ca": "",
            "rejectUnauthorized": true,
            "followRedirect": true,
            "useQuerystring": false,
            "gzip": true,
            "useMtls": false
          },
          "mapper": {
            "url": `${webhookUrl}/claude/enrichment-execution`,
            "data": "{{1.analysis_data}}"
          },
          "metadata": {
            "designer": {
              "x": 300,
              "y": 0
            },
            "restore": {},
            "parameters": [
              {
                "name": "url",
                "type": "url",
                "label": "URL",
                "required": true
              }
            ],
            "name": "Stage 2: Enrichment & SQL"
          }
        }
      ],
      "metadata": {
        "instant": false,
        "version": 1,
        "scenario": {
          "roundtrips": 1,
          "maxErrors": 3,
          "autoCommit": true,
          "autoCommitTriggerLast": true,
          "sequential": false,
          "slots": null,
          "confidential": false,
          "dataloss": false,
          "dlq": false,
          "freshVariables": false
        },
        "designer": {
          "orphans": []
        },
        "zone": "us2.make.com"
      }
    };

    try {
      const response = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Authorization': `Token ${this.apiToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          blueprint: JSON.stringify(blueprint),
          scheduling: JSON.stringify({
            type: "indefinitely",
            interval: 60  // 1-minute intervals for faster processing
          })
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