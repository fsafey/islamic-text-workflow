/**
 * Islamic Text Processing - Knowledge Engineering Dashboard
 * World-class monitoring with full pipeline transparency
 */

class KnowledgeEngineeringDashboard {
    constructor() {
        this.websocket = null;
        this.orchestratorUrl = window.location.origin.replace('8080', '4000');
        this.refreshInterval = 2000; // 2 seconds
        this.currentBooks = new Map();
        this.agentStates = new Map();
        this.logs = [];
        this.maxLogs = 100;
        
        this.init();
    }
    
    async init() {
        await this.setupWebSocket();
        await this.setupEventHandlers();
        await this.startDataRefresh();
        
        console.log('🎛️ Knowledge Engineering Dashboard initialized');
    }
    
    // ====================
    // WebSocket Connection
    // ====================
    
    async setupWebSocket() {
        try {
            // Try WebSocket connection for real-time updates
            const wsUrl = this.orchestratorUrl.replace('http', 'ws') + '/ws';
            this.websocket = new WebSocket(wsUrl);
            
            this.websocket.onmessage = (event) => {
                const data = JSON.parse(event.data);
                this.handleRealTimeUpdate(data);
            };
            
            this.websocket.onclose = () => {
                console.log('WebSocket connection closed, falling back to polling');
                this.websocket = null;
            };
            
        } catch (error) {
            console.log('WebSocket unavailable, using polling mode');
            this.websocket = null;
        }
    }
    
    handleRealTimeUpdate(data) {
        switch (data.type) {
            case 'book_update':
                this.updateBookStatus(data.book);
                break;
            case 'agent_update':
                this.updateAgentStatus(data.agent);
                break;
            case 'log_entry':
                this.addLogEntry(data.log);
                break;
            case 'pipeline_stats':
                this.updatePipelineStats(data.stats);
                break;
        }
    }
    
    // ====================
    // Event Handlers
    // ====================
    
