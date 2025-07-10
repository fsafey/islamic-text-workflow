-- =============================================
-- STREAMLINED 25-FIELD SCHEMA
-- Islamic Text Processing Workflow - Essential Fields Only
-- Purpose: Capture core workflow requirements with 83% field reduction (155 → 25)
-- =============================================

-- Drop existing tables to recreate with streamlined structure
DROP TABLE IF EXISTS book_enrichment_results_streamlined CASCADE;
DROP TABLE IF EXISTS book_analysis_results_streamlined CASCADE;

-- =============================================
-- Stage 1: Streamlined Analysis Results (8 Essential Fields)
-- =============================================
CREATE TABLE IF NOT EXISTS book_analysis_results_streamlined (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    
    -- INPUT METADATA
    input_title TEXT NOT NULL,
    input_author TEXT NOT NULL,
    processing_timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- === STAGE 1: CORE ANALYSIS RESULTS (8 ESSENTIAL FIELDS) ===
    
    -- Core Analysis Components (derived from Academic-Analysis-Prompt-V4-Hybrid.md)
    central_node TEXT, -- Book's single most important thesis/subject/argument
    genre_classification TEXT, -- Precise work type identification
    methodological_foundation TEXT, -- Specific sources and analytical methods
    scholarly_perspective TEXT, -- Author's school of thought/intellectual tradition
    network_description TEXT, -- Paragraph explaining conceptual connections
    
    -- Quality Gates
    analysis_quality_score INTEGER CHECK (analysis_quality_score >= 1 AND analysis_quality_score <= 10),
    quality_gate_passed BOOLEAN DEFAULT false, -- Quality threshold (≥7) met
    ready_for_stage2 BOOLEAN DEFAULT false, -- Ready for enrichment processing
    
    -- === AUDIT TRAIL ===
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    stage_status TEXT DEFAULT 'pending' CHECK (stage_status IN ('pending', 'in_progress', 'completed', 'failed')),
    
    -- CONSTRAINTS
    UNIQUE(book_id) -- One analysis per book
);

-- =============================================
-- Stage 2: Streamlined Enrichment Results (17 Essential Fields)
-- =============================================
CREATE TABLE IF NOT EXISTS book_enrichment_results_streamlined (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    analysis_result_id UUID REFERENCES book_analysis_results_streamlined(id) ON DELETE CASCADE,
    
    -- INPUT METADATA
    input_book_title TEXT,
    input_author_name TEXT,
    input_analysis_data JSONB, -- Stage 1 analysis results used as input
    
    -- === STAGE 2: CORE ENRICHMENT RESULTS (12 ESSENTIAL FIELDS) ===
    
    -- Database Update Fields (what gets stored in books table)
    final_title_alias TEXT, -- Complete semicolon-separated title alias string
    final_keywords TEXT[], -- Complete keywords array for database
    final_description TEXT, -- Complete 100-150 word academic description
    
    -- Generation Metrics
    transliteration_variations_count INTEGER DEFAULT 0, -- Number of transliteration variants generated
    core_concepts_count INTEGER DEFAULT 0, -- Number of core concept keywords
    contextual_associations_count INTEGER DEFAULT 0, -- Total contextual associations (people/places/events)
    description_word_count INTEGER DEFAULT 0, -- Actual word count (target 100-150)
    
    -- Quality Validation
    academic_tone_maintained BOOLEAN DEFAULT false, -- Proper academic tone achieved
    enrichment_quality_score INTEGER CHECK (enrichment_quality_score >= 1 AND enrichment_quality_score <= 10),
    
    -- Execution Status
    sql_executed BOOLEAN DEFAULT false, -- SQL was executed successfully
    execution_successful BOOLEAN DEFAULT false, -- Database update completed
    methodology_compliance_gate_passed BOOLEAN DEFAULT false, -- All methodology requirements met
    
    -- === EXECUTION TRACKING (5 ESSENTIAL FIELDS) ===
    
    execution_timestamp TIMESTAMP WITH TIME ZONE, -- When SQL execution occurred
    rows_affected INTEGER DEFAULT 0, -- Number of database rows updated
    execution_error TEXT, -- Any execution errors encountered
    books_updated_at TIMESTAMP WITH TIME ZONE, -- Database table update timestamp
    overall_quality_gate_passed BOOLEAN DEFAULT false, -- All quality gates passed
    
    -- === AUDIT TRAIL ===
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    stage_status TEXT DEFAULT 'pending' CHECK (stage_status IN ('pending', 'in_progress', 'completed', 'failed')),
    
    -- CONSTRAINTS
    UNIQUE(book_id) -- One enrichment per book
);

-- =============================================
-- STREAMLINED VIEWS FOR MONITORING
-- =============================================

