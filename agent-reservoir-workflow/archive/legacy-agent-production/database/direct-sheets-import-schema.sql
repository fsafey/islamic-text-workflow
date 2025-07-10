-- Direct Google Sheets to Supabase Import System
-- Automatically generates UUIDs and creates books + authors from sheet data

-- ============================================================================
-- ENHANCED STAGING TABLE: book_author_staging
-- ============================================================================

CREATE TABLE IF NOT EXISTS book_author_staging (
    -- Primary identifiers (auto-generated)
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Google Sheets input data (required fields)
    title TEXT NOT NULL,
    author_name TEXT NOT NULL,
    
    -- Auto-generated UUIDs for target tables
    target_book_id UUID DEFAULT gen_random_uuid(),
    target_author_id UUID DEFAULT gen_random_uuid(),
    
    -- Processing status workflow
    processing_status TEXT NOT NULL DEFAULT 'new' CHECK (
        processing_status IN ('new', 'processing', 'author_created', 'book_created', 'completed', 'error', 'duplicate_detected')
    ),
    
    -- Duplicate detection results
    existing_book_id UUID REFERENCES books(id),
    existing_author_id UUID REFERENCES authors(id),
    duplicate_type TEXT CHECK (duplicate_type IN ('book_duplicate', 'author_exists', 'both_exist', 'no_duplicates')),
    similarity_scores JSONB, -- Store all similarity calculations
    
    -- Author processing
    author_created BOOLEAN DEFAULT FALSE,
    author_creation_successful BOOLEAN DEFAULT FALSE,
    author_standardized_name TEXT, -- Cleaned/standardized author name
    
    -- Book processing  
    book_created BOOLEAN DEFAULT FALSE,
    book_creation_successful BOOLEAN DEFAULT FALSE,
    book_standardized_title TEXT, -- Cleaned/standardized title
    
    -- Google Sheets metadata
    sheets_row_number INTEGER,
    sheets_source TEXT DEFAULT 'Google Sheets Import',
    sheets_imported_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Processing metadata
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- Error handling and validation
    validation_errors TEXT[],
    processing_errors TEXT[],
    manual_review_required BOOLEAN DEFAULT FALSE,
    manual_review_notes TEXT,
    
    -- Queue integration
    added_to_processing_queue BOOLEAN DEFAULT FALSE,
    processing_queue_id UUID
);

-- ============================================================================
-- INDEXES for Performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_book_author_staging_status 
    ON book_author_staging(processing_status);
    
CREATE INDEX IF NOT EXISTS idx_book_author_staging_duplicates 
    ON book_author_staging(duplicate_type, existing_book_id, existing_author_id);
    
CREATE INDEX IF NOT EXISTS idx_book_author_staging_uuids 
    ON book_author_staging(target_book_id, target_author_id);

CREATE INDEX IF NOT EXISTS idx_book_author_staging_created 
    ON book_author_staging(created_at DESC);

-- Search indexes for duplicate detection
CREATE INDEX IF NOT EXISTS idx_book_author_staging_title_search 
    ON book_author_staging USING gin(to_tsvector('english', title));
    
CREATE INDEX IF NOT EXISTS idx_book_author_staging_author_search 
    ON book_author_staging USING gin(to_tsvector('english', author_name));

-- ============================================================================
-- AUTOMATION TRIGGERS
-- ============================================================================

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_book_author_staging_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_author_staging_timestamp
    BEFORE UPDATE ON book_author_staging
    FOR EACH ROW
    EXECUTE FUNCTION update_book_author_staging_timestamp();

-- Auto-process new entries trigger
CREATE OR REPLACE FUNCTION auto_process_staging_entry()
RETURNS TRIGGER AS $$
BEGIN
    -- Only process 'new' entries
    IF NEW.processing_status = 'new' THEN
        -- Start processing
        NEW.processing_status = 'processing';
        
        -- Standardize names
        NEW.author_standardized_name = TRIM(REGEXP_REPLACE(NEW.author_name, '\s+', ' ', 'g'));
        NEW.book_standardized_title = TRIM(REGEXP_REPLACE(NEW.title, '\s+', ' ', 'g'));
        
        -- Schedule duplicate detection (will be handled by separate function)
        PERFORM pg_notify('staging_entry_ready', NEW.id::text);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_process_staging_entry
    BEFORE INSERT OR UPDATE ON book_author_staging
    FOR EACH ROW
    EXECUTE FUNCTION auto_process_staging_entry();

-- ============================================================================
-- DUPLICATE DETECTION FUNCTIONS
-- ============================================================================

-- Comprehensive duplicate detection
CREATE OR REPLACE FUNCTION detect_duplicates_and_matches(staging_id UUID)
RETURNS JSONB AS $$
DECLARE
    staging_record RECORD;
    book_matches RECORD;
    author_matches RECORD;
    result JSONB := '{}';
BEGIN
    -- Get staging record
    SELECT * INTO staging_record FROM book_author_staging WHERE id = staging_id;
    
    -- Check for existing books
    SELECT 
        b.id,
        b.title,
        b.author_name,
        similarity(staging_record.book_standardized_title, b.title) as title_similarity,
        similarity(staging_record.author_standardized_name, COALESCE(b.author_name, '')) as author_similarity
    INTO book_matches
    FROM books b
    WHERE similarity(staging_record.book_standardized_title, b.title) > 0.7
       OR (similarity(staging_record.author_standardized_name, COALESCE(b.author_name, '')) > 0.8 
           AND similarity(staging_record.book_standardized_title, b.title) > 0.5)
    ORDER BY (similarity(staging_record.book_standardized_title, b.title) + 
              similarity(staging_record.author_standardized_name, COALESCE(b.author_name, ''))) DESC
    LIMIT 1;
    
    -- Check for existing authors
    SELECT 
        a.id,
        a.name,
        similarity(staging_record.author_standardized_name, a.name) as name_similarity
    INTO author_matches
    FROM authors a
    WHERE similarity(staging_record.author_standardized_name, a.name) > 0.8
    ORDER BY similarity(staging_record.author_standardized_name, a.name) DESC
    LIMIT 1;
    
    -- Build result JSON
    result := jsonb_build_object(
        'book_match', CASE WHEN book_matches.id IS NOT NULL THEN
            jsonb_build_object(
                'id', book_matches.id,
                'title', book_matches.title,
                'author_name', book_matches.author_name,
                'title_similarity', book_matches.title_similarity,
                'author_similarity', book_matches.author_similarity
            )
        ELSE NULL END,
        'author_match', CASE WHEN author_matches.id IS NOT NULL THEN
            jsonb_build_object(
                'id', author_matches.id,
                'name', author_matches.name,
                'name_similarity', author_matches.name_similarity
            )
        ELSE NULL END
    );
    
    -- Update staging record with results
    UPDATE book_author_staging SET
        existing_book_id = book_matches.id,
        existing_author_id = author_matches.id,
        similarity_scores = result,
        duplicate_type = CASE 
            WHEN book_matches.id IS NOT NULL AND author_matches.id IS NOT NULL THEN 'both_exist'
            WHEN book_matches.id IS NOT NULL THEN 'book_duplicate'
            WHEN author_matches.id IS NOT NULL THEN 'author_exists'
            ELSE 'no_duplicates'
        END,
        processing_status = CASE 
            WHEN book_matches.id IS NOT NULL THEN 'duplicate_detected'
            ELSE 'processing'
        END
    WHERE id = staging_id;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- AUTHOR CREATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION create_author_from_staging(staging_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    staging_record RECORD;
    author_created BOOLEAN := FALSE;
BEGIN
    -- Get staging record
    SELECT * INTO staging_record FROM book_author_staging WHERE id = staging_id;
    
    -- Only create if author doesn't exist
    IF staging_record.existing_author_id IS NULL THEN
        BEGIN
            -- Insert new author
            INSERT INTO authors (id, name, created_at)
            VALUES (
                staging_record.target_author_id,
                staging_record.author_standardized_name,
                NOW()
            );
            
            author_created := TRUE;
            
            -- Update staging record
            UPDATE book_author_staging SET
                author_created = TRUE,
                author_creation_successful = TRUE,
                existing_author_id = staging_record.target_author_id
            WHERE id = staging_id;
            
        EXCEPTION WHEN OTHERS THEN
            -- Handle creation error
            UPDATE book_author_staging SET
                author_created = FALSE,
                author_creation_successful = FALSE,
                processing_errors = array_append(COALESCE(processing_errors, ARRAY[]::TEXT[]), 
                    'Author creation failed: ' || SQLERRM),
                processing_status = 'error'
            WHERE id = staging_id;
            
            author_created := FALSE;
        END;
    ELSE
        -- Author already exists, mark as successful
        UPDATE book_author_staging SET
            author_created = TRUE,
            author_creation_successful = TRUE
        WHERE id = staging_id;
        
        author_created := TRUE;
    END IF;
    
    RETURN author_created;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- BOOK CREATION FUNCTION  
-- ============================================================================

CREATE OR REPLACE FUNCTION create_book_from_staging(staging_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    staging_record RECORD;
    book_created BOOLEAN := FALSE;
BEGIN
    -- Get staging record
    SELECT * INTO staging_record FROM book_author_staging WHERE id = staging_id;
    
    -- Only create if book doesn't exist and author was created successfully
    IF staging_record.existing_book_id IS NULL AND staging_record.author_creation_successful THEN
        BEGIN
            -- Insert new book
            INSERT INTO books (
                id, 
                title, 
                author_name,
                author_id,
                status,
                created_at
            ) VALUES (
                staging_record.target_book_id,
                staging_record.book_standardized_title,
                staging_record.author_standardized_name,
                COALESCE(staging_record.existing_author_id, staging_record.target_author_id),
                'available',
                NOW()
            );
            
            book_created := TRUE;
            
            -- Update staging record
            UPDATE book_author_staging SET
                book_created = TRUE,
                book_creation_successful = TRUE,
                processing_status = 'book_created'
            WHERE id = staging_id;
            
        EXCEPTION WHEN OTHERS THEN
            -- Handle creation error
            UPDATE book_author_staging SET
                book_created = FALSE,
                book_creation_successful = FALSE,
                processing_errors = array_append(COALESCE(processing_errors, ARRAY[]::TEXT[]), 
                    'Book creation failed: ' || SQLERRM),
                processing_status = 'error'
            WHERE id = staging_id;
            
            book_created := FALSE;
        END;
    ELSE
        -- Book already exists or author creation failed
        UPDATE book_author_staging SET
            book_created = FALSE,
            book_creation_successful = FALSE,
            processing_errors = array_append(COALESCE(processing_errors, ARRAY[]::TEXT[]), 
                CASE 
                    WHEN staging_record.existing_book_id IS NOT NULL THEN 'Book already exists'
                    WHEN NOT staging_record.author_creation_successful THEN 'Author creation failed'
                    ELSE 'Unknown book creation issue'
                END)
        WHERE id = staging_id;
        
        book_created := FALSE;
    END IF;
    
    RETURN book_created;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- COMPLETE PROCESSING FUNCTION
-- ============================================================================

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
    IF staging_record.duplicate_type != 'book_duplicate' THEN
        book_success := create_book_from_staging(staging_id);
    ELSE
        book_success := FALSE;
    END IF;
    
    -- Step 4: Add to processing queue if book was created
    IF book_success THEN
        INSERT INTO book_processing_queue (book_id, status, priority)
        VALUES (staging_record.target_book_id, 'pending', 1)
        ON CONFLICT (book_id) DO NOTHING;
        
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

-- ============================================================================
-- BATCH PROCESSING FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION process_all_new_staging_entries()
RETURNS JSONB AS $$
DECLARE
    staging_entry RECORD;
    total_processed INTEGER := 0;
    successful_books INTEGER := 0;
    successful_authors INTEGER := 0;
    duplicates_detected INTEGER := 0;
    errors_encountered INTEGER := 0;
    processing_result JSONB;
    final_result JSONB;
BEGIN
    -- Process all 'new' or 'processing' entries
    FOR staging_entry IN 
        SELECT id FROM book_author_staging 
        WHERE processing_status IN ('new', 'processing')
        ORDER BY created_at ASC
    LOOP
        -- Process individual entry
        processing_result := process_staging_entry_complete(staging_entry.id);
        
        total_processed := total_processed + 1;
        
        -- Count results
        IF (processing_result->>'book_created')::boolean THEN
            successful_books := successful_books + 1;
        END IF;
        
        IF (processing_result->>'author_created')::boolean THEN
            successful_authors := successful_authors + 1;
        END IF;
        
        IF processing_result->>'final_status' = 'duplicate_detected' THEN
            duplicates_detected := duplicates_detected + 1;
        END IF;
        
        IF processing_result->>'final_status' = 'error' THEN
            errors_encountered := errors_encountered + 1;
        END IF;
    END LOOP;
    
    final_result := jsonb_build_object(
        'total_processed', total_processed,
        'successful_books', successful_books,
        'successful_authors', successful_authors,
        'duplicates_detected', duplicates_detected,
        'errors_encountered', errors_encountered,
        'processed_at', NOW()
    );
    
    RETURN final_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- MONITORING VIEWS
-- ============================================================================

-- Processing status dashboard
CREATE OR REPLACE VIEW staging_processing_dashboard AS
SELECT 
    processing_status,
    duplicate_type,
    COUNT(*) as count,
    COUNT(CASE WHEN author_creation_successful THEN 1 END) as authors_created,
    COUNT(CASE WHEN book_creation_successful THEN 1 END) as books_created,
    COUNT(CASE WHEN added_to_processing_queue THEN 1 END) as queued_for_enrichment
FROM book_author_staging
GROUP BY processing_status, duplicate_type
ORDER BY processing_status, duplicate_type;

-- Recent processing results
CREATE OR REPLACE VIEW staging_recent_results AS
SELECT 
    id,
    title,
    author_name,
    processing_status,
    duplicate_type,
    author_creation_successful,
    book_creation_successful,
    added_to_processing_queue,
    created_at,
    processed_at
FROM book_author_staging
WHERE created_at >= NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;

-- Error analysis view
CREATE OR REPLACE VIEW staging_errors_analysis AS
SELECT 
    id,
    title,
    author_name,
    processing_status,
    processing_errors,
    validation_errors,
    manual_review_required,
    manual_review_notes,
    created_at
FROM book_author_staging
WHERE processing_status = 'error' 
   OR array_length(processing_errors, 1) > 0
   OR manual_review_required = TRUE
ORDER BY created_at DESC;

-- Duplicate detection results
CREATE OR REPLACE VIEW staging_duplicates_detected AS
SELECT 
    s.id,
    s.title as staging_title,
    s.author_name as staging_author,
    s.duplicate_type,
    b.title as existing_book_title,
    b.author_name as existing_book_author,
    a.name as existing_author_name,
    s.similarity_scores,
    s.created_at
FROM book_author_staging s
LEFT JOIN books b ON s.existing_book_id = b.id
LEFT JOIN authors a ON s.existing_author_id = a.id
WHERE s.duplicate_type IS NOT NULL AND s.duplicate_type != 'no_duplicates'
ORDER BY s.created_at DESC;

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE book_author_staging ENABLE ROW LEVEL SECURITY;

-- Service role full access
CREATE POLICY "Service role full access on book_author_staging"
    ON book_author_staging FOR ALL TO service_role
    USING (true) WITH CHECK (true);

-- Authenticated users read access
CREATE POLICY "Authenticated read access on book_author_staging"
    ON book_author_staging FOR SELECT TO authenticated
    USING (true);

-- Librarians full access
CREATE POLICY "Librarians full access on book_author_staging"
    ON book_author_staging FOR ALL TO authenticated
    USING (is_librarian()) WITH CHECK (is_librarian());

-- ============================================================================
-- SAMPLE DATA AND TESTING
-- ============================================================================

-- Insert sample data for testing
INSERT INTO book_author_staging (title, author_name, sheets_row_number, sheets_source) VALUES
('Kitab al-Irshad', 'Sheikh al-Mufid', 1, 'Test Import'),
('Al-Kafi', 'Muhammad ibn Ya''qub al-Kulayni', 2, 'Test Import'),
('Nahj al-Balagha', 'Compiled by Sharif al-Radi', 3, 'Test Import'),
('Bihar al-Anwar', 'Muhammad Baqir al-Majlisi', 4, 'Test Import'),
('Man la Yahduruhu al-Faqih', 'Ibn Babawayh al-Qummi', 5, 'Test Import');

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Direct Google Sheets Import System deployed successfully!';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Main table: book_author_staging';
    RAISE NOTICE 'Key functions:';
    RAISE NOTICE '- process_staging_entry_complete(uuid)';
    RAISE NOTICE '- process_all_new_staging_entries()';
    RAISE NOTICE '- detect_duplicates_and_matches(uuid)';
    RAISE NOTICE '- create_author_from_staging(uuid)';
    RAISE NOTICE '- create_book_from_staging(uuid)';
    RAISE NOTICE '';
    RAISE NOTICE 'Monitoring views:';
    RAISE NOTICE '- staging_processing_dashboard';
    RAISE NOTICE '- staging_recent_results';
    RAISE NOTICE '- staging_errors_analysis';
    RAISE NOTICE '- staging_duplicates_detected';
    RAISE NOTICE '';
    RAISE NOTICE 'Sample data: 5 test books inserted with processing_status = "new"';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Configure Google Sheets direct integration with Supabase';
    RAISE NOTICE '2. Test processing: SELECT process_all_new_staging_entries();';
    RAISE NOTICE '3. Monitor results: SELECT * FROM staging_processing_dashboard;';
    RAISE NOTICE '4. Set up automatic processing triggers';
    RAISE NOTICE '=================================================================';
END $$;