    async setupEventHandlers() {
        // Control buttons
        document.getElementById('startPipeline').addEventListener('click', () => this.startPipeline());
        document.getElementById('stopPipeline').addEventListener('click', () => this.stopPipeline());
        document.getElementById('refreshData').addEventListener('click', () => this.refreshAllData());
        
        // Book selection
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('book-item')) {
                this.selectBook(e.target.dataset.bookId);
            }
        });
        
        // Agent selection
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('agent-card')) {
                this.selectAgent(e.target.dataset.agentName);
            }
        });
    }
    
    // ====================
    // Data Refresh
    // ====================
    
    async startDataRefresh() {
        if (!this.websocket) {
            setInterval(() => this.refreshAllData(), this.refreshInterval);
        }
        
        // Initial data load
        await this.refreshAllData();
    }
    
    async refreshAllData() {
        try {
            await Promise.all([
                this.updateSystemStats(),
                this.updateWorkflowStages(),
                this.updateCurrentBooks(),
                this.updateAgentStates(),
                this.updateLogs()
            ]);
        } catch (error) {
            console.error('Error refreshing data:', error);
            this.addLogEntry({
                level: 'error',
                agent: 'dashboard',
                message: `Failed to refresh data: ${error.message}`,
                timestamp: new Date().toISOString()
            });
        }
    }
    
    // ====================
    // System Stats
    // ====================
    
    async updateSystemStats() {
        try {
            const response = await fetch(`${this.orchestratorUrl}/reservoir-status`);
            const data = await response.json();
            
            // Update header stats
            document.getElementById('totalBooks').textContent = data.total_books || 1019;
            document.getElementById('processedBooks').textContent = data.completed || 0;
            document.getElementById('processingRate').textContent = data.processing_rate || '0/hr';
            
            // Update health stats
            const agentsResponse = await fetch(`${this.orchestratorUrl}/agents-health`);
            const agentsData = await agentsResponse.json();
            
            const onlineAgents = Object.values(agentsData.agents).filter(a => a.status === 'healthy').length;
            const totalErrors = Object.values(agentsData.agents).reduce((sum, a) => sum + (a.errors || 0), 0);
            
            document.getElementById('agentsOnline').textContent = onlineAgents;
            document.getElementById('errorsCount').textContent = totalErrors;
            
            // Calculate average processing time
            const avgTime = this.calculateAverageProcessingTime(data);
            document.getElementById('avgProcessingTime').textContent = avgTime;
            
            // Memory usage (estimated)
            const memoryUsage = this.calculateMemoryUsage(agentsData);
            document.getElementById('memoryUsage').textContent = memoryUsage;
            
        } catch (error) {
            console.error('Error updating system stats:', error);
        }
    }
    
    calculateAverageProcessingTime(data) {
        // Calculate based on processing rate and queue depth
        const rate = parseFloat(data.processing_rate) || 1;
        const avgMinutes = 60 / rate;
        return `${avgMinutes.toFixed(1)}m`;
    }
    
    calculateMemoryUsage(agentsData) {
        // Estimate memory usage based on agent token usage
        const agents = Object.values(agentsData.agents);
        const avgTokenUsage = agents.reduce((sum, a) => sum + (a.usage_percentage || 0), 0) / agents.length;
        return `${Math.round(avgTokenUsage * 100)}%`;
    }
    
    // ====================
    // Workflow Stages
    // ====================
    
    async updateWorkflowStages() {
        try {
            const response = await fetch(`${this.orchestratorUrl}/reservoir-status`);
            const data = await response.json();
            
            const stages = [
                { name: 'Pending', count: data.reservoir_status?.pending || 0, color: '#757575' },
                { name: 'Flowchart Analysis', count: data.reservoir_status?.flowchart || 0, color: '#4CAF50' },
                { name: 'Network Mapping', count: data.reservoir_status?.network || 0, color: '#2196F3' },
                { name: 'Metadata Research', count: data.reservoir_status?.metadata || 0, color: '#FF9800' },
                { name: 'Content Synthesis', count: data.reservoir_status?.synthesis || 0, color: '#9C27B0' },
                { name: 'Data Pipeline', count: data.reservoir_status?.pipeline || 0, color: '#00BCD4' },
                { name: 'Completed', count: data.reservoir_status?.completed || 0, color: '#4CAF50' }
            ];
            
            const stagesContainer = document.getElementById('workflowStages');
            stagesContainer.innerHTML = stages.map(stage => `
                <div class="workflow-stage">
                    <div class="stage-header">
                        <div class="stage-name">${stage.name}</div>
                        <div class="stage-count">${stage.count}</div>
                    </div>
                    <div class="stage-progress">
                        <div class="stage-progress-fill" style="width: ${this.calculateStageProgress(stage.count, data.total_books)}%; background-color: ${stage.color};"></div>
                    </div>
                    <div class="stage-books" id="stage-${stage.name.toLowerCase().replace(' ', '-')}">
                        ${this.renderStageBooks(stage.name, stage.count)}
                    </div>
                </div>
            `).join('');
            
        } catch (error) {
            console.error('Error updating workflow stages:', error);
        }
    }
    
    calculateStageProgress(count, total) {
        return total > 0 ? (count / total) * 100 : 0;
    }
    
    renderStageBooks(stageName, count) {
        // Generate placeholder book items for visualization
        const books = [];
        for (let i = 0; i < Math.min(count, 20); i++) {
            books.push(`<div class="book-item" data-book-id="${stageName}-${i}">Book ${i + 1}</div>`);
        }
        if (count > 20) {
            books.push(`<div class="book-item">+${count - 20} more</div>`);
        }
        return books.join('');
    }
    
    // ====================
    // Current Books Processing
    // ====================
    
    async updateCurrentBooks() {
        try {
            const response = await fetch(`${this.orchestratorUrl}/processing-queue`);
            const data = await response.json();
            
            const currentBooksContainer = document.getElementById('currentBooks');
            
            if (data.current_books && data.current_books.length > 0) {
                currentBooksContainer.innerHTML = data.current_books.map(book => this.renderBookDetail(book)).join('');
            } else {
                currentBooksContainer.innerHTML = `
                    <div class="book-detail">
                        <div class="book-title">No books currently processing</div>
                        <div class="book-author">Start the pipeline to begin processing</div>
                    </div>
                `;
            }
            
        } catch (error) {
            console.error('Error updating current books:', error);
            // Fallback to sample data for demonstration
            this.renderSampleBooks();
        }
    }
    
    renderBookDetail(book) {
        const stages = ['pending', 'flowchart', 'network', 'metadata', 'synthesis', 'pipeline', 'completed'];
        const currentStageIndex = stages.indexOf(book.current_stage || 'pending');
        
        return `
            <div class="book-detail" data-book-id="${book.id}">
                <div class="book-title">${book.title || 'Unknown Title'}</div>
                <div class="book-author">by ${book.author || 'Unknown Author'}</div>
                
                <div class="book-stages">
                    ${stages.map((stage, index) => `
                        <div class="stage-indicator ${index < currentStageIndex ? 'completed' : index === currentStageIndex ? 'current' : ''}" 
                             data-stage="${stage}">
                        </div>
                    `).join('')}
                </div>
                
                <div class="book-metadata">
                    <div class="metadata-item">
                        <span class="metadata-label">Stage:</span>
                        <span class="metadata-value">${book.current_stage || 'pending'}</span>
                    </div>
                    <div class="metadata-item">
                        <span class="metadata-label">Agent:</span>
                        <span class="metadata-value">${book.current_agent || 'none'}</span>
                    </div>
                    <div class="metadata-item">
                        <span class="metadata-label">Progress:</span>
                        <span class="metadata-value">${book.progress || 0}%</span>
                    </div>
                    <div class="metadata-item">
                        <span class="metadata-label">Time:</span>
                        <span class="metadata-value">${book.processing_time || '0m'}</span>
                    </div>
                </div>
            </div>
        `;
    }
    
    renderSampleBooks() {
        // Sample data for demonstration
        const sampleBooks = [
            {
                id: 1,
                title: "Ihya Ulum al-Din",
                author: "Al-Ghazali",
                current_stage: "flowchart",
                current_agent: "flowchart_mapper",
                progress: 65,
                processing_time: "2.3m"
            },
            {
                id: 2,
                title: "Tafsir al-Tabari",
                author: "Al-Tabari",
                current_stage: "network",
                current_agent: "network_mapper",
                progress: 23,
                processing_time: "1.1m"
            }
        ];
        
        const container = document.getElementById('currentBooks');
        container.innerHTML = sampleBooks.map(book => this.renderBookDetail(book)).join('');
    }
    
    // ====================
    // Agent States
    // ====================
    
    async updateAgentStates() {
        try {
            const response = await fetch(`${this.orchestratorUrl}/agents-health`);
            const data = await response.json();
            
            const agentsContainer = document.getElementById('agentsGrid');
            const agents = Object.values(data.agents);
            
            agentsContainer.innerHTML = agents.map(agent => this.renderAgentCard(agent)).join('');
            
        } catch (error) {
            console.error('Error updating agent states:', error);
        }
    }
    
    renderAgentCard(agent) {
        const agentNames = {
            'flowchart_mapper': 'Flowchart Mapper',
            'network_mapper': 'Network Mapper',
            'metadata_hunter': 'Metadata Hunter',
            'content_synthesizer': 'Content Synthesizer',
            'data_pipeline': 'Data Pipeline'
        };
        
        const displayName = agentNames[agent.agent] || agent.agent;
        const statusClass = agent.status === 'healthy' ? 'online' : 'offline';
        
        return `
            <div class="agent-card" data-agent-name="${agent.agent}">
                <div class="agent-header">
                    <div class="agent-name">${displayName}</div>
                    <div class="agent-status ${statusClass}"></div>
                </div>
                
                <div class="agent-metrics">
                    <div class="metric-item">
                        <div class="metric-value">${agent.processed || 0}</div>
                        <div class="metric-label">Processed</div>
                    </div>
                    <div class="metric-item">
                        <div class="metric-value">${agent.errors || 0}</div>
                        <div class="metric-label">Errors</div>
                    </div>
                </div>
                
                <div class="current-task">
                    <div class="task-book">${agent.current_book || 'Waiting...'}</div>
                    <div class="task-progress">
                        <div class="task-progress-fill" style="width: ${agent.progress || 0}%"></div>
                    </div>
                    <div class="task-time">${agent.processing_time || '0s'}</div>
                </div>
            </div>
        `;
    }
    
    // ====================
    // Logs Management
    // ====================
    
    async updateLogs() {
        try {
            const response = await fetch(`${this.orchestratorUrl}/system-logs?limit=50`);
            const data = await response.json();
            
            if (data.logs) {
                data.logs.forEach(log => this.addLogEntry(log));
            }
            
        } catch (error) {
            console.error('Error updating logs:', error);
        }
    }
    
    addLogEntry(log) {
        this.logs.unshift(log);
        if (this.logs.length > this.maxLogs) {
            this.logs = this.logs.slice(0, this.maxLogs);
        }
        
        this.renderLogs();
    }
    
    renderLogs() {
        const logsContainer = document.getElementById('logsContainer');
        logsContainer.innerHTML = this.logs.map(log => `
            <div class="log-entry ${log.level}">
                <span class="log-timestamp">${new Date(log.timestamp).toLocaleTimeString()}</span>
                <span class="log-agent">[${log.agent}]</span>
                <span class="log-message">${log.message}</span>
            </div>
        `).join('');
        
        // Auto-scroll to bottom
        logsContainer.scrollTop = logsContainer.scrollHeight;
    }
    
    // ====================
    // Control Actions
    // ====================
    
    async startPipeline() {
        try {
            const response = await fetch(`${this.orchestratorUrl}/start-assembly`, {
                method: 'POST'
            });
            
            if (response.ok) {
                this.addLogEntry({
                    level: 'info',
                    agent: 'dashboard',
                    message: 'Pipeline started successfully',
                    timestamp: new Date().toISOString()
                });
            }
            
        } catch (error) {
            this.addLogEntry({
                level: 'error',
                agent: 'dashboard',
                message: `Failed to start pipeline: ${error.message}`,
                timestamp: new Date().toISOString()
            });
        }
    }
    
    async stopPipeline() {
        try {
            const response = await fetch(`${this.orchestratorUrl}/stop-pipeline`, {
                method: 'POST'
            });
            
            if (response.ok) {
                this.addLogEntry({
                    level: 'info',
                    agent: 'dashboard',
                    message: 'Pipeline stopped successfully',
                    timestamp: new Date().toISOString()
                });
            }
            
        } catch (error) {
            this.addLogEntry({
                level: 'error',
                agent: 'dashboard',
                message: `Failed to stop pipeline: ${error.message}`,
                timestamp: new Date().toISOString()
            });
        }
    }
    
    // ====================
    // Selection Handlers
    // ====================
    
    selectBook(bookId) {
        // Highlight selected book and show detailed view
        document.querySelectorAll('.book-item').forEach(el => el.classList.remove('selected'));
        document.querySelector(`[data-book-id="${bookId}"]`).classList.add('selected');
        
        this.addLogEntry({
            level: 'info',
            agent: 'dashboard',
            message: `Selected book: ${bookId}`,
            timestamp: new Date().toISOString()
        });
    }
    
    selectAgent(agentName) {
        // Highlight selected agent and show detailed view
        document.querySelectorAll('.agent-card').forEach(el => el.classList.remove('selected'));
        document.querySelector(`[data-agent-name="${agentName}"]`).classList.add('selected');
        
        this.addLogEntry({
            level: 'info',
            agent: 'dashboard',
            message: `Selected agent: ${agentName}`,
            timestamp: new Date().toISOString()
        });
    }
}

// Initialize dashboard when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new KnowledgeEngineeringDashboard();
});

// CSS for selected states
const style = document.createElement('style');
style.textContent = `
    .book-item.selected {
        background: rgba(76, 175, 80, 0.4) !important;
        border: 1px solid #4CAF50;
    }
    
    .agent-card.selected {
        background: rgba(76, 175, 80, 0.1) !important;
        border: 1px solid #4CAF50;
    }
`;
document.head.appendChild(style);