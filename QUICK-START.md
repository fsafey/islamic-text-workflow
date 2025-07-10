# Islamic Text Processing - Quick Start Guide

## 🎯 **Choose Your Processing Method**

### **Option A: Agent System** (Recommended - Automated)
**Best for**: Bulk processing, automated workflows, real-time monitoring

### **Option B: Manual Workflow** (Legacy - Research-verified)
**Best for**: Custom analysis, specialized books, research verification

---

## 🚀 **Option A: Agent System Quick Start**

### 1. Launch Dashboard
```bash
# Desktop App (easiest)
open "/Users/farieds/Desktop/Islamic Text Dashboard.app"

# OR Command Line
cd ./agent-reservoir-workflow/production/orchestration/
npm run dev
# Dashboard: http://localhost:4000/monitor/
```

### 2. Control Processing
- **Start Assembly**: Click "🚀 Start Assembly" button
- **Choose Preset**: Thorough/Debug dropdown
- **Adjust Batch Size**: 1-20 books per batch
- **Monitor Progress**: Real-time reservoir status

### 3. Individual Agent Control
Each agent card has controls:
- **▶️ Start** - Start individual agent
- **⏹️ Stop** - Stop individual agent
- **🔄 Restart** - Restart individual agent
- **👁️ Details** - View implementation

### 4. Command Line Modes
```bash
# Debug mode (verbose, single book)
open "/path/to/app" --args debug --verbose

# Thorough mode (all agents, comprehensive analysis)
open "/path/to/app" --args thorough

# Auto-start everything
open "/path/to/app" --args thorough --auto-start
```

---

## 🚀 **Option B: Manual Workflow** (Legacy)

### Research Protocol Required

### Step 1: Prepare Input Data
```
Book UUID: [from Supabase books table]
Title: [original title with transliteration issues if any]
Author: [author name]
```

### Step 2: Research & Hybrid Analysis
**🚨 MANDATORY FIRST**: Use WebSearch to research the book title and author. NEVER guess or assume book content.
**📖 If no reliable information found**: SKIP the book entirely. Do not proceed with guesswork.

1. **RESEARCH**: Use WebSearch to verify book content and author information
2. **ANALYSIS**: Use prompt: `./prompts/Academic-Analysis-Prompt-V4-Hybrid.md` (with verified information only)
3. **OUTPUT**: `./academic-analyses/[Book-Title]-Hybrid-Analysis.md`

### Step 3: Generate SQL Enrichment
**🚨 MANDATORY FIRST**: Read and apply `./documentation/ENRICHMENT_CRITERIA.md` methodology for comprehensive search optimization.

1. **STUDY CRITERIA**: Read `./documentation/ENRICHMENT_CRITERIA.md` for title_alias and keywords methodology
2. **EXTRACT DATA**: Get structured data from hybrid analysis for description generation  
3. **GENERATE SQL**: Create comprehensive UPDATE statement with title_alias, keywords, and description
4. **SAVE**: `./sql-updates/[Book-Title]-enrichment.sql`
5. **APPEND**: Add to `./sql-updates/batch-enrichment-updates.sql`

### Step 4: Execute Database Update
```bash
# Individual update (test first)
PGPASSWORD="sXm0id2x7pEjggUd" psql \
  -h aws-0-us-east-2.pooler.supabase.com \
  -p 5432 \
  -U postgres.aayvvcpxafzhcjqewwja \
  -d postgres \
  -f ./islamic-text-workflow/sql-updates/[Book-Title]-enrichment.sql

# Batch update (when ready)
PGPASSWORD="sXm0id2x7pEjggUd" psql \
  -h aws-0-us-east-2.pooler.supabase.com \
  -p 5432 \
  -U postgres.aayvvcpxafzhcjqewwja \
  -d postgres \
  -f ./islamic-text-workflow/sql-updates/batch-enrichment-updates.sql
```

### Step 5: Verify Results
```bash
# Check the updated record
PGPASSWORD="sXm0id2x7pEjggUd" psql \
  -h aws-0-us-east-2.pooler.supabase.com \
  -p 5432 \
  -U postgres.aayvvcpxafzhcjqewwja \
  -d postgres \
  -c "SELECT title, title_alias, array_length(keywords, 1) as keyword_count, length(description) as desc_length FROM books WHERE id = '[UUID]';"
```

## 🛠 **Agent System Features**

### Processing Agents
- **Flowchart Mapper**: Intellectual architecture analysis
- **Network Mapper**: Conceptual network discovery  
- **Metadata Hunter**: Bibliographic research
- **Content Synthesizer**: Library catalog synthesis
- **Data Pipeline**: Production database updates

### Dashboard Controls
- **Workflow Presets**: Thorough, Debug
- **Real-time Monitoring**: Stage distribution, active queue
- **Bottleneck Detection**: Automatic issue identification
- **Individual Controls**: Start/stop/restart any agent

### Environment Variables
```bash
export STARTUP_MODE="debug"          # Control startup behavior
export BATCH_SIZE="5"                # Processing batch size
export AUTO_START_AGENTS="true"      # Auto-start on launch
export WORKFLOW_PRESET="thorough"    # thorough/debug
```

## ⏱️ Processing Times
### Agent System (Automated)
- **Per Book**: 2-5 minutes (depending on preset)
- **Batch Processing**: Configurable (1-20 books)
- **Total Throughput**: 10-30 books/hour

### Manual Workflow (Legacy)
- **Per Book**: ~15 minutes with research
- **Research Required**: WebSearch verification mandatory

## 🔧 Quick Commands

### Agent System
```bash
# Start dashboard
cd ./agent-reservoir-workflow/production/orchestration/
npm run dev

# API status check
curl http://localhost:4000/agent-status

# Control agents
curl -X POST http://localhost:4000/start-agents
curl -X POST http://localhost:4000/stop-agents

# Check reservoir status
curl http://localhost:4000/reservoir-workflow
```

### Database Operations
```bash
# Test connection
PGPASSWORD="sXm0id2x7pEjggUd" psql \
  -h aws-0-us-east-2.pooler.supabase.com \
  -p 5432 \
  -U postgres.aayvvcpxafzhcjqewwja \
  -d postgres \
  -c "SELECT COUNT(*) FROM books;"

# Check reservoir status
psql ... -c "SELECT processing_stage, COUNT(*) FROM book_enrichment_reservoir GROUP BY processing_stage;"
```

## 📚 **Documentation Links**

### Agent System
- **Control Guide**: `./agent-reservoir-workflow/production/orchestration/ENHANCED_CONTROL_GUIDE.md`
- **System Overview**: `./agent-reservoir-workflow/README.md`

### Legacy Workflow  
- **Complete Guide**: `./documentation/Islamic-Text-Processing-Workflow.md`
- **Enrichment Criteria**: `./documentation/ENRICHMENT_CRITERIA.md`
- **Expert Handoff**: `./documentation/EXPERT-AGENT-HANDOFF.md`

## 🎯 **Quick Decision Guide**

**Choose Agent System if:**
- Processing 10+ books
- Want automation and monitoring
- Need configurable workflows
- Want real-time status tracking

**Choose Manual Workflow if:**
- Processing 1-5 books
- Need custom research verification
- Want maximum control over analysis
- Working with specialized/rare texts