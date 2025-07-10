-- ======================================================================
-- ISLAMIC TEXT PROCESSING - DISTRIBUTED PIPELINE DATABASE SETUP
-- Creates tables for Make.com + Local Agent coordination
-- ======================================================================

-- Book Processing Queue Table
CREATE TABLE IF NOT EXISTS book_processing_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'research', 'analysis', 'sql', 'completed', 'failed', 'archived')),
  priority INTEGER DEFAULT 0,
  
  -- Task IDs for tracking each stage
  research_task_id UUID,
  analysis_task_id UUID,
  sql_task_id UUID,
  
  -- Timing information
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  
  -- Error handling
  error_count INTEGER DEFAULT 0,
  last_error TEXT,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Agent Task Logs Table
CREATE TABLE IF NOT EXISTS agent_task_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL,
  task_type TEXT NOT NULL CHECK (task_type IN ('research', 'analysis', 'sql')),
  book_id UUID REFERENCES books(id),
  
  -- Agent information
  agent_id TEXT DEFAULT 'local-agent',
  status TEXT CHECK (status IN ('started', 'completed', 'failed')),
  
  -- Task data
  input_data JSONB,
  output_data JSONB,
  processing_time INTEGER, -- seconds
  error_message TEXT,
  
  -- Timing
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);

-- Webhook Execution Logs Table
CREATE TABLE IF NOT EXISTS webhook_execution_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  webhook_type TEXT NOT NULL CHECK (webhook_type IN ('research', 'analysis', 'sql')),
  task_id UUID NOT NULL,
  
  -- Webhook details
  webhook_url TEXT NOT NULL,
  payload JSONB,
  response_status INTEGER,
  response_body TEXT,
  
  -- Timing
  execution_time INTEGER, -- milliseconds
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_queue_status ON book_processing_queue(status);
CREATE INDEX IF NOT EXISTS idx_queue_priority ON book_processing_queue(priority DESC, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_queue_book_id ON book_processing_queue(book_id);
CREATE INDEX IF NOT EXISTS idx_queue_task_ids ON book_processing_queue(research_task_id, analysis_task_id, sql_task_id);

CREATE INDEX IF NOT EXISTS idx_task_logs_task_id ON agent_task_logs(task_id);
CREATE INDEX IF NOT EXISTS idx_task_logs_type_status ON agent_task_logs(task_type, status);
CREATE INDEX IF NOT EXISTS idx_task_logs_book_id ON agent_task_logs(book_id);

CREATE INDEX IF NOT EXISTS idx_webhook_logs_type ON webhook_execution_logs(webhook_type);
CREATE INDEX IF NOT EXISTS idx_webhook_logs_task_id ON webhook_execution_logs(task_id);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_queue_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_book_processing_queue_updated_at
  BEFORE UPDATE ON book_processing_queue
  FOR EACH ROW
  EXECUTE FUNCTION update_queue_updated_at();

-- Insert sample monitoring views
CREATE OR REPLACE VIEW queue_status_summary AS
SELECT 
  status,
  COUNT(*) as count,
  AVG(EXTRACT(EPOCH FROM (COALESCE(completed_at, NOW()) - started_at))) as avg_processing_time_seconds
FROM book_processing_queue 
WHERE started_at IS NOT NULL
GROUP BY status;

CREATE OR REPLACE VIEW agent_performance_summary AS
SELECT 
  task_type,
  status,
  COUNT(*) as total_tasks,
  AVG(processing_time) as avg_processing_time,
  MAX(processing_time) as max_processing_time,
  MIN(processing_time) as min_processing_time
FROM agent_task_logs 
GROUP BY task_type, status
ORDER BY task_type, status;

-- Sample queries for monitoring
COMMENT ON VIEW queue_status_summary IS 'Monitor queue status and average processing times';
COMMENT ON VIEW agent_performance_summary IS 'Monitor agent performance by task type';

-- Grant permissions (adjust as needed for your setup)
GRANT SELECT, INSERT, UPDATE ON book_processing_queue TO authenticated;
GRANT SELECT, INSERT, UPDATE ON agent_task_logs TO authenticated;
GRANT SELECT, INSERT ON webhook_execution_logs TO authenticated;
GRANT SELECT ON queue_status_summary TO authenticated;
GRANT SELECT ON agent_performance_summary TO authenticated;

-- ======================================================================
-- SETUP VERIFICATION QUERIES
-- ======================================================================

-- Check if tables were created successfully
SELECT 
  table_name,
  table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('book_processing_queue', 'agent_task_logs', 'webhook_execution_logs')
ORDER BY table_name;

-- Check indexes
SELECT 
  schemaname,
  tablename,
  indexname
FROM pg_indexes 
WHERE tablename IN ('book_processing_queue', 'agent_task_logs', 'webhook_execution_logs')
ORDER BY tablename, indexname;

COMMENT ON TABLE book_processing_queue IS 'Queue for managing distributed Islamic text processing pipeline';
COMMENT ON TABLE agent_task_logs IS 'Logs for tracking individual agent task execution';
COMMENT ON TABLE webhook_execution_logs IS 'Logs for webhook calls between Make.com and local agents';