# 🗂️ Agent Reservoir Workflow - System Inventory

**Location**: `/islamic-text-workflow/agent-reservoir-workflow/`

---

## 📁 **Production Components**

### **Agents** (`production/agents/`)
| Agent | Port | Database Table | Function Called | Purpose |
|-------|------|----------------|-----------------|---------|
| `enhanced-flowchart-mapper-agent.js` | 3001 | `book_enrichment_reservoir` | `get_books_ready_for_agent('flowchart')` | Intellectual architecture analysis |
| `enhanced-network-mapper-agent.js` | 3002 | `book_enrichment_reservoir` | `get_books_ready_for_agent('network')` | Conceptual network discovery |
| `enhanced-metadata-hunter-agent.js` | 3003 | `book_enrichment_reservoir` | `get_books_ready_for_agent('metadata')` | Bibliographic research |
| `content-synthesizer-agent.js` | 3004 | `book_enrichment_reservoir` | `get_books_ready_for_agent('synthesis')` | Library catalog synthesis |
| `data-pipeline-agent.js` | 3006 | `book_enrichment_reservoir` + `books` | Custom pipeline functions | Production database population |

### **Orchestration** (`production/orchestration/`)
| Component | Port | Purpose | Key Endpoints |
|-----------|------|---------|---------------|
| `orchestrator.js` | 4000 | Coordinate all agents | `/health`, `/agents-health`, `/start-assembly`, `/initialize-reservoir` |

### **Database** (`production/database/`)
| File | Purpose | Tables Created |
|------|---------|----------------|
| `create-reservoir-schema.sql` | Main reservoir table | `book_enrichment_reservoir` |
| `staging-area-schema.sql` | Staging tables | Various staging tables |
| `direct-sheets-import-schema.sql` | Import utilities | Import-related tables |
| `fix-processing-function.sql` | Function fixes | Repair existing functions |

---

## 📚 **Documentation** (`docs/`)
| Document | Purpose | Key Sections |
|----------|---------|--------------|
| `LOCAL-ORCHESTRATION-GUIDE.md` | **Primary technical reference** | Database schema, agent interactions, functions |
| `ASSEMBLY-LINE-README.md` | Setup and execution guide | Quick start, monitoring |
| `AGENT_ENHANCEMENT_MASTER_GUIDE.md` | Agent enhancement methodology | Design patterns, improvements |
| `RESERVOIR_SYSTEM_PHILOSOPHY.md` | System design philosophy | Architecture principles |
| `SIMPLE-SETUP-GUIDE.md` | Simplified setup instructions | Basic configuration |

---

## 🎯 **Guidance Documents** (`guidance/`)
| Guidance File | Agent | Methodology Focus |
|---------------|-------|-------------------|
| `FLOWCHART_MAPPER_GUIDANCE.md` | enhanced-flowchart-mapper-agent.js | Intellectual architecture analysis |
| `NETWORK_MAPPER_GUIDANCE.md` | enhanced-network-mapper-agent.js | Conceptual network discovery |
| `METADATA_HUNTER_GUIDANCE.md` | enhanced-metadata-hunter-agent.js | Bibliographic research methodology |
| `CONTENT_SYNTHESIZER_GUIDANCE.md` | content-synthesizer-agent.js | Library catalog synthesis |
| `DATA_PIPELINE_GUIDANCE.md` | data-pipeline-agent.js | Production data population |
| `ORCHESTRATOR_GUIDANCE.md` | orchestrator.js | Agent coordination patterns |

---

## 📊 **Reports & Analysis** (`reports/`)
| Report | Purpose | Status |
|--------|---------|--------|
| `WORKFLOW_TEST_EXECUTION_REPORT.md` | **Active test documentation** | Current workflow testing |
| `ENHANCED_WORKFLOW_TEST_REPORT.md` | Enhanced agent testing | Historical test results |
| `ENHANCEMENT_LOG.md` | Change tracking | Development history |

---

## 🧪 **Testing & Archive** 

### **Tests** (`tests/`)
| File | Purpose |
|------|---------|
| `test-pipeline.js` | End-to-end pipeline testing |

### **Archive** (`archive/`)
| Folder | Content | Purpose |
|--------|---------|---------|
| `old-agents/` | Working reference agents | **Comparison baseline for debugging** |
| `old-docs/` | Previous documentation | Historical reference |
| `complex-designs/` | Advanced design concepts | Future enhancement ideas |

---

## 🔄 **Workflow Execution Order**

### **Stage Sequence**
1. **Initialize**: `orchestrator.js` → `initialize_reservoir_from_queue()`
2. **Stage 1**: `enhanced-flowchart-mapper-agent.js` → Intellectual architecture analysis
3. **Stage 2**: `enhanced-network-mapper-agent.js` → Conceptual network discovery  
4. **Stage 3**: `enhanced-metadata-hunter-agent.js` → Bibliographic research
5. **Stage 4**: `content-synthesizer-agent.js` → Library catalog synthesis
6. **Stage 5**: `data-pipeline-agent.js` → Production database population

### **Database Flow**
```
book_processing_queue → book_enrichment_reservoir → books (production)
                     ↓                          ↓
              Agent processing stages    Final enriched catalog
```

---

## 🚀 **Quick Start Commands**

```bash
# Navigate to workflow directory
cd /Users/farieds/imam-lib-masha-allah/islamic-text-workflow/agent-reservoir-workflow

# Start orchestrator
node production/orchestration/orchestrator.js

# Test individual agents  
node production/agents/enhanced-flowchart-mapper-agent.js

# Run tests
node tests/test-pipeline.js

# View documentation
open docs/LOCAL-ORCHESTRATION-GUIDE.md
```

---

## 🔍 **Key Technical References**

- **Database Schema**: `docs/LOCAL-ORCHESTRATION-GUIDE.md` (Database Schema & Functions section)
- **Agent Interactions**: `docs/LOCAL-ORCHESTRATION-GUIDE.md` (Enhanced 5-Stage Workflow section)  
- **Debugging Reference**: `archive/old-agents/` (working baseline agents)
- **Current Issues**: `reports/WORKFLOW_TEST_EXECUTION_REPORT.md`