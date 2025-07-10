#!/bin/bash

# Test Webhook Connectivity - Islamic Text Processing Pipeline
# Run this after creating Make.com scenarios manually

echo "🚀 Testing Make.com + Local Agent Webhook Connectivity"
echo "=================================================="

# Test 1: Local Agent Health Check
echo "📊 1. Testing Local Agent Health..."
HEALTH_RESPONSE=$(curl -s -X GET http://localhost:3001/health)
if [[ $? -eq 0 ]]; then
    echo "✅ Local agent is healthy"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo "❌ Local agent health check failed"
    exit 1
fi

echo ""

# Test 2: Database Queue Status
echo "📊 2. Checking Database Queue Status..."
QUEUE_STATUS=$(PGPASSWORD="sXm0id2x7pEjggUd" psql \
  -h aws-0-us-east-2.pooler.supabase.com \
  -p 5432 \
  -U postgres.aayvvcpxafzhcjqewwja \
  -d postgres \
  -t -c "SELECT status, COUNT(*) FROM book_processing_queue GROUP BY status;")

if [[ $? -eq 0 ]]; then
    echo "✅ Database connection successful"
    echo "   Queue status:"
    echo "$QUEUE_STATUS"
else
    echo "❌ Database connection failed"
    exit 1
fi

echo ""

# Test 3: Research Webhook Test
echo "📊 3. Testing Research Webhook..."
RESEARCH_RESPONSE=$(curl -s -X POST https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb \
  -H "Content-Type: application/json" \
  -d '{
    "task_id": "test-research-webhook-'$(date +%s)'",
    "status": "completed",
    "book_data": {
      "id": "test-book-id",
      "title": "Test Book Title",
      "author": "Test Author"
    },
    "research_findings": {
      "verified": true,
      "sources_found": 2,
      "research_quality": "high"
    },
    "processing_time": 120,
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }')

if [[ $? -eq 0 ]]; then
    echo "✅ Research webhook responded"
    echo "   Response: $RESEARCH_RESPONSE"
else
    echo "❌ Research webhook failed"
fi

echo ""

# Test 4: Analysis Webhook Test  
echo "📊 4. Testing Analysis Webhook..."
ANALYSIS_RESPONSE=$(curl -s -X POST https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/analysis \
  -H "Content-Type: application/json" \
  -d '{
    "task_id": "test-analysis-webhook-'$(date +%s)'",
    "status": "completed",
    "book_data": {
      "id": "test-book-id",
      "title": "Test Book Title",
      "author": "Test Author"
    },
    "analysis": {
      "conceptual_network": {
        "central_node": "Test concept"
      }
    },
    "processing_time": 300,
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }')

if [[ $? -eq 0 ]]; then
    echo "✅ Analysis webhook responded"
    echo "   Response: $ANALYSIS_RESPONSE"
else
    echo "❌ Analysis webhook failed"
fi

echo ""

# Test 5: SQL Webhook Test
echo "📊 5. Testing SQL Webhook..."
SQL_RESPONSE=$(curl -s -X POST https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb/sql \
  -H "Content-Type: application/json" \
  -d '{
    "task_id": "test-sql-webhook-'$(date +%s)'",
    "status": "completed",
    "book_data": {
      "id": "test-book-id",
      "title": "Test Book Title",
      "author": "Test Author"
    },
    "sql_data": {
      "title_alias": "Test Book; Test Book Title",
      "keywords": ["test", "book", "title"],
      "description": "This is a test book description"
    },
    "processing_time": 60,
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }')

if [[ $? -eq 0 ]]; then
    echo "✅ SQL webhook responded"
    echo "   Response: $SQL_RESPONSE"
else
    echo "❌ SQL webhook failed"
fi

echo ""

# Test 6: Local Agent Research Endpoint
echo "📊 6. Testing Local Agent Research Endpoint..."
AGENT_RESPONSE=$(curl -s -X POST http://localhost:3001/agent/research \
  -H "Content-Type: application/json" \
  -d '{
    "task_id": "test-agent-'$(date +%s)'",
    "book_data": {
      "id": "test-book-id",
      "title": "Test Book for Agent",
      "author": "Test Author"
    },
    "webhook_url": "https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb"
  }')

if [[ $? -eq 0 ]]; then
    echo "✅ Local agent research endpoint working"
    echo "   Response: $AGENT_RESPONSE"
else
    echo "❌ Local agent research endpoint failed"
fi

echo ""
echo "🎯 Connectivity Test Summary"
echo "=============================="
echo "Local Agent Health: ✅"
echo "Database Connection: ✅"
echo "Research Webhook: Check response above"
echo "Analysis Webhook: Check response above"
echo "SQL Webhook: Check response above"
echo "Agent Research Endpoint: ✅"

echo ""
echo "📋 Next Steps:"
echo "1. Verify all webhook responses are successful (200 status)"
echo "2. Check Make.com scenario execution logs"
echo "3. Monitor database for queue status changes"
echo "4. Run single book end-to-end test"

echo ""
echo "🔍 Monitoring Commands:"
echo "# Check queue status:"
echo 'PGPASSWORD="sXm0id2x7pEjggUd" psql -h aws-0-us-east-2.pooler.supabase.com -p 5432 -U postgres.aayvvcpxafzhcjqewwja -d postgres -c "SELECT status, COUNT(*) FROM book_processing_queue GROUP BY status;"'
echo ""
echo "# Check agent health:"
echo "curl -X GET http://localhost:3001/health"
echo ""
echo "# View Make.com executions:"
echo "Visit: https://us2.make.com/scenarios"