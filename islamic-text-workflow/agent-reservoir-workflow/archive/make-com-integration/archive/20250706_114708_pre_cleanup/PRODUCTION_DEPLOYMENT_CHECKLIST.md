# Islamic Text Processing Pipeline - Production Deployment Checklist

**Pipeline Status**: ✅ Ready for Production  
**Last Updated**: 2025-07-06  
**Scenario ID**: 2350731

## 🚀 Pre-Deployment Checklist

### System Requirements
- [ ] **Node.js** - Version 18+ installed
- [ ] **uv package manager** - For codemcp installation
- [ ] **ngrok account** - With authentication token configured
- [ ] **Make.com access** - API token and scenario permissions
- [ ] **Supabase access** - Database connection verified

### Environment Setup
- [ ] **ngrok authenticated**: `ngrok auth <token>` completed
- [ ] **Production folder**: All files copied to `production/` directory
- [ ] **Executable permissions**: Scripts have execute permissions
- [ ] **Configuration verified**: API tokens and credentials correct

## 🔧 Deployment Steps

### 1. Start the Pipeline
```bash
cd production/
./start-pipeline.sh
```

**Expected Output:**
- ✅ codemcp server started (port 8000)
- ✅ Claude Desktop bridge started (port 3002)
- ✅ ngrok tunnel established
- ✅ Public URL displayed

### 2. Update Make.com Scenario
```bash
node update-scenario-urls.js
```

**Expected Output:**
- ✅ Scenario 2350731 updated successfully
- ✅ New ngrok URL configured
- ✅ All endpoints updated

### 3. Health Verification
```bash
# Test local endpoints
curl http://localhost:3002/health
curl http://localhost:8000/sse

# Test public endpoint
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
curl "$NGROK_URL/health"
```

### 4. Process Test Book
```bash
# Send test request to Claude Desktop
curl -X POST "$NGROK_URL/claude/research" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Islamic Book", "author": "Test Author"}'
```

## ✅ Production Validation

### Service Health Checks
- [ ] **codemcp server responding** (port 8000)
- [ ] **Claude Desktop bridge responding** (port 3002)  
- [ ] **ngrok tunnel active** (check dashboard at localhost:4040)
- [ ] **Public URL accessible** from external network

### Functional Tests
- [ ] **Health endpoint**: Returns service status
- [ ] **Research endpoint**: Processes Islamic text requests
- [ ] **Make.com scenario**: Updated with current URLs
- [ ] **Database connectivity**: Queue access working

### End-to-End Test
- [ ] **Queue polling**: Make.com can read pending books
- [ ] **Claude Desktop processing**: Books analyzed correctly
- [ ] **Response handling**: Results sent to webhook
- [ ] **Status updates**: Queue marked as completed

## 📊 Production Monitoring

### Key Metrics
- **Queue Processing Rate**: Books per hour
- **Response Time**: Claude Desktop analysis speed
- **Error Rate**: Failed vs successful requests
- **Service Uptime**: All components running

### Monitoring Commands
```bash
# Check service status
ps aux | grep -E "(codemcp|claude-desktop-agent|ngrok)"

# Monitor queue
PGPASSWORD="sXm0id2x7pEjggUd" psql \
  -h aws-0-us-east-2.pooler.supabase.com \
  -p 5432 \
  -U postgres.aayvvcpxafzhcjqewwja \
  -d postgres \
  -c "SELECT status, COUNT(*) FROM book_processing_queue GROUP BY status;"

# Check ngrok status
curl -s http://localhost:4040/api/tunnels | jq '.tunnels[0].public_url'
```

## 🛑 Troubleshooting

### Common Issues

**ngrok authentication failed**
```bash
# Solution: Re-authenticate
ngrok auth <your-token>
```

**Port already in use**
```bash
# Solution: Stop existing processes
./stop-pipeline.sh
sleep 5
./start-pipeline.sh
```

**codemcp not found**
```bash
# Solution: Install uv package manager
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
```

**Make.com scenario not responding**
```bash
# Solution: Check scenario status
curl -H "Authorization: Token ee520945-335f-4f06-9cb6-f9e782fc5bdd" \
     https://us2.make.com/api/v2/scenarios/2350731
```

### Emergency Procedures

**Complete restart**
```bash
./stop-pipeline.sh
pkill -f ngrok      # Force kill ngrok
sleep 10
./start-pipeline.sh
```

**Rollback to localhost testing**
```bash
# Stop public pipeline
./stop-pipeline.sh

# Start local development
cd ..
node claude-desktop-agent.js
```

## 📞 Production Support

### Status Dashboard
- **ngrok**: http://localhost:4040
- **Make.com**: https://us2.make.com/scenarios/2350731
- **Supabase**: Database dashboard

### Log Locations
- **Bridge logs**: Console output from `claude-desktop-agent.js`
- **codemcp logs**: Process output from `uvx codemcp serve`
- **ngrok logs**: Available in ngrok dashboard

### Success Criteria
- [ ] **360 books in queue** ready for processing
- [ ] **All services healthy** and responding
- [ ] **End-to-end test successful** with real book data
- [ ] **Production monitoring** active and functional

---

**Deployment Goal**: Process 360+ Islamic texts through Claude Desktop + Make.com pipeline  
**Expected Performance**: Systematic processing with complete audit trail and Islamic text expertise