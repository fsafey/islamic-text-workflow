/**
 * API Endpoints for Knowledge Engineering Dashboard
 * Provides orchestrator proxy and enhanced monitoring capabilities
 */

// ====================
// Orchestrator Proxy Functions
// ====================

async function proxyToOrchestrator(endpoint, method = 'GET', body = null) {
    try {
        const url = `${CONFIG.ORCHESTRATOR_URL}${endpoint}`;
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
            }
        };
        
        if (body) {
            options.body = JSON.stringify(body);
        }
        
        const response = await fetch(url, options);
        
        if (!response.ok) {
            throw new Error(`Orchestrator request failed: ${response.status}`);
        }
        
        return await response.json();
        
    } catch (error) {
        console.error(`Error proxying to orchestrator (${endpoint}):`, error);
        throw error;
    }
}

// ====================
// Dashboard API Endpoints
// ====================

// Health check for dashboard
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'islamic-text-dashboard',
        timestamp: new Date().toISOString(),
        orchestrator_url: CONFIG.ORCHESTRATOR_URL,
        uptime: process.uptime()
    });
});

// Get system stats (enhanced)
app.get('/system-stats', async (req, res) => {
    try {
        // Get basic stats from orchestrator
        const reservoirData = await proxyToOrchestrator('/reservoir-status');
        const agentsData = await proxyToOrchestrator('/agents-health');
        
        // Get enhanced stats from database
        const enhancedStats = await getEnhancedSystemStats();
        
        res.json({
            ...reservoirData,
            ...agentsData,
            ...enhancedStats,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        res.status(500).json({
            error: 'Failed to get system stats',
            message: error.message
        });
    }
});

// Get reservoir status (proxy)
app.get('/reservoir-status', async (req, res) => {
    try {
        const data = await proxyToOrchestrator('/reservoir-status');
        res.json(data);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to get reservoir status',
            message: error.message
        });
    }
});

// Get agents health (proxy)
app.get('/agents-health', async (req, res) => {
    try {
        const data = await proxyToOrchestrator('/agents-health');
        res.json(data);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to get agents health',
            message: error.message
        });
    }
});

// Get processing queue (enhanced)
app.get('/processing-queue', async (req, res) => {
    try {
        // Get basic queue data from orchestrator
        const basicData = await proxyToOrchestrator('/pipeline-status');
        
        // Get enhanced current books from database
        const currentBooks = await getCurrentProcessingBooks();
        
        res.json({
            ...basicData,
            current_books: currentBooks,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        res.status(500).json({
            error: 'Failed to get processing queue',
            message: error.message
        });
    }
});

// Get system logs (enhanced)
app.get('/system-logs', async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 50;
        const level = req.query.level || null;
        
        const logs = await getSystemLogs(limit, level);
        
        res.json({
            logs,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        res.status(500).json({
            error: 'Failed to get system logs',
            message: error.message
        });
    }
});

// Start assembly (proxy)
app.post('/start-assembly', async (req, res) => {
    try {
        const data = await proxyToOrchestrator('/start-assembly', 'POST');
        
        // Log to dashboard
        await logDashboardAction('start-assembly', 'Pipeline started via dashboard');
        
        res.json(data);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to start assembly',
            message: error.message
        });
    }
});

// Stop pipeline (proxy)
app.post('/stop-pipeline', async (req, res) => {
    try {
        const data = await proxyToOrchestrator('/stop-pipeline', 'POST');
        
        // Log to dashboard
        await logDashboardAction('stop-pipeline', 'Pipeline stopped via dashboard');
        
        res.json(data);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to stop pipeline',
            message: error.message
        });
    }
});

// Initialize reservoir (proxy)
app.post('/initialize-reservoir', async (req, res) => {
    try {
        const data = await proxyToOrchestrator('/initialize-reservoir', 'POST');
        
        // Log to dashboard
        await logDashboardAction('initialize-reservoir', 'Reservoir initialized via dashboard');
        
        res.json(data);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to initialize reservoir',
            message: error.message
        });
    }
});

// Get book details (enhanced)
app.get('/book/:bookId', async (req, res) => {
    try {
        const bookId = req.params.bookId;
        const bookDetails = await getBookDetails(bookId);
        
        res.json(bookDetails);
        
    } catch (error) {
        res.status(500).json({
            error: 'Failed to get book details',
            message: error.message
        });
    }
});

