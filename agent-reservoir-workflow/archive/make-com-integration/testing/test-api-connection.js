#!/usr/bin/env node

// Test Make.com API Connection
// Uses credentials from .env file or config.js

import config from './config.js';

async function testMakeApiConnection() {
  console.log('🔌 Testing Make.com API Connection...');
  console.log('📊 Configuration:');
  console.log(`   API Token: ${config.makeApi.token.substring(0, 8)}...`);
  console.log(`   Organization ID: ${config.makeApi.organizationId}`);
  console.log(`   Team ID: ${config.makeApi.teamId}`);
  console.log(`   Zone: ${config.makeApi.zone}`);
  console.log('');

  try {
    // Test 1: Get user info
    console.log('🧪 Test 1: Get user information...');
    const userResponse = await fetch(`${config.makeApi.baseUrl}/users/me`, {
      headers: {
        'Authorization': `Token ${config.makeApi.token}`,
        'Accept': 'application/json'
      }
    });

    if (userResponse.ok) {
      const userData = await userResponse.json();
      console.log('✅ User API access successful');
      console.log(`   User: ${userData.authUser.name} (${userData.authUser.email})`);
    } else {
      throw new Error(`User API failed: ${userResponse.status} ${userResponse.statusText}`);
    }

    // Test 2: List scenarios
    console.log('🧪 Test 2: List scenarios...');
    const scenariosResponse = await fetch(`${config.makeApi.baseUrl}/scenarios?organizationId=${config.makeApi.organizationId}`, {
      headers: {
        'Authorization': `Token ${config.makeApi.token}`,
        'Accept': 'application/json'
      }
    });

    if (scenariosResponse.ok) {
      const scenariosData = await scenariosResponse.json();
      console.log('✅ Scenarios API access successful');
      console.log(`   Found ${scenariosData.scenarios?.length || 0} scenarios`);
    } else {
      throw new Error(`Scenarios API failed: ${scenariosResponse.status} ${scenariosResponse.statusText}`);
    }

    // Test 3: Test webhook endpoint
    console.log('🧪 Test 3: Test webhook endpoint...');
    const webhookResponse = await fetch(config.webhook.url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        test: true,
        timestamp: new Date().toISOString(),
        source: 'api-connection-test'
      })
    });

    if (webhookResponse.ok || webhookResponse.status === 404) {
      // 404 is expected if webhook scenario doesn't exist yet
      console.log(`⚠️  Webhook test: ${webhookResponse.status} (${webhookResponse.status === 404 ? 'scenario not created yet' : 'active'})`);
    } else {
      console.log(`❌ Webhook test failed: ${webhookResponse.status} ${webhookResponse.statusText}`);
    }

    console.log('');
    console.log('🎉 API connection tests completed successfully!');
    console.log('🚀 Ready to create scenarios programmatically');

  } catch (error) {
    console.error('❌ API connection test failed:');
    console.error(`   Error: ${error.message}`);
    process.exit(1);
  }
}

// Run the test
if (import.meta.url === `file://${process.argv[1]}`) {
  testMakeApiConnection();
}

export { testMakeApiConnection };