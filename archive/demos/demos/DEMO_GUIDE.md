# 🚀 Claude Docker Demo Guide - Islamic Text Workflow

## Prerequisites
- Docker Desktop running
- Terminal/Command Line access
- Claude Docker installed (from islamic-text-workflow)

## 📚 Demo 1: Analyze Academic Islamic Text Research

### What You'll Learn
- AI-assisted academic analysis
- Pattern recognition in scholarly work
- Research methodology enhancement

### Steps:
```bash
# 1. Start from project root (islamic-text-workflow)
claude-docker

# 2. Give Claude this instruction:
"Read demos/islamic-text-demos/task1-analyze-academic-files.md and analyze our Islamic text research methodology. Look at the git status to see the academic analysis files and identify patterns in our scholarly approach."

# 3. Claude will:
- Analyze deleted academic analysis files from git status
- Extract common themes and methodologies
- Generate quality metrics for research
- Suggest improvements for future analyses
```

### Expected Result:
- `academic_analysis_report.md` with research insights
- `analysis_patterns.json` with structured findings
- Recommendations for workflow enhancement

---

## 🔍 Demo 2: Enhance Text Processing Pipeline (Serena MCP)

### What You'll Learn
- Code analysis for academic projects
- NLP pipeline optimization
- Research tool enhancement

### Steps:
```bash
# Continue from project root
claude-docker --continue

# Give Claude this instruction:
"Read demos/islamic-text-demos/task2-enhance-workflow.md and improve our Islamic text processing pipeline. Use Context7 to research latest NLP techniques for Arabic and Islamic texts."

# Claude will:
- Analyze existing .mcp.json configuration
- Research modern NLP tools via Context7
- Enhance text processing capabilities
- Add Arabic/Islamic text analysis features
```

### Expected Result:
- Enhanced processing scripts with new capabilities
- `workflow_enhancements.md` documenting improvements
- New features for Islamic text analysis

---

## 📚 Demo 3: Generate Academic Documentation (Context7)

### What You'll Learn
- Academic project documentation
- Research methodology documentation
- Scholarly standards compliance

### Steps:
```bash
# Continue from project root
claude-docker --continue

# Give Claude this instruction:
"Read demos/islamic-text-demos/task3-document-project.md and create comprehensive documentation for this Islamic text workflow project. Analyze the entire project structure and create academic-quality documentation."

# Claude will:
- Analyze entire project architecture
- Document research methodology
- Create setup guides for researchers
- Generate academic standards documentation
```

### Expected Result:
- Comprehensive `README.md` for the project
- `METHODOLOGY.md` explaining academic approach
- `SETUP_GUIDE.md` for new researchers
- Templates for future Islamic text analyses

---

## ⚡ Demo 4: Research Automation and Scaling

### What You'll Learn
- Multi-text batch processing
- Research workflow automation
- Academic project scaling

### Steps:
```bash
# Continue from project root with more resources
claude-docker --memory 8g --continue

# Give Claude this instruction:
"Create an automated system to process multiple Islamic texts simultaneously. Build a batch processor that can analyze new texts using our enhanced methodology and generate standardized academic reports."

# Claude will:
- Create batch processing system
- Implement quality assurance checks
- Generate standardized report templates
- Set up automated citation tracking
```

### Expected Result:
- Automated batch processing system
- Standardized analysis templates
- Quality assurance workflows
- SMS notifications for long-running analyses

---

## 🚀 Advanced Usage Examples

### 1. Continue Previous Session
```bash
claude-docker --continue
```

### 2. High Memory Tasks
```bash
claude-docker --memory 16g
```

### 3. GPU-Accelerated Tasks
```bash
claude-docker --gpus all
```

### 4. Custom MCP Servers
Edit `~/islamic-text-workflow/mcp-servers.txt` and add:
```bash
claude mcp add -s user my-tool -- npx @company/my-mcp-server
```
Then rebuild:
```bash
claude-docker --rebuild
```

---

## 💡 Pro Tips

### 1. Task Logging
Claude automatically creates `task_log.md` documenting:
- Assumptions made
- Challenges encountered
- Solutions implemented

### 2. SMS Notifications
Perfect for long-running tasks:
- "Starting web scraping of 1000 pages..."
- "Task failed: API rate limit reached"
- "Success! Processed 1000 pages in 45 minutes"

### 3. Conversation History
Each project maintains its own conversation history. Use `--continue` to resume.

### 4. Environment Persistence
- Authentication persists across sessions
- Settings in `~/.claude-docker/claude-home/`
- Project-specific configs in `.claude/`

---

## 🛠️ Customization

### Add Custom Instructions
Edit `~/.claude-docker/claude-home/CLAUDE.md` to add:
- Coding standards
- Preferred libraries
- Project conventions

### Configure MCP Servers
Edit settings in `~/.claude-docker/claude-home/settings.json`

### Team Deployment
```bash
# Build custom image
docker build -t myteam/claude-docker .

# Push to registry
docker push myteam/claude-docker

# Team members pull
docker pull myteam/claude-docker
```

---

## 🎉 Next Steps

1. **Try each demo** to understand capabilities
2. **Modify task files** to match your needs
3. **Combine features** for complex workflows
4. **Scale up** with batch processing
5. **Share results** with your team

Remember: Claude Docker gives you an autonomous AI developer that can work on complex tasks while you focus on high-level strategy!