// Get agent details (enhanced)
app.get('/agent/:agentName', async (req, res) => {
    try {
        const agentName = req.params.agentName;
        
        // Get basic agent data from orchestrator
        const agentsData = await proxyToOrchestrator('/agents-health');
        const agentData = agentsData.agents[agentName];
        
        if (!agentData) {
            return res.status(404).json({
                error: 'Agent not found',
                agent: agentName
            });
        }
        
        // Get enhanced agent data from database
        const enhancedData = await getAgentDetails(agentName);
        
        res.json({
            ...agentData,
            ...enhancedData,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        res.status(500).json({
            error: 'Failed to get agent details',
            message: error.message
        });
    }
});

// ====================
// Enhanced Database Functions
// ====================

async function getEnhancedSystemStats() {
    if (!supabase) {
        return {
            error: 'Database not available',
            fallback: true
        };
    }
    
    try {
        // Get processing rates
        const { data: processingData, error: processingError } = await supabase
            .from('book_enrichment_reservoir')
            .select('processing_stage, updated_at, created_at')
            .order('updated_at', { ascending: false })
            .limit(100);
        
        if (processingError) throw processingError;
        
        // Calculate processing rate
        const now = new Date();
        const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
        
        const recentProcessing = processingData.filter(book => 
            new Date(book.updated_at) > oneHourAgo
        );
        
        const processingRate = recentProcessing.length;
        
        // Get stage distribution
        const stageDistribution = processingData.reduce((acc, book) => {
            acc[book.processing_stage] = (acc[book.processing_stage] || 0) + 1;
            return acc;
        }, {});
        
        // Calculate average processing time
        const completedBooks = processingData.filter(book => 
            book.processing_stage === 'completed'
        );
        
        const avgProcessingTime = completedBooks.reduce((acc, book) => {
            const processingTime = new Date(book.updated_at) - new Date(book.created_at);
            return acc + processingTime;
        }, 0) / completedBooks.length;
        
        return {
            processing_rate: `${processingRate}/hr`,
            stage_distribution: stageDistribution,
            avg_processing_time: Math.round(avgProcessingTime / 60000), // minutes
            total_processed: completedBooks.length,
            enhanced: true
        };
        
    } catch (error) {
        console.error('Error getting enhanced system stats:', error);
        return {
            error: error.message,
            fallback: true
        };
    }
}

async function getCurrentProcessingBooks() {
    if (!supabase) {
        return [];
    }
    
    try {
        const { data, error } = await supabase
            .from('book_enrichment_reservoir')
            .select(`
                id,
                title,
                author_name,
                processing_stage,
                created_at,
                updated_at,
                flowchart_completed,
                network_completed,
                metadata_completed,
                synthesis_completed
            `)
            .in('processing_stage', ['flowchart', 'network', 'metadata', 'synthesis', 'pipeline'])
            .order('updated_at', { ascending: false })
            .limit(10);
        
        if (error) throw error;
        
        return data.map(book => ({
            id: book.id,
            title: book.title,
            author: book.author_name,
            current_stage: book.processing_stage,
            current_agent: mapStageToAgent(book.processing_stage),
            progress: calculateBookProgress(book),
            processing_time: calculateProcessingTime(book.created_at, book.updated_at),
            stages_completed: getCompletedStages(book)
        }));
        
    } catch (error) {
        console.error('Error getting current processing books:', error);
        return [];
    }
}

async function getSystemLogs(limit = 50, level = null) {
    // For now, return mock logs - in production, you'd implement proper logging
    const mockLogs = [
        {
            level: 'info',
            agent: 'dashboard',
            message: 'Dashboard initialized successfully',
            timestamp: new Date().toISOString()
        },
        {
            level: 'info',
            agent: 'flowchart_mapper',
            message: 'Processing book: Ihya Ulum al-Din',
            timestamp: new Date(Date.now() - 30000).toISOString()
        },
        {
            level: 'info',
            agent: 'network_mapper',
            message: 'Completed network analysis for book ID 123',
            timestamp: new Date(Date.now() - 60000).toISOString()
        }
    ];
    
    return mockLogs.slice(0, limit);
}

async function getBookDetails(bookId) {
    if (!supabase) {
        return {
            error: 'Database not available'
        };
    }
    
    try {
        const { data, error } = await supabase
            .from('book_enrichment_reservoir')
            .select('*')
            .eq('id', bookId)
            .single();
        
        if (error) throw error;
        
        return {
            ...data,
            processing_history: await getBookProcessingHistory(bookId),
            current_agent: mapStageToAgent(data.processing_stage),
            progress: calculateBookProgress(data)
        };
        
    } catch (error) {
        console.error('Error getting book details:', error);
        return {
            error: error.message
        };
    }
}

async function getAgentDetails(agentName) {
    if (!supabase) {
        return {
            error: 'Database not available'
        };
    }
    
    try {
        // Get recent books processed by this agent
        const stage = mapAgentToStage(agentName);
        
        const { data, error } = await supabase
            .from('book_enrichment_reservoir')
            .select('id, title, author_name, updated_at')
            .eq('processing_stage', stage)
            .order('updated_at', { ascending: false })
            .limit(10);
        
        if (error) throw error;
        
        return {
            recent_books: data,
            processing_stage: stage,
            enhanced: true
        };
        
    } catch (error) {
        console.error('Error getting agent details:', error);
        return {
            error: error.message
        };
    }
}

async function logDashboardAction(action, message) {
    console.log(`📊 Dashboard Action: ${action} - ${message}`);
    
    // In production, you'd log to database
    dashboardState.logs.unshift({
        level: 'info',
        agent: 'dashboard',
        message: `${action}: ${message}`,
        timestamp: new Date().toISOString()
    });
    
    // Keep only last 100 logs
    if (dashboardState.logs.length > 100) {
        dashboardState.logs = dashboardState.logs.slice(0, 100);
    }
}

// ====================
// Utility Functions
// ====================

function mapStageToAgent(stage) {
    const mapping = {
        'flowchart': 'flowchart_mapper',
        'network': 'network_mapper',
        'metadata': 'metadata_hunter',
        'synthesis': 'content_synthesizer',
        'pipeline': 'data_pipeline'
    };
    
    return mapping[stage] || 'unknown';
}

function mapAgentToStage(agent) {
    const mapping = {
        'flowchart_mapper': 'flowchart',
        'network_mapper': 'network',
        'metadata_hunter': 'metadata',
        'content_synthesizer': 'synthesis',
        'data_pipeline': 'pipeline'
    };
    
    return mapping[agent] || 'unknown';
}

function calculateBookProgress(book) {
    const stages = ['flowchart', 'network', 'metadata', 'synthesis', 'pipeline'];
    const currentStageIndex = stages.indexOf(book.processing_stage);
    
    if (currentStageIndex === -1) return 0;
    
    const completedStages = currentStageIndex;
    const totalStages = stages.length;
    
    return Math.round((completedStages / totalStages) * 100);
}

function calculateProcessingTime(createdAt, updatedAt) {
    const start = new Date(createdAt);
    const end = new Date(updatedAt);
    const diffMinutes = Math.round((end - start) / 60000);
    
    if (diffMinutes < 60) {
        return `${diffMinutes}m`;
    } else {
        const hours = Math.floor(diffMinutes / 60);
        const minutes = diffMinutes % 60;
        return `${hours}h ${minutes}m`;
    }
}

function getCompletedStages(book) {
    const stages = [];
    
    if (book.flowchart_completed) stages.push('flowchart');
    if (book.network_completed) stages.push('network');
    if (book.metadata_completed) stages.push('metadata');
    if (book.synthesis_completed) stages.push('synthesis');
    
    return stages;
}

async function getBookProcessingHistory(bookId) {
    // Mock processing history - in production, you'd have a proper audit log
    return [
        {
            stage: 'flowchart',
            started_at: new Date(Date.now() - 300000).toISOString(),
            completed_at: new Date(Date.now() - 240000).toISOString(),
            agent: 'flowchart_mapper',
            status: 'completed'
        },
        {
            stage: 'network',
            started_at: new Date(Date.now() - 240000).toISOString(),
            completed_at: new Date(Date.now() - 180000).toISOString(),
            agent: 'network_mapper',
            status: 'completed'
        },
        {
            stage: 'metadata',
            started_at: new Date(Date.now() - 180000).toISOString(),
            completed_at: null,
            agent: 'metadata_hunter',
            status: 'processing'
        }
    ];
}

module.exports = {
    proxyToOrchestrator,
    getEnhancedSystemStats,
    getCurrentProcessingBooks,
    getSystemLogs,
    getBookDetails,
    getAgentDetails,
    logDashboardAction
};