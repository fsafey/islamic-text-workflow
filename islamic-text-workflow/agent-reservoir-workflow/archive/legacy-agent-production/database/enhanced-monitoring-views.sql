-- Enhanced monitoring views for agent pipeline

-- Agent performance dashboard view
CREATE OR REPLACE VIEW agent_performance_dashboard AS
SELECT 
  processing_stage,
  COUNT(*) as book_count,
  AVG(EXTRACT(EPOCH FROM (updated_at - created_at))/60) as avg_processing_minutes,
  COUNT(CASE WHEN processing_errors != '[]'::jsonb THEN 1 END) as error_count
FROM book_enrichment_reservoir 
GROUP BY processing_stage;

-- Agent throughput tracking
CREATE OR REPLACE VIEW agent_throughput_metrics AS
SELECT 
  unnest(agents_completed) as agent,
  COUNT(*) as books_processed,
  AVG(EXTRACT(EPOCH FROM (updated_at - created_at))/60) as avg_time_minutes
FROM book_enrichment_reservoir 
WHERE agents_completed != '{}'
GROUP BY agent;

-- Bottleneck detection view
CREATE OR REPLACE VIEW pipeline_bottlenecks AS
WITH stage_times AS (
  SELECT 
    processing_stage,
    AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) as avg_duration,
    COUNT(*) as queue_size,
    COUNT(CASE WHEN updated_at < NOW() - INTERVAL '30 minutes' THEN 1 END) as stuck_books
  FROM book_enrichment_reservoir 
  GROUP BY processing_stage
)
SELECT 
  processing_stage,
  queue_size,
  avg_duration,
  stuck_books,
  CASE 
    WHEN avg_duration > 1800 THEN 'SLOW'  -- > 30 minutes
    WHEN queue_size > 100 THEN 'BACKLOG'
    WHEN stuck_books > 5 THEN 'STUCK'
    ELSE 'NORMAL'
  END as bottleneck_status
FROM stage_times;

-- Hourly processing stats for trends
CREATE OR REPLACE VIEW hourly_processing_stats AS
SELECT 
  date_trunc('hour', updated_at) as hour,
  processing_stage,
  COUNT(*) as books_processed,
  AVG(EXTRACT(EPOCH FROM (updated_at - created_at))/60) as avg_processing_minutes
FROM book_enrichment_reservoir 
WHERE updated_at >= NOW() - INTERVAL '24 hours'
GROUP BY hour, processing_stage
ORDER BY hour DESC;

-- Agent quality metrics summary
CREATE OR REPLACE VIEW agent_quality_summary AS
SELECT 
  processing_stage,
  COUNT(*) as total_books,
  COUNT(CASE WHEN flowchart_analysis IS NOT NULL THEN 1 END) as flowchart_completed,
  COUNT(CASE WHEN network_analysis IS NOT NULL THEN 1 END) as network_completed,
  COUNT(CASE WHEN metadata_findings IS NOT NULL THEN 1 END) as metadata_completed,
  COUNT(CASE WHEN content_synthesis IS NOT NULL THEN 1 END) as synthesis_completed,
  ROUND(
    (COUNT(CASE WHEN flowchart_analysis IS NOT NULL THEN 1 END)::float / 
     NULLIF(COUNT(*), 0) * 100), 2
  ) as flowchart_completion_rate,
  ROUND(
    (COUNT(CASE WHEN network_analysis IS NOT NULL THEN 1 END)::float / 
     NULLIF(COUNT(*), 0) * 100), 2
  ) as network_completion_rate
FROM book_enrichment_reservoir
GROUP BY processing_stage;