-- Stage 1 Essential Status View
CREATE OR REPLACE VIEW stage1_essential_status AS
SELECT 
    bar.book_id,
    b.title,
    b.author_name,
    
    -- Core Analysis Status
    bar.central_node IS NOT NULL as central_node_provided,
    bar.genre_classification IS NOT NULL as genre_provided,
    bar.methodological_foundation IS NOT NULL as methodology_provided,
    bar.scholarly_perspective IS NOT NULL as perspective_provided,
    bar.network_description IS NOT NULL as network_description_provided,
    
    -- Quality Gates
    bar.analysis_quality_score,
    bar.quality_gate_passed,
    bar.ready_for_stage2,
    bar.stage_status,
    bar.created_at

FROM book_analysis_results_streamlined bar
JOIN books b ON bar.book_id = b.id
ORDER BY bar.created_at DESC;

-- Stage 2 Essential Status View
CREATE OR REPLACE VIEW stage2_essential_status AS
SELECT 
    ber.book_id,
    b.title,
    b.author_name,
    
    -- Core Enrichment Status
    ber.final_title_alias IS NOT NULL as title_alias_generated,
    ber.final_keywords IS NOT NULL as keywords_generated,
    ber.final_description IS NOT NULL as description_generated,
    
    -- Metrics
    ber.transliteration_variations_count,
    ber.core_concepts_count,
    ber.contextual_associations_count,
    ber.description_word_count,
    ber.description_word_count BETWEEN 100 AND 150 as word_count_compliant,
    
    -- Quality and Execution
    ber.academic_tone_maintained,
    ber.enrichment_quality_score,
    ber.sql_executed,
    ber.execution_successful,
    ber.methodology_compliance_gate_passed,
    ber.overall_quality_gate_passed,
    ber.stage_status,
    ber.created_at

FROM book_enrichment_results_streamlined ber
JOIN books b ON ber.book_id = b.id
ORDER BY ber.created_at DESC;

-- Complete Streamlined Pipeline Status
CREATE OR REPLACE VIEW streamlined_pipeline_status AS
SELECT 
    b.id as book_id,
    b.title,
    b.author_name,
    
    -- Stage 1 Status
    CASE 
        WHEN bar.id IS NULL THEN 'not_started'
        WHEN bar.stage_status = 'completed' AND bar.quality_gate_passed THEN 'completed'
        WHEN bar.stage_status = 'failed' THEN 'failed'
        WHEN bar.stage_status = 'in_progress' THEN 'in_progress'
        ELSE 'pending'
    END as stage1_status,
    bar.analysis_quality_score,
    bar.ready_for_stage2,
    
    -- Stage 2 Status  
    CASE
        WHEN ber.id IS NULL THEN 'not_started'
        WHEN ber.stage_status = 'completed' AND ber.overall_quality_gate_passed THEN 'completed'
        WHEN ber.stage_status = 'failed' THEN 'failed'
        WHEN ber.stage_status = 'in_progress' THEN 'in_progress'
        ELSE 'pending'
    END as stage2_status,
    ber.enrichment_quality_score,
    ber.execution_successful,
    
    -- Overall Pipeline Status
    CASE
        WHEN bar.ready_for_stage2 AND ber.overall_quality_gate_passed THEN 'fully_completed'
        WHEN bar.ready_for_stage2 AND ber.id IS NULL THEN 'stage1_complete_ready_stage2'
        WHEN bar.id IS NOT NULL AND NOT bar.ready_for_stage2 THEN 'stage1_needs_work'
        WHEN ber.id IS NOT NULL AND NOT ber.overall_quality_gate_passed THEN 'stage2_needs_work'
        ELSE 'ready_for_processing'
    END as overall_status,
    
    -- Database Update Status
    CASE 
        WHEN b.title_alias IS NOT NULL AND b.keywords IS NOT NULL AND b.description IS NOT NULL THEN 'enriched'
        WHEN b.title_alias IS NOT NULL OR b.keywords IS NOT NULL THEN 'partially_enriched'
        ELSE 'not_enriched'
    END as database_status,
    
    -- Timestamps
    bar.created_at as stage1_completed_at,
    ber.created_at as stage2_completed_at,
    GREATEST(COALESCE(bar.updated_at, '1970-01-01'::timestamp), COALESCE(ber.updated_at, '1970-01-01'::timestamp), b.updated_at) as last_updated

FROM books b
LEFT JOIN book_analysis_results_streamlined bar ON b.id = bar.book_id
LEFT JOIN book_enrichment_results_streamlined ber ON b.id = ber.book_id
ORDER BY b.created_at DESC;

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Stage 1 indexes
CREATE INDEX IF NOT EXISTS idx_analysis_streamlined_book_id ON book_analysis_results_streamlined(book_id);
CREATE INDEX IF NOT EXISTS idx_analysis_streamlined_quality ON book_analysis_results_streamlined(quality_gate_passed, ready_for_stage2);
CREATE INDEX IF NOT EXISTS idx_analysis_streamlined_status ON book_analysis_results_streamlined(stage_status);

-- Stage 2 indexes
CREATE INDEX IF NOT EXISTS idx_enrichment_streamlined_book_id ON book_enrichment_results_streamlined(book_id);
CREATE INDEX IF NOT EXISTS idx_enrichment_streamlined_quality ON book_enrichment_results_streamlined(overall_quality_gate_passed, execution_successful);
CREATE INDEX IF NOT EXISTS idx_enrichment_streamlined_status ON book_enrichment_results_streamlined(stage_status);

-- =============================================
-- QUALITY GATE TRIGGERS (SIMPLIFIED)
-- =============================================

-- Stage 1 Quality Gate Trigger
CREATE OR REPLACE FUNCTION update_streamlined_stage1_gates()
RETURNS TRIGGER AS $$
BEGIN
    -- Quality gate: analysis_quality_score >= 7
    NEW.quality_gate_passed = (NEW.analysis_quality_score >= 7);
    
    -- Ready for stage 2: quality gate passed AND all core fields present
    NEW.ready_for_stage2 = (
        NEW.quality_gate_passed AND
        NEW.central_node IS NOT NULL AND
        NEW.genre_classification IS NOT NULL AND
        NEW.methodological_foundation IS NOT NULL AND
        NEW.scholarly_perspective IS NOT NULL AND
        NEW.network_description IS NOT NULL
    );
    
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_streamlined_stage1_gates
    BEFORE UPDATE ON book_analysis_results_streamlined
    FOR EACH ROW
    EXECUTE FUNCTION update_streamlined_stage1_gates();

-- Stage 2 Quality Gate Trigger
CREATE OR REPLACE FUNCTION update_streamlined_stage2_gates()
RETURNS TRIGGER AS $$
BEGIN
    -- Methodology compliance: core fields present and word count in range
    NEW.methodology_compliance_gate_passed = (
        NEW.final_title_alias IS NOT NULL AND
        NEW.final_keywords IS NOT NULL AND
        NEW.final_description IS NOT NULL AND
        NEW.description_word_count BETWEEN 100 AND 150 AND
        NEW.academic_tone_maintained = true AND
        NEW.enrichment_quality_score >= 7
    );
    
    -- Overall quality gate: methodology + execution success
    NEW.overall_quality_gate_passed = (
        NEW.methodology_compliance_gate_passed AND 
        NEW.execution_successful = true
    );
    
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_streamlined_stage2_gates
    BEFORE UPDATE ON book_enrichment_results_streamlined
    FOR EACH ROW
    EXECUTE FUNCTION update_streamlined_stage2_gates();

-- =============================================
-- COMMENTS AND DOCUMENTATION
-- =============================================

COMMENT ON TABLE book_analysis_results_streamlined IS 'Streamlined Stage 1 analysis results - 8 essential fields (reduced from 59 fields - 86% reduction)';
COMMENT ON TABLE book_enrichment_results_streamlined IS 'Streamlined Stage 2 enrichment results - 17 essential fields (reduced from 96 fields - 82% reduction)';

COMMENT ON COLUMN book_analysis_results_streamlined.central_node IS 'Book''s single most important thesis/subject/argument';
COMMENT ON COLUMN book_analysis_results_streamlined.genre_classification IS 'Precise work type identification';
COMMENT ON COLUMN book_analysis_results_streamlined.methodological_foundation IS 'Specific sources and analytical methods';
COMMENT ON COLUMN book_analysis_results_streamlined.scholarly_perspective IS 'Author''s school of thought/intellectual tradition';
COMMENT ON COLUMN book_analysis_results_streamlined.network_description IS 'Paragraph explaining conceptual connections';

COMMENT ON COLUMN book_enrichment_results_streamlined.final_title_alias IS 'Complete semicolon-separated title alias string → books.title_alias';
COMMENT ON COLUMN book_enrichment_results_streamlined.final_keywords IS 'Complete keywords array → books.keywords';
COMMENT ON COLUMN book_enrichment_results_streamlined.final_description IS 'Complete 100-150 word academic description → books.description';

-- =============================================
-- USAGE EXAMPLES
-- =============================================

/*
-- Monitor Stage 1 Progress
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN ready_for_stage2 THEN 1 END) as ready_for_stage2,
    COUNT(CASE WHEN stage_status = 'completed' THEN 1 END) as completed
FROM book_analysis_results_streamlined;

-- Monitor Stage 2 Progress  
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN overall_quality_gate_passed THEN 1 END) as fully_completed,
    COUNT(CASE WHEN execution_successful THEN 1 END) as database_updated
FROM book_enrichment_results_streamlined;

-- Overall Pipeline Status Summary
SELECT 
    overall_status,
    COUNT(*) as count
FROM streamlined_pipeline_status 
GROUP BY overall_status
ORDER BY count DESC;

-- Books Ready for Processing
SELECT book_id, title, author_name 
FROM streamlined_pipeline_status 
WHERE overall_status = 'ready_for_processing'
LIMIT 10;
*/