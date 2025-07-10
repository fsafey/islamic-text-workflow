-- ======================================================================
-- POPULATE BOOK PROCESSING QUEUE
-- Adds all unprocessed books to the distributed pipeline queue
-- ======================================================================

-- First, let's see what books need processing
SELECT 
    'Books needing enrichment:' as status,
    COUNT(*) as count
FROM books 
WHERE (title_alias IS NULL OR keywords IS NULL OR description IS NULL)
  AND title IS NOT NULL 
  AND author_name IS NOT NULL;

-- Add all unprocessed books to the queue
INSERT INTO book_processing_queue (book_id, priority, created_at)
SELECT 
    b.id as book_id,
    CASE 
        -- Higher priority for books with some existing data
        WHEN b.description IS NOT NULL THEN 1
        WHEN b.title_alias IS NOT NULL THEN 2
        ELSE 0
    END as priority,
    NOW() as created_at
FROM books b
WHERE (b.title_alias IS NULL OR b.keywords IS NULL OR b.description IS NULL)
  AND b.title IS NOT NULL 
  AND b.author_name IS NOT NULL
  -- Avoid duplicates if script is run multiple times
  AND NOT EXISTS (
    SELECT 1 FROM book_processing_queue bpq 
    WHERE bpq.book_id = b.id
  )
ORDER BY 
    -- Process books with existing data first
    CASE WHEN b.description IS NOT NULL THEN 1 ELSE 2 END,
    b.created_at ASC;

-- Show queue statistics after population
SELECT 
    'Queue populated successfully' as status,
    COUNT(*) as total_books_queued
FROM book_processing_queue 
WHERE status = 'pending';

-- Show priority distribution
SELECT 
    priority,
    COUNT(*) as book_count,
    CASE priority
        WHEN 0 THEN 'No existing data'
        WHEN 1 THEN 'Has description'
        WHEN 2 THEN 'Has title alias'
        ELSE 'Other'
    END as priority_description
FROM book_processing_queue 
WHERE status = 'pending'
GROUP BY priority
ORDER BY priority;

-- Show sample of queued books
SELECT 
    bpq.id as queue_id,
    bpq.priority,
    b.title,
    b.author_name,
    CASE 
        WHEN b.title_alias IS NOT NULL THEN '✓' ELSE '✗' 
    END as has_title_alias,
    CASE 
        WHEN b.keywords IS NOT NULL THEN '✓' ELSE '✗' 
    END as has_keywords,
    CASE 
        WHEN b.description IS NOT NULL THEN '✓' ELSE '✗' 
    END as has_description
FROM book_processing_queue bpq
JOIN books b ON bpq.book_id = b.id
WHERE bpq.status = 'pending'
ORDER BY bpq.priority DESC, bpq.created_at ASC
LIMIT 10;

-- ======================================================================
-- QUEUE MANAGEMENT HELPERS
-- ======================================================================

-- Function to reset failed books back to pending
CREATE OR REPLACE FUNCTION reset_failed_books()
RETURNS INTEGER AS $$
DECLARE
    reset_count INTEGER;
BEGIN
    UPDATE book_processing_queue 
    SET 
        status = 'pending',
        started_at = NULL,
        error_count = error_count + 1,
        last_error = 'Reset from failed status',
        updated_at = NOW()
    WHERE status = 'failed' 
      AND error_count < 3; -- Only retry books that haven't failed too many times
    
    GET DIAGNOSTICS reset_count = ROW_COUNT;
    RETURN reset_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get next book for processing
CREATE OR REPLACE FUNCTION get_next_book_for_processing()
RETURNS TABLE(
    queue_id UUID,
    book_id UUID,
    title TEXT,
    author_name TEXT,
    priority INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bpq.id,
        bpq.book_id,
        b.title,
        b.author_name,
        bpq.priority
    FROM book_processing_queue bpq
    JOIN books b ON bpq.book_id = b.id
    WHERE bpq.status = 'pending'
    ORDER BY bpq.priority DESC, bpq.created_at ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to get queue statistics
CREATE OR REPLACE FUNCTION get_queue_stats()
RETURNS TABLE(
    status TEXT,
    count BIGINT,
    percentage NUMERIC
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_count FROM book_processing_queue;
    
    RETURN QUERY
    SELECT 
        bpq.status,
        COUNT(*) as count,
        ROUND((COUNT(*) * 100.0 / total_count), 2) as percentage
    FROM book_processing_queue bpq
    GROUP BY bpq.status
    ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;

-- ======================================================================
-- VERIFICATION AND MONITORING
-- ======================================================================

-- Quick status check
SELECT 'Queue Status Summary:' as info;
SELECT * FROM get_queue_stats();

-- Show books ready for processing
SELECT 
    'Books ready for processing:' as info,
    COUNT(*) as ready_count
FROM book_processing_queue 
WHERE status = 'pending';

-- Show any books currently being processed
SELECT 
    'Books currently being processed:' as info,
    status,
    COUNT(*) as count
FROM book_processing_queue 
WHERE status IN ('research', 'analysis', 'sql')
GROUP BY status;

-- ======================================================================
-- SAMPLE QUERIES FOR MAKE.COM SCENARIOS
-- ======================================================================

-- Query for Make.com Orchestrator to get next book
-- Use this in Make.com HTTP module:
/*
SELECT 
    bpq.id as queue_id,
    bpq.book_id,
    b.title,
    b.author_name,
    bpq.priority
FROM book_processing_queue bpq
JOIN books b ON bpq.book_id = b.id
WHERE bpq.status = 'pending'
ORDER BY bpq.priority DESC, bpq.created_at ASC
LIMIT 1;
*/

COMMENT ON FUNCTION get_next_book_for_processing() IS 'Used by Make.com orchestrator to get next book for processing';
COMMENT ON FUNCTION reset_failed_books() IS 'Administrative function to retry failed books';
COMMENT ON FUNCTION get_queue_stats() IS 'Monitor overall queue health and progress';