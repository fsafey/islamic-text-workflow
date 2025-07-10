# Islamic Text Processing Workflow

## 🚨 **UPDATED**: Enhanced Agent Reservoir System Available

**NEW AUTOMATED PIPELINE**: Agent-based processing with dashboard controls and reservoir workflow management.

**LEGACY WORKFLOW**: Manual research-based processing (still available for custom analysis).

---

## 🎯 **Two Processing Options**

### Option 1: **Agent Reservoir System** (NEW - Recommended)
Automated 5-agent pipeline with dashboard controls:
- **Location**: `./agent-reservoir-workflow/production/orchestration/`
- **Launch**: Desktop app or `npm run dev`
- **Agents**: Flowchart Mapper, Network Mapper, Metadata Hunter, Content Synthesizer, Data Pipeline
- **Features**: Real-time monitoring, individual agent controls, workflow presets

### Option 2: **Fresh Context Integration** (NEW - Single Agent)
Streamlined single-agent processing with context isolation:
- **Location**: `./claude-docker-model/`
- **Launch**: `docker-compose --profile fresh-context up -d`
- **Features**: Context isolation per book, automatic restarts, simplified deployment


---

## 🚀 **Quick Start - Agent System**

### 1. Desktop App (Easiest)
```bash
# Double-click: Islamic Text Dashboard.app (on Desktop)
# Or with options:
open "/Users/farieds/Desktop/Islamic Text Dashboard.app" --args debug --verbose
```

### 2. Command Line
```bash
cd ./agent-reservoir-workflow/production/orchestration/
npm run dev
# Dashboard: http://localhost:4000/monitor/
```

### 3. Workflow Control Modes
- **Standard**: All 5 agents, batch size 5
- **Fast**: Essential agents, batch size 10  
- **Thorough**: All agents, batch size 2
- **Debug**: Single agent, verbose logging

## 🔬 **Core Quality Standards**

### Research-First Approach
- **WebSearch Required**: Every book must be researched before analysis
- **No Guessing Policy**: Skip books with insufficient information
- **Verified Analysis Only**: Base analysis on actual book content

### Academic Excellence  
- **Islamic Studies Expertise**: Deep scholarly knowledge required
- **World-Class Output**: Publication-ready academic descriptions
- **Comprehensive Metadata**: 40+ keywords, multiple title aliases, 150-word descriptions

### Technical Precision
- **Database Integration**: Direct Supabase updates with verification
- **SQL Safety**: Proper escaping and transaction management
- **Quality Verification**: Database updates confirmed successful

## 📁 **Folder Structure**

```
islamic-text-workflow/
├── README.md                               # 🚨 START HERE (this file)
├── QUICK-START.md                          # Quick reference guide
├── agent-reservoir-workflow/               # 🆕 NEW: Automated agent system
│   └── production/
│       ├── orchestration/                  # Main system directory
│       │   ├── orchestrator.js            # System controller
│       │   ├── monitor/index.html          # Dashboard interface
│       │   ├── Islamic Text Dashboard.app  # Desktop app
│       │   └── ENHANCED_CONTROL_GUIDE.md   # Control documentation
│       └── agents/                         # Processing agents
│           ├── enhanced-flowchart-mapper-agent.js
│           ├── enhanced-network-mapper-agent.js
│           ├── enhanced-metadata-hunter-agent.js
│           ├── content-synthesizer-agent.js
│           └── data-pipeline-agent.js
├── claude-docker-model/                    # 🆕 NEW: Fresh Context Integration
│   ├── docker-compose.integration.yml      # Streamlined agent deployment
│   ├── README.md                           # Integration documentation
│   └── Fresh-Context-Implementation-Report.md  # Context isolation guide
├── documentation/                          # Legacy workflow docs
│   ├── Islamic-Text-Processing-Workflow.md
│   ├── EXPERT-AGENT-HANDOFF.md
│   └── ENRICHMENT_CRITERIA.md
├── prompts/                               # Manual workflow prompts
├── outputs/                               # Manual workflow outputs
└── sql-updates/                           # Manual SQL updates
```

## 🛠 **Agent System Features**

### Dashboard Controls
- **Workflow Presets**: Standard, Fast, Thorough, Debug modes
- **Individual Agent Controls**: Start/stop/restart specific agents
- **Batch Processing**: Configurable batch sizes (1-20)
- **Real-time Monitoring**: Reservoir status, stage distribution, bottleneck detection

### Environment Controls
```bash
# Environment variables for startup control
export STARTUP_MODE="debug"          # normal, debug, fast, thorough
export BATCH_SIZE="5"                # Processing batch size
export AUTO_START_AGENTS="true"      # Auto-start on launch
export VERBOSE_LOGGING="true"        # Debug output
```

### API Endpoints
```bash
# Individual agent control
POST /start-agent {"agentType": "flowchart"}
POST /stop-agent {"agentType": "metadata"}
POST /restart-agent {"agentType": "synthesis"}

# Workflow control
POST /start-assembly              # Start processing
POST /stop-pipeline              # Stop all processing
GET /reservoir-workflow          # Get status
```

## 📊 **Output Quality Metrics**

### Per Book Deliverables:
- ✅ **1 Hybrid Academic Analysis**: Comprehensive scholarly analysis (8-12 min)
- ✅ **1 Academic Description**: 150-word publication-ready description (integrated)
- ✅ **1 SQL Enrichment File**: Complete database update with metadata (3-5 min)
- ✅ **1 Database Update**: Verified successful enrichment (1-2 min)

### Metadata Quality:
- **Title Aliases**: 10+ variations covering transliterations and conceptual titles
- **Keywords**: 40+ comprehensive terms (core concepts + broader subjects + Arabic terms)
- **Description**: 150-word academic description following 5-step narrative structure
- **Database Fields**: title_alias, keywords, description fully populated

## 🎯 **Success Criteria**

### Research Standards:
- ✅ Book content verified through WebSearch before analysis
- ✅ Author information confirmed and accurate
- ✅ No analysis based on assumptions or guesswork

### Academic Standards:
- ✅ Expert-level Islamic studies knowledge demonstrated
- ✅ Comprehensive hybrid analysis (conceptual network + structural flowchart)
- ✅ Publication-ready academic description with proper Arabic terms

### Technical Standards:
- ✅ Database successfully updated with comprehensive metadata
- ✅ SQL properly escaped and transaction-safe
- ✅ All files created and properly organized

## 📚 **Documentation Hierarchy**

**Level 1 - Quick Start**:
- `README.md` ← You are here
- `QUICK-START.md` ← Next step for immediate workflow

**Level 2 - Complete Guide**:
- `./documentation/Islamic-Text-Processing-Workflow.md` ← Full methodology
- `./documentation/ENRICHMENT_CRITERIA.md` ← Search optimization guide

**Level 3 - Specialized**:
- `./documentation/EXPERT-AGENT-HANDOFF.md` ← Multi-book processing
- `./prompts/Academic-Analysis-Prompt-V4-Hybrid.md` ← Stage 1 prompt

## 🚨 **Critical Reminders**

1. **ALWAYS RESEARCH FIRST**: Use WebSearch before any analysis
2. **NEVER GUESS**: Skip books without reliable information  
3. **READ ENRICHMENT_CRITERIA.md**: Mandatory for quality metadata
4. **VERIFY DATABASE UPDATES**: Confirm successful enrichment
5. **MAINTAIN ACADEMIC RIGOR**: World-class scholarly standards required

## 🎯 **What's Next?**

**New to the workflow?** → Read `QUICK-START.md`  
**Need complete methodology?** → Read `./documentation/Islamic-Text-Processing-Workflow.md`  
**Processing multiple books?** → Read `./documentation/EXPERT-AGENT-HANDOFF.md`  
**Starting analysis?** → Research book first, then use `./prompts/Academic-Analysis-Prompt-V4-Hybrid.md`

---

**🎯 GOAL**: Transform Islamic book data into world-class academic metadata through research-verified, expert-level analysis with comprehensive searchable enrichment.**