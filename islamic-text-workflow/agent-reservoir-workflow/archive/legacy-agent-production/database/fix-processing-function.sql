-- Fix the queue insertion in the processing function
CREATE OR REPLACE FUNCTION process_staging_entry_complete(staging_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB := '{}';
    duplicate_results JSONB;
    author_success BOOLEAN;
    book_success BOOLEAN;
    staging_record RECORD;
BEGIN
    -- Step 1: Detect duplicates
    duplicate_results := detect_duplicates_and_matches(staging_id);
    
    -- Get updated staging record
    SELECT * INTO staging_record FROM book_author_staging WHERE id = staging_id;
    
    -- Step 2: Create author if needed
    author_success := create_author_from_staging(staging_id);
    
    -- Step 3: Create book if no duplicates
    IF staging_record.duplicate_type IS DISTINCT FROM 'book_duplicate' THEN
        book_success := create_book_from_staging(staging_id);
    ELSE
        book_success := FALSE;
    END IF;
    
    -- Step 4: Add to processing queue if book was created
    IF book_success THEN
        -- Check if already in queue
        IF NOT EXISTS (SELECT 1 FROM book_processing_queue WHERE book_id = staging_record.target_book_id) THEN
            INSERT INTO book_processing_queue (book_id, status, priority)
            VALUES (staging_record.target_book_id, 'pending', 1);
        END IF;
        
        UPDATE book_author_staging SET
            added_to_processing_queue = TRUE,
            processing_status = 'completed',
            processed_at = NOW()
        WHERE id = staging_id;
    END IF;
    
    -- Build result
    result := jsonb_build_object(
        'staging_id', staging_id,
        'duplicate_results', duplicate_results,
        'author_created', author_success,
        'book_created', book_success,
        'added_to_queue', book_success,
        'final_status', CASE 
            WHEN book_success THEN 'completed'
            WHEN staging_record.duplicate_type = 'book_duplicate' THEN 'duplicate_detected'
            ELSE 'error'
        END
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;