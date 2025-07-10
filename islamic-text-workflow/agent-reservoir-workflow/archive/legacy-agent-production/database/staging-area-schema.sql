-- Staging Area for Google Sheets to Library Integration
-- This table accepts title and author from Google Sheets and prepares books for library processing

-- ============================================================================
-- STAGING TABLE: book_intake_staging
-- ============================================================================

CREATE TABLE IF NOT EXISTS book_intake_staging (
    -- Primary identifiers
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Google Sheets input data (minimal required fields)
    title TEXT NOT NULL,
    author_name TEXT NOT NULL,
    
    -- Processing status and workflow
    intake_status TEXT NOT NULL DEFAULT 'pending' CHECK (
        intake_status IN ('pending', 'processing', 'validated', 'rejected', 'completed', 'error')
    ),
    
    -- Duplicate detection and validation
    duplicate_book_id UUID REFERENCES books(id), -- If duplicate found, reference existing book
    duplicate_check_status TEXT DEFAULT 'pending' CHECK (
        duplicate_check_status IN ('pending', 'no_duplicate', 'potential_duplicate', 'confirmed_duplicate')
    ),
    duplicate_similarity_score DECIMAL(3,2), -- 0.00 to 1.00 similarity score
    
    -- Author matching and standardization
    matched_author_id UUID REFERENCES authors(id), -- If author exists, reference
    author_match_confidence DECIMAL(3,2), -- 0.00 to 1.00 confidence score
    author_standardized_name TEXT, -- Standardized version of author name
    
    -- Google Sheets metadata
    google_sheets_row_id TEXT, -- Row identifier from Google Sheets
    google_sheets_source TEXT, -- Which sheet/tab this came from
    google_sheets_timestamp TIMESTAMP WITH TIME ZONE, -- When added to sheet
    
    -- Processing metadata
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE, -- When processing completed
    
    -- Validation and quality flags
    title_validation_status TEXT DEFAULT 'pending' CHECK (
        title_validation_status IN ('pending', 'valid', 'needs_review', 'invalid')
    ),
    author_validation_status TEXT DEFAULT 'pending' CHECK (
        author_validation_status IN ('pending', 'valid', 'needs_review', 'invalid')
    ),
    
    -- Processing notes and errors
    validation_notes TEXT,
    processing_errors TEXT,
    manual_review_required BOOLEAN DEFAULT FALSE,
    manual_review_reason TEXT,
    
    -- Book creation preparation
    prepared_for_books_table BOOLEAN DEFAULT FALSE,
    books_table_insert_ready BOOLEAN DEFAULT FALSE,
    target_book_id UUID -- UUID prepared for books table insertion
);

-- ============================================================================
-- INDEXES for Performance
-- ============================================================================

-- Primary lookup indexes
CREATE INDEX IF NOT EXISTS idx_book_intake_staging_status 
    ON book_intake_staging(intake_status);
    
CREATE INDEX IF NOT EXISTS idx_book_intake_staging_duplicate_check 
    ON book_intake_staging(duplicate_check_status);
    
CREATE INDEX IF NOT EXISTS idx_book_intake_staging_processing 
    ON book_intake_staging(intake_status, duplicate_check_status, manual_review_required);

-- Search and matching indexes
CREATE INDEX IF NOT EXISTS idx_book_intake_staging_title_search 
    ON book_intake_staging USING gin(to_tsvector('english', title));
    
CREATE INDEX IF NOT EXISTS idx_book_intake_staging_author_search 
    ON book_intake_staging USING gin(to_tsvector('english', author_name));

-- Google Sheets integration indexes
CREATE INDEX IF NOT EXISTS idx_book_intake_staging_google_source 
    ON book_intake_staging(google_sheets_source, google_sheets_row_id);

-- Timestamp indexes for monitoring
CREATE INDEX IF NOT EXISTS idx_book_intake_staging_created_at 
    ON book_intake_staging(created_at DESC);
    
CREATE INDEX IF NOT EXISTS idx_book_intake_staging_updated_at 
    ON book_intake_staging(updated_at DESC);

-- ============================================================================
-- TRIGGERS for Automation
-- ============================================================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_book_intake_staging_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_intake_staging_updated_at
    BEFORE UPDATE ON book_intake_staging
    FOR EACH ROW
    EXECUTE FUNCTION update_book_intake_staging_updated_at();

-- Auto-generate target_book_id when marked as ready
CREATE OR REPLACE FUNCTION prepare_target_book_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Generate target_book_id when marked as ready for books table
    IF NEW.books_table_insert_ready = TRUE AND OLD.books_table_insert_ready = FALSE THEN
        NEW.target_book_id = gen_random_uuid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prepare_target_book_id
    BEFORE UPDATE ON book_intake_staging
    FOR EACH ROW
    EXECUTE FUNCTION prepare_target_book_id();

-- ============================================================================
-- UTILITY FUNCTIONS for Processing
-- ============================================================================

-- Function to check for potential duplicates
CREATE OR REPLACE FUNCTION check_staging_duplicates(staging_title TEXT, staging_author TEXT)
RETURNS TABLE(
    book_id UUID,
    title TEXT,
    author_name TEXT,
    similarity_score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.title,
        b.author_name,
        GREATEST(
            similarity(staging_title, b.title),
            similarity(staging_author, COALESCE(b.author_name, ''))
        ) as similarity_score
    FROM books b
    WHERE 
        similarity(staging_title, b.title) > 0.6 
        OR similarity(staging_author, COALESCE(b.author_name, '')) > 0.7
    ORDER BY similarity_score DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Function to find matching authors
CREATE OR REPLACE FUNCTION find_matching_authors(staging_author_name TEXT)
RETURNS TABLE(
    author_id UUID,
    name TEXT,
    confidence_score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        similarity(staging_author_name, a.name) as confidence_score
    FROM authors a
    WHERE similarity(staging_author_name, a.name) > 0.7
    ORDER BY confidence_score DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- Function to validate staging entry
CREATE OR REPLACE FUNCTION validate_staging_entry(staging_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    entry_record RECORD;
    validation_passed BOOLEAN := TRUE;
    notes TEXT := '';
BEGIN
    SELECT * INTO entry_record FROM book_intake_staging WHERE id = staging_id;
    
    -- Title validation
    IF LENGTH(TRIM(entry_record.title)) < 3 THEN
        validation_passed := FALSE;
        notes := notes || 'Title too short. ';
    END IF;
    
    -- Author validation  
    IF LENGTH(TRIM(entry_record.author_name)) < 2 THEN
        validation_passed := FALSE;
        notes := notes || 'Author name too short. ';
    END IF;
    
    -- Update validation status
    UPDATE book_intake_staging SET
        title_validation_status = CASE WHEN validation_passed THEN 'valid' ELSE 'invalid' END,
        author_validation_status = CASE WHEN validation_passed THEN 'valid' ELSE 'invalid' END,
        validation_notes = notes,
        manual_review_required = NOT validation_passed,
        manual_review_reason = CASE WHEN NOT validation_passed THEN 'Validation failed: ' || notes ELSE NULL END
    WHERE id = staging_id;
    
    RETURN validation_passed;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VIEWS for Monitoring and Management
-- ============================================================================

-- Staging dashboard view
CREATE OR REPLACE VIEW staging_dashboard AS
SELECT 
    intake_status,
    duplicate_check_status,
    COUNT(*) as count,
    MIN(created_at) as oldest_entry,
    MAX(created_at) as newest_entry
FROM book_intake_staging 
GROUP BY intake_status, duplicate_check_status
ORDER BY intake_status, duplicate_check_status;

-- Ready for processing view
CREATE OR REPLACE VIEW staging_ready_for_processing AS
SELECT 
    id,
    title,
    author_name,
    target_book_id,
    created_at,
    google_sheets_source
FROM book_intake_staging
WHERE 
    intake_status = 'validated'
    AND duplicate_check_status = 'no_duplicate'
    AND books_table_insert_ready = TRUE
    AND manual_review_required = FALSE
ORDER BY created_at ASC;

-- Manual review queue view
CREATE OR REPLACE VIEW staging_manual_review_queue AS
SELECT 
    id,
    title,
    author_name,
    intake_status,
    manual_review_reason,
    validation_notes,
    created_at,
    google_sheets_source
FROM book_intake_staging
WHERE 
    manual_review_required = TRUE
    OR intake_status = 'error'
ORDER BY created_at ASC;

-- Duplicate detection view
CREATE OR REPLACE VIEW staging_potential_duplicates AS
SELECT 
    s.id as staging_id,
    s.title as staging_title,
    s.author_name as staging_author,
    b.id as existing_book_id,
    b.title as existing_title,
    b.author_name as existing_author,
    s.duplicate_similarity_score,
    s.created_at
FROM book_intake_staging s
LEFT JOIN books b ON s.duplicate_book_id = b.id
WHERE s.duplicate_check_status = 'potential_duplicate'
ORDER BY s.duplicate_similarity_score DESC, s.created_at ASC;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS
ALTER TABLE book_intake_staging ENABLE ROW LEVEL SECURITY;

-- Policy for service role (full access)
CREATE POLICY "Service role full access on book_intake_staging"
    ON book_intake_staging
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Policy for authenticated users (read access)
CREATE POLICY "Authenticated read access on book_intake_staging"
    ON book_intake_staging
    FOR SELECT
    TO authenticated
    USING (true);

-- Policy for librarians (full access)
CREATE POLICY "Librarians full access on book_intake_staging"
    ON book_intake_staging
    FOR ALL
    TO authenticated
    USING (is_librarian())
    WITH CHECK (is_librarian());

-- ============================================================================
-- SAMPLE DATA for Testing
-- ============================================================================

-- Insert sample staging entries for testing
INSERT INTO book_intake_staging (
    title, 
    author_name, 
    google_sheets_source, 
    google_sheets_row_id,
    google_sheets_timestamp
) VALUES 
(
    'Kitab al-Irshad', 
    'Sheikh al-Mufid', 
    'New Books Sheet 2025',
    'row_001',
    NOW() - INTERVAL '1 hour'
),
(
    'Al-Kafi',
    'Muhammad ibn Ya''qub al-Kulayni',
    'New Books Sheet 2025', 
    'row_002',
    NOW() - INTERVAL '30 minutes'
),
(
    'Nahj al-Balagha',
    'Compiled by Sharif al-Radi',
    'New Books Sheet 2025',
    'row_003', 
    NOW() - INTERVAL '15 minutes'
);

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Book Intake Staging System deployed successfully!';
    RAISE NOTICE 'Tables created: book_intake_staging';
    RAISE NOTICE 'Views created: staging_dashboard, staging_ready_for_processing, staging_manual_review_queue, staging_potential_duplicates';
    RAISE NOTICE 'Functions created: check_staging_duplicates, find_matching_authors, validate_staging_entry';
    RAISE NOTICE 'Sample data inserted: 3 test entries';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Configure Google Sheets integration with Make.com';
    RAISE NOTICE '2. Set up staging processing workflow';
    RAISE NOTICE '3. Test duplicate detection and validation';
    RAISE NOTICE '4. Deploy to production';
END $$;