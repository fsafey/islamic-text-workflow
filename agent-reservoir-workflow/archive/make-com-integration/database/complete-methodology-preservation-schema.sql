-- =============================================
-- COMPLETE METHODOLOGY PRESERVATION SCHEMA
-- Islamic Text Processing Workflow - Full Prompt Compliance
-- Purpose: Capture EVERY component from Academic-Analysis-Prompt-V4-Hybrid.md and ENRICHMENT_CRITERIA.md
-- =============================================

-- Drop existing tables to recreate with complete methodology preservation
DROP TABLE IF EXISTS book_enrichment_results CASCADE;
DROP TABLE IF EXISTS book_analysis_results CASCADE;

-- =============================================
-- Stage 1: COMPLETE Academic Analysis Preservation - Academic-Analysis-Prompt-V4-Hybrid.md
-- =============================================
CREATE TABLE IF NOT EXISTS book_analysis_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    
    -- INPUT DATA PRESERVATION
    input_title TEXT NOT NULL,
    input_author_name TEXT NOT NULL, -- Matches books.author_name
    input_book_uuid UUID NOT NULL,
    input_processing_timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
    
    -- COMPLETE AGENT OUTPUT PRESERVATION
    hybrid_analysis_full_text TEXT, -- Complete markdown analysis content
    agent_full_response JSONB, -- Complete Claude agent response preservation
    agent_response_tokens INTEGER, -- Token count for analysis
    
    -- === PART 1: CONCEPTUAL NETWORK - COMPLETE CAPTURE ===
    
    -- CENTRAL NODE (required by prompt)
    central_node TEXT, -- Single most important thesis, subject, or argument
    
    -- PRIMARY CONNECTED CONCEPTS (4 MANDATORY elements from prompt)
    genre_classification TEXT, -- Precise work type (theological treatise, biographical encyclopedia, etc)
    methodological_foundation TEXT, -- Specific sources/methods (Quran/Sunnah analysis, historical records, etc)
    scholarly_perspective TEXT, -- School of thought (Shi'a Imami, Sunni Ash'ari, Hanafi, etc)
    core_argumentative_thesis TEXT, -- Central intellectual claim or primary purpose
    primary_concepts_complete BOOLEAN DEFAULT false, -- All 4 elements captured
    
    -- SECONDARY/SUPPORTING CONCEPTS (required by prompt)
    secondary_supporting_concepts TEXT[], -- Related ideas, events, key figures, fields of study
    secondary_concepts_count INTEGER, -- Number of supporting concepts identified
    
    -- NETWORK DESCRIPTION (required by prompt)
    network_description TEXT, -- Concise paragraph explaining how nodes connect to form unique framework
    network_description_addresses_all_four BOOLEAN DEFAULT false, -- Must address Genre, Methodology, Perspective, Thesis
    relational_connections_explained BOOLEAN DEFAULT false, -- Shows how elements connect
    
    -- === PART 2: STRUCTURAL FLOWCHART - COMPLETE CAPTURE ===
    
    -- LOGICAL ORGANIZATION (required by prompt)
    logical_organization JSONB, -- Primary sections structure (Volumes, Parts, Chapters)
    logical_organization_type TEXT, -- Type of organization used
    
    -- VISUAL HIERARCHY (required by prompt)
    visual_hierarchy JSONB, -- Indentation and arrows showing argument flow
    main_topics_to_subtopics_flow JSONB, -- Flow from main to sub-topics
    
    -- EXTREME SPECIFICITY (required by prompt)
    extreme_specificity_details JSONB, -- Specific concepts, terms, verses, events, figures
    specific_concepts_count INTEGER, -- Number of specific concepts included
    scriptural_verses_referenced TEXT[], -- Specific verses that would be discussed
    historical_events_referenced TEXT[], -- Specific events that would be covered
    key_figures_referenced TEXT[], -- Specific people discussed
    
    -- KEY TERMINOLOGY (required by prompt)
    key_terminology_arabic TEXT[], -- Arabic/technical terms in italics (Wilayah, Isnad, Raj'a)
    arabic_terms_properly_italicized BOOLEAN DEFAULT false, -- Formatting verification
    technical_terms_count INTEGER, -- Number of technical terms included
    
    -- ANTICIPATORY STRUCTURE (required by prompt)
    anticipatory_structure_notes TEXT, -- Introduction, conclusion, counter-arguments
    includes_introduction BOOLEAN DEFAULT false,
    includes_conclusion BOOLEAN DEFAULT false,
    addresses_counter_arguments BOOLEAN DEFAULT false,
    includes_misconceptions_section BOOLEAN DEFAULT false,
    
    -- CONCRETE EXAMPLES (required by prompt)
    concrete_examples TEXT[], -- Specific examples of scholarly tool usage
    realistic_citations_included TEXT[], -- Sample citations based on genre understanding
    sample_entries_provided TEXT[], -- Sample entries if applicable
    concrete_examples_count INTEGER, -- Number of concrete examples
    
    -- === RESEARCH INTEGRATION PROTOCOL - MANDATORY REQUIREMENTS ===
    
    -- MANDATORY RESEARCH FIRST (required by prompt)
    websearch_performed BOOLEAN DEFAULT false, -- ALWAYS use WebSearch requirement
    websearch_research_notes TEXT, -- Brief documentation of verification research
    book_content_verified BOOLEAN DEFAULT false, -- Actual knowledge vs guesswork
    reliable_information_found BOOLEAN DEFAULT false, -- Whether reliable info was found
    
    -- SKIP CONDITIONS (required by prompt)
    skip_if_no_information BOOLEAN DEFAULT false, -- Skip book if no reliable info
    skip_reason TEXT, -- Reason for skipping (if applicable)
    proceeded_with_guesswork BOOLEAN DEFAULT false, -- Violation of prompt requirements
    
    -- RESEARCH SOURCES AND VERIFICATION
    research_sources TEXT[], -- WebSearch sources used
    research_confidence INTEGER CHECK (research_confidence >= 1 AND research_confidence <= 10),
    verification_notes TEXT, -- Additional research verification
    
    -- === QUALITY STANDARDS - PROMPT COMPLIANCE ===
    
    -- STRUCTURE ADHERENCE (required by prompt)
    follows_example_structure BOOLEAN DEFAULT false, -- Follows Al-Ghadir example exactly
    analytical_rigor_matches_v3 BOOLEAN DEFAULT false, -- Matches V3 precision
    hybrid_approach_advantages_demonstrated BOOLEAN DEFAULT false, -- Multi-dimensional understanding
    
    -- MANDATORY REQUIREMENTS CHECK (from prompt)
    extreme_specificity_achieved BOOLEAN DEFAULT false, -- No vague descriptions
    perfect_adherence_to_structure BOOLEAN DEFAULT false, -- Follows example exactly
    explicit_coverage_all_four BOOLEAN DEFAULT false, -- All 4 primary elements covered
    scholarly_depth_demonstrated BOOLEAN DEFAULT false, -- Arabic terms + Islamic studies knowledge
    
    -- === FILE MANAGEMENT - DOCUMENTATION REQUIREMENT ===
    
    -- MANDATORY FILE CREATION (required by prompt)
    analysis_file_path TEXT, -- Path to .md file in academic-analyses/
    analysis_file_generated BOOLEAN DEFAULT false, -- File creation completed
    analysis_file_size_bytes INTEGER, -- File size verification
    file_structure_compliant BOOLEAN DEFAULT false, -- Follows required markdown structure
    file_naming_convention_followed BOOLEAN DEFAULT false, -- [Key-Title-Words]-Hybrid-Analysis.md
    
    -- === WORKFLOW INTEGRATION ===
    
    -- DOWNSTREAM STAGE PREPARATION
    stage2_input_data_prepared JSONB, -- Structured data for Stage 2 enrichment
    central_node_for_enrichment TEXT, -- Main thesis for title_alias generation
    primary_concepts_for_enrichment TEXT[], -- 4 pillars for keyword generation  
    key_evidence_for_enrichment TEXT[], -- Specific terms for keywords
    authors_core_project TEXT, -- For description generation
    
    -- === COMPREHENSIVE CATEGORIZATION ===
    
    -- VERIFIED METADATA
    verified_title TEXT, -- Research-verified title
    verified_author TEXT, -- Research-verified author with biographical info
    author_biographical_info TEXT, -- Detailed biographical information
    subject_category TEXT, -- Primary Islamic studies category
    theological_school TEXT, -- Sunni, Shia, specific madhab
    historical_period TEXT, -- Time period of work/author
    target_audience TEXT CHECK (target_audience IN ('beginner', 'intermediate', 'advanced', 'scholarly')),
    complexity_level TEXT CHECK (complexity_level IN ('beginner', 'intermediate', 'advanced', 'scholarly')),
    
    -- THEMATIC ANALYSIS
    core_themes TEXT[], -- Main themes identified
    theological_positions TEXT[], -- Theological stances
    arguments_presented TEXT[], -- Key arguments
    key_concepts TEXT[], -- Important concepts
    related_works TEXT[], -- Related books/texts
    cited_sources TEXT[], -- Sources cited in book
    influences TEXT[], -- Intellectual influences
    
    -- === QUALITY ASSESSMENT AND GATES ===
    
    -- METHODOLOGY COMPLIANCE SCORING
    prompt_methodology_compliance_score INTEGER CHECK (prompt_methodology_compliance_score >= 1 AND prompt_methodology_compliance_score <= 10),
    websearch_requirement_met BOOLEAN DEFAULT false, -- Mandatory research performed
    four_elements_requirement_met BOOLEAN DEFAULT false, -- All 4 primary concepts identified
    network_description_requirement_met BOOLEAN DEFAULT false, -- Network description provided
    structural_flowchart_requirement_met BOOLEAN DEFAULT false, -- Flowchart provided
    extreme_specificity_requirement_met BOOLEAN DEFAULT false, -- Specific details provided
    file_creation_requirement_met BOOLEAN DEFAULT false, -- Markdown file created
    
    -- OVERALL QUALITY GATES
    analysis_quality_score INTEGER CHECK (analysis_quality_score >= 1 AND analysis_quality_score <= 10),
    quality_gate_passed BOOLEAN DEFAULT false, -- analysis_quality_score >= 7
    methodology_compliance_gate_passed BOOLEAN DEFAULT false, -- All methodology requirements met
    ready_for_stage2 BOOLEAN DEFAULT false, -- Ready for enrichment stage
    
    -- === PROCESSING METADATA ===
    
    stage_status TEXT DEFAULT 'pending' CHECK (stage_status IN ('pending', 'in_progress', 'completed', 'failed', 'manual_review')),
    processing_time_minutes INTEGER,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    processing_warnings TEXT[],
    
    -- === AUDIT TRAIL ===
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    processed_by TEXT DEFAULT 'hybrid_analysis_agent',
    claude_agent_version TEXT,
    prompt_version TEXT DEFAULT 'Academic-Analysis-Prompt-V4-Hybrid',
    processing_node TEXT,
    
    -- CONSTRAINTS
    UNIQUE(book_id) -- One analysis per book
);

-- =============================================
-- Stage 2: COMPLETE Enrichment & Execution Preservation - ENRICHMENT_CRITERIA.md
-- =============================================
CREATE TABLE IF NOT EXISTS book_enrichment_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    analysis_result_id UUID NOT NULL REFERENCES book_analysis_results(id) ON DELETE CASCADE,
    
    -- INPUT DATA PRESERVATION (from Stage 1)
    input_analysis_data JSONB, -- Complete Stage 1 results used as input
    input_central_node TEXT,
    input_primary_concepts TEXT[],
    input_key_evidence TEXT[],
    input_authors_project TEXT,
    input_academic_description TEXT,
    
    -- COMPLETE AGENT OUTPUT PRESERVATION
    enrichment_agent_full_response JSONB, -- Complete Claude enrichment response
    description_agent_full_response JSONB, -- Complete description generation response
    combined_agent_responses JSONB, -- If integrated into single response
    
    -- === FINAL DATABASE UPDATE VALUES ===
    
    final_title_alias TEXT, -- Single semicolon-separated field → books.title_alias
    final_keywords TEXT[], -- Array → books.keywords  
    final_description TEXT, -- Academic description → books.description
    
    -- === TITLE_ALIAS GENERATION - COMPLETE ENRICHMENT_CRITERIA.md COMPLIANCE ===
    
    -- TRANSLITERATION VARIATIONS (required by criteria)
    transliteration_variations TEXT[], -- Different transliteration schemes
    transliteration_variations_count INTEGER, -- Number of variations generated
    
    -- DEFINITE ARTICLE HANDLING (required by criteria)
    definite_article_variants TEXT[], -- Al-, el-, Al , omitted variations
    definite_article_al_forms TEXT[], -- Al-Ghadir variations
    definite_article_el_forms TEXT[], -- el-Ghadir variations  
    definite_article_omitted_forms TEXT[], -- Ghadir (omitted article)
    definite_article_space_variants TEXT[], -- "Al Ghadir" vs "Al-Ghadir"
    
    -- SPECIAL CHARACTER SIMPLIFICATION (required by criteria)
    special_character_simplifications TEXT[], -- _a→ayn, _→gh transformations
    underscore_a_replacements TEXT[], -- _a → ayn variations
    underscore_replacements TEXT[], -- _ → gh variations  
    special_char_removed_forms TEXT[], -- Completely removed special chars
    common_phonetic_replacements TEXT[], -- Intuitive phonetic forms
    
    -- VOWEL AND CONSONANT AMBIGUITY (required by criteria)
    vowel_consonant_variations TEXT[], -- q/k, th/s, dh/d phonetic variations
    qaf_variations TEXT[], -- q → k variations
    tha_variations TEXT[], -- th → s variations
    dhad_variations TEXT[], -- dh → d variations
    phonetic_ambiguity_count INTEGER, -- Total phonetic variations
    
    -- WORD COMBINATION (required by criteria)
    word_combination_variants TEXT[], -- AlHusayn, Al-Husayn, Al Husayn
    combined_forms TEXT[], -- AlHusayn style
    hyphenated_forms TEXT[], -- Al-Husayn style
    spaced_forms TEXT[], -- Al Husayn style
    word_combination_count INTEGER, -- Number of combination variants
    
    -- PARTIAL AND SIMPLIFIED TITLES (required by criteria)
    partial_memorable_titles TEXT[], -- Distinctive parts users remember
    most_distinctive_part TEXT, -- Single most memorable element
    shortened_memorable_versions TEXT[], -- Shorter versions
    simplified_title_forms TEXT[], -- Simplified for ease of recall
    
    -- CONCEPTUAL/DESCRIPTIVE TITLES (required by criteria)
    conceptual_descriptive_titles TEXT[], -- What book is *about* ("The Verse of Cursing")
    english_conceptual_titles TEXT[], -- English descriptions of content
    topic_based_titles TEXT[], -- Based on main topic
    descriptive_aliases TEXT[], -- Descriptive variations
    
    -- === KEYWORDS GENERATION - COMPLETE ENRICHMENT_CRITERIA.md COMPLIANCE ===
    
    -- CORE CONCEPTS (required by criteria)
    core_concept_keywords TEXT[], -- Main nouns/ideas from title (Husayn, Adam, Warith)
    title_derived_concepts TEXT[], -- Concepts directly from title
    core_concepts_count INTEGER, -- Number of core concepts
    
    -- ASSOCIATED FIGURES, PLACES, EVENTS (required by criteria)
    associated_figures_keywords TEXT[], -- Contextually relevant people (Imam Ali, Prophet, etc)
    associated_places_keywords TEXT[], -- Relevant locations (Karbala, Mecca, Najran)
    associated_events_keywords TEXT[], -- Historical events (Ghadir, Ashura, Mubahala)
    contextual_associations_count INTEGER, -- Total contextual associations
    
    -- BROADER SUBJECT AREAS (required by criteria)
    broader_subject_keywords TEXT[], -- Academic fields (Theology, Hadith, Fiqh, Kalam)
    academic_fields TEXT[], -- Specific academic disciplines
    theological_fields TEXT[], -- Theological specializations
    jurisprudence_fields TEXT[], -- Fiqh-related areas
    historical_fields TEXT[], -- Historical specializations
    
    -- SYNONYMS AND RELATED TERMS (required by criteria)
    synonyms_related_keywords TEXT[], -- English synonyms (Martyrdom for Shahid)
    english_synonyms TEXT[], -- English equivalents
    arabic_terms_simple_transliteration TEXT[], -- Simple Arabic transliterations
    concept_synonyms TEXT[], -- Conceptual equivalents
    
    -- COMPREHENSIVE KEYWORD CATEGORIES
    author_name_variations TEXT[], -- Author name and common variations
    theological_school_keywords TEXT[], -- Shia Islam, Sunni, specific madhabs
    historical_period_keywords TEXT[], -- Time period related terms
    manuscript_tradition_keywords TEXT[], -- Manuscript and textual tradition terms
    
    -- === DESCRIPTION GENERATION - COMPLETE Islamic-Text-Processing-Workflow.md ===
    
    -- 5-STEP NARRATIVE STRUCTURE (required by workflow)
    description_5_step_breakdown JSONB, -- 1)Identity 2)Thesis 3)Pillars 4)Evidence 5)Conclusion
    step1_identity_sentence TEXT, -- Introducing book, stating author analyzes source
    step2_thesis_statement TEXT, -- Central argument using Core Project + Central Node
    step3_pillars_explanation TEXT, -- What system is built on (Primary Concepts)
    step4_evidence_grounding TEXT, -- Most significant Key Evidence
    step5_concluding_thought TEXT, -- Author's ultimate goal, relevant model
    
    -- DESCRIPTION QUALITY REQUIREMENTS
    description_methodology TEXT DEFAULT 'Description Generation Prompt + 5-step narrative',
    description_word_count INTEGER, -- Should be 100-150
    description_quality_score INTEGER CHECK (description_quality_score >= 1 AND description_quality_score <= 10),
    academic_encyclopedic_tone_maintained BOOLEAN DEFAULT false,
    single_paragraph_flow_achieved BOOLEAN DEFAULT false,
    logical_flow_maintained BOOLEAN DEFAULT false,
    
    -- ARABIC TERMS FORMATTING
    arabic_terms_italicized TEXT[], -- Arabic terms properly formatted (*Wilayah*, *Sunnah*)
    arabic_terms_formatting_correct BOOLEAN DEFAULT false,
    key_islamic_terms_included BOOLEAN DEFAULT false,
    
    -- === SQL GENERATION AND VALIDATION ===
    
    -- SQL STATEMENT GENERATION
    generated_sql_statement TEXT, -- Complete SQL UPDATE statement
    sql_methodology TEXT DEFAULT 'ENRICHMENT_CRITERIA.md + books table schema compliance',
    
    -- SCHEMA COMPLIANCE VALIDATION
    sql_syntax_validated BOOLEAN DEFAULT false,
    sql_escaping_correct BOOLEAN DEFAULT false, -- Apostrophes, special chars
    sql_title_alias_format_correct BOOLEAN DEFAULT false, -- Single semicolon-separated text
    sql_keywords_array_format_correct BOOLEAN DEFAULT false, -- Proper PostgreSQL array format
    sql_schema_compliance_verified BOOLEAN DEFAULT false, -- Matches actual books table schema
    sql_preview_generated BOOLEAN DEFAULT false,
    
    -- === DATABASE EXECUTION TRACKING ===
    
    sql_executed BOOLEAN DEFAULT false,
    execution_successful BOOLEAN DEFAULT false,
    execution_timestamp TIMESTAMP WITH TIME ZONE,
    execution_duration_ms INTEGER,
    rows_affected INTEGER,
    execution_error TEXT,
    rollback_performed BOOLEAN DEFAULT false,
    execution_retry_count INTEGER DEFAULT 0,
    
    -- BEFORE/AFTER VALUE PRESERVATION (complete audit trail)
    books_title_alias_before TEXT, -- Previous value in books table
    books_title_alias_after TEXT, -- New value applied
    books_keywords_before TEXT[], -- Previous keywords array
    books_keywords_after TEXT[], -- New keywords array applied
    books_description_before TEXT, -- Previous description
    books_description_after TEXT, -- New description applied
    books_updated_at TIMESTAMP WITH TIME ZONE, -- When books record was updated
    
    -- === METHODOLOGY COMPLIANCE ASSESSMENT ===
    
    -- ENRICHMENT_CRITERIA.md COMPLIANCE
    enrichment_criteria_methodology_score INTEGER CHECK (enrichment_criteria_methodology_score >= 1 AND enrichment_criteria_methodology_score <= 10),
    title_alias_criteria_compliance BOOLEAN DEFAULT false, -- All title_alias requirements met
    keywords_criteria_compliance BOOLEAN DEFAULT false, -- All keywords requirements met
    transliteration_variations_adequate BOOLEAN DEFAULT false, -- Sufficient variations provided
    phonetic_variations_comprehensive BOOLEAN DEFAULT false, -- All phonetic rules applied
    contextual_associations_complete BOOLEAN DEFAULT false, -- Relevant figures/places/events included
    
    -- QUALITY METRICS
    enrichment_quality_score INTEGER CHECK (enrichment_quality_score >= 1 AND enrichment_quality_score <= 10),
    criteria_compliance_score INTEGER CHECK (criteria_compliance_score >= 1 AND criteria_compliance_score <= 10),
    title_alias_count INTEGER, -- Number of aliases generated
    keywords_count INTEGER, -- Total number of keywords
    keyword_category_coverage INTEGER, -- How many categories covered
    
    -- === FILE MANAGEMENT ===
    
    sql_file_path TEXT, -- Path to individual SQL file in sql-updates/
    sql_file_generated BOOLEAN DEFAULT false,
    batch_sql_added BOOLEAN DEFAULT false, -- Added to batch-enrichment-updates.sql
    sql_file_size_bytes INTEGER,
    
    -- === QUALITY GATES AND PIPELINE STATUS ===
    
    -- INDIVIDUAL QUALITY GATES
    enrichment_quality_gate_passed BOOLEAN DEFAULT false, -- enrichment_quality_score >= 8
    sql_validation_gate_passed BOOLEAN DEFAULT false, -- sql_syntax_validated = true
    execution_gate_passed BOOLEAN DEFAULT false, -- execution_successful = true
    methodology_compliance_gate_passed BOOLEAN DEFAULT false, -- All methodology requirements met
    
    -- OVERALL PIPELINE STATUS
    overall_quality_gate_passed BOOLEAN DEFAULT false, -- All gates passed
    ready_for_pipeline_completion BOOLEAN DEFAULT false,
    
    -- === PROCESSING METADATA ===
    
    stage_status TEXT DEFAULT 'pending' CHECK (stage_status IN ('pending', 'in_progress', 'completed', 'failed', 'manual_review')),
    processing_time_minutes INTEGER,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    processing_warnings TEXT[],
    
    -- === AUDIT TRAIL ===
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    processed_by TEXT DEFAULT 'enrichment_execution_agent',
    claude_agent_version TEXT,
    enrichment_criteria_version TEXT DEFAULT 'ENRICHMENT_CRITERIA.md',
    workflow_version TEXT DEFAULT 'Islamic-Text-Processing-Workflow.md',
    processing_node TEXT,
    
    -- CONSTRAINTS
    UNIQUE(book_id) -- One enrichment per book
);

-- =============================================
-- COMPLETE METHODOLOGY COMPLIANCE VIEWS
-- =============================================

-- Stage 1 Methodology Compliance View
CREATE OR REPLACE VIEW stage1_methodology_compliance AS
SELECT 
    bar.book_id,
    bar.id as analysis_id,
    b.title,
    b.author_name,
    
    -- Research Protocol Compliance
    bar.websearch_performed,
    bar.book_content_verified,
    bar.websearch_requirement_met,
    
    -- Primary Elements Compliance (4 mandatory)
    bar.genre_classification IS NOT NULL as genre_provided,
    bar.methodological_foundation IS NOT NULL as methodology_provided,
    bar.scholarly_perspective IS NOT NULL as perspective_provided,
    bar.core_argumentative_thesis IS NOT NULL as thesis_provided,
    bar.four_elements_requirement_met,
    
    -- Network and Structure Compliance
    bar.network_description IS NOT NULL as network_description_provided,
    bar.network_description_addresses_all_four,
    bar.structural_flowchart_requirement_met,
    bar.extreme_specificity_requirement_met,
    
    -- File Creation Compliance
    bar.file_creation_requirement_met,
    bar.analysis_file_generated,
    
    -- Overall Compliance
    bar.methodology_compliance_gate_passed,
    bar.prompt_methodology_compliance_score,
    bar.quality_gate_passed,
    bar.stage_status

FROM book_analysis_results bar
JOIN books b ON bar.book_id = b.id
ORDER BY bar.created_at DESC;

-- Stage 2 Methodology Compliance View  
CREATE OR REPLACE VIEW stage2_methodology_compliance AS
SELECT 
    ber.book_id,
    ber.id as enrichment_id,
    b.title,
    b.author_name,
    
    -- Title Alias Methodology Compliance
    ber.transliteration_variations_count,
    ber.definite_article_variants IS NOT NULL as definite_article_handled,
    ber.special_character_simplifications IS NOT NULL as special_chars_simplified,
    ber.vowel_consonant_variations IS NOT NULL as phonetic_variations_provided,
    ber.partial_memorable_titles IS NOT NULL as partial_titles_provided,
    ber.conceptual_descriptive_titles IS NOT NULL as conceptual_titles_provided,
    ber.title_alias_criteria_compliance,
    
    -- Keywords Methodology Compliance
    ber.core_concept_keywords IS NOT NULL as core_concepts_extracted,
    ber.associated_figures_keywords IS NOT NULL as figures_included,
    ber.associated_places_keywords IS NOT NULL as places_included,
    ber.associated_events_keywords IS NOT NULL as events_included,
    ber.broader_subject_keywords IS NOT NULL as subjects_included,
    ber.synonyms_related_keywords IS NOT NULL as synonyms_included,
    ber.keywords_criteria_compliance,
    
    -- Description Generation Compliance
    ber.description_5_step_breakdown IS NOT NULL as five_step_structure_used,
    ber.description_word_count BETWEEN 100 AND 150 as word_count_compliant,
    ber.academic_encyclopedic_tone_maintained,
    ber.single_paragraph_flow_achieved,
    
    -- SQL and Execution Compliance
    ber.sql_schema_compliance_verified,
    ber.sql_title_alias_format_correct,
    ber.sql_keywords_array_format_correct,
    ber.execution_successful,
    
    -- Overall Compliance
    ber.methodology_compliance_gate_passed,
    ber.enrichment_criteria_methodology_score,
    ber.overall_quality_gate_passed,
    ber.stage_status

FROM book_enrichment_results ber
JOIN books b ON ber.book_id = b.id
ORDER BY ber.created_at DESC;

-- Complete Pipeline Status with Methodology Tracking
CREATE OR REPLACE VIEW complete_pipeline_status AS
SELECT 
    b.id as book_id,
    b.title,
    b.author_name,
    b.processing_agent,
    b.processing_started,
    
    -- Stage 1 Methodology Status
    CASE 
        WHEN bar.id IS NULL THEN 'not_started'
        WHEN bar.stage_status = 'completed' AND bar.methodology_compliance_gate_passed THEN 'methodology_compliant'
        WHEN bar.stage_status = 'completed' AND bar.quality_gate_passed THEN 'completed_needs_review'
        WHEN bar.stage_status = 'failed' THEN 'failed'
        WHEN bar.stage_status = 'in_progress' THEN 'in_progress'
        ELSE 'pending'
    END as stage1_methodology_status,
    bar.prompt_methodology_compliance_score,
    bar.methodology_compliance_gate_passed as stage1_methodology_compliant,
    
    -- Stage 2 Methodology Status  
    CASE
        WHEN ber.id IS NULL THEN 'not_started'
        WHEN ber.stage_status = 'completed' AND ber.methodology_compliance_gate_passed THEN 'methodology_compliant'
        WHEN ber.stage_status = 'completed' AND ber.overall_quality_gate_passed THEN 'completed_needs_review'
        WHEN ber.stage_status = 'failed' THEN 'failed' 
        WHEN ber.stage_status = 'in_progress' THEN 'in_progress'
        ELSE 'pending'
    END as stage2_methodology_status,
    ber.enrichment_criteria_methodology_score,
    ber.methodology_compliance_gate_passed as stage2_methodology_compliant,
    
    -- Overall Methodology Compliance
    CASE
        WHEN bar.methodology_compliance_gate_passed AND ber.methodology_compliance_gate_passed THEN 'fully_compliant'
        WHEN bar.methodology_compliance_gate_passed AND ber.id IS NULL THEN 'stage1_compliant_ready_stage2'
        WHEN bar.id IS NOT NULL AND NOT bar.methodology_compliance_gate_passed THEN 'stage1_methodology_issues'
        WHEN ber.id IS NOT NULL AND NOT ber.methodology_compliance_gate_passed THEN 'stage2_methodology_issues'
        WHEN b.processing_agent IS NOT NULL THEN 'in_progress'
        ELSE 'ready_for_processing'
    END as overall_methodology_status,
    
    -- Database Status
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
LEFT JOIN book_analysis_results bar ON b.id = bar.book_id
LEFT JOIN book_enrichment_results ber ON b.id = ber.book_id
WHERE b.title_alias IS NULL OR b.keywords IS NULL -- Focus on books needing processing
ORDER BY b.created_at DESC;

-- =============================================
-- ENHANCED INDEXES FOR METHODOLOGY TRACKING
-- =============================================

-- Stage 1 methodology indexes
CREATE INDEX IF NOT EXISTS idx_book_analysis_methodology_compliance ON book_analysis_results(methodology_compliance_gate_passed, prompt_methodology_compliance_score);
CREATE INDEX IF NOT EXISTS idx_book_analysis_websearch ON book_analysis_results(websearch_performed, book_content_verified);
CREATE INDEX IF NOT EXISTS idx_book_analysis_four_elements ON book_analysis_results(four_elements_requirement_met);
CREATE INDEX IF NOT EXISTS idx_book_analysis_file_creation ON book_analysis_results(file_creation_requirement_met, analysis_file_generated);

-- Stage 2 methodology indexes  
CREATE INDEX IF NOT EXISTS idx_book_enrichment_methodology_compliance ON book_enrichment_results(methodology_compliance_gate_passed, enrichment_criteria_methodology_score);
CREATE INDEX IF NOT EXISTS idx_book_enrichment_title_alias_compliance ON book_enrichment_results(title_alias_criteria_compliance);
CREATE INDEX IF NOT EXISTS idx_book_enrichment_keywords_compliance ON book_enrichment_results(keywords_criteria_compliance);
CREATE INDEX IF NOT EXISTS idx_book_enrichment_sql_compliance ON book_enrichment_results(sql_schema_compliance_verified, sql_title_alias_format_correct, sql_keywords_array_format_correct);

-- Combined methodology tracking
CREATE INDEX IF NOT EXISTS idx_complete_methodology_status ON book_analysis_results(methodology_compliance_gate_passed) WHERE methodology_compliance_gate_passed = true;
CREATE INDEX IF NOT EXISTS idx_enrichment_methodology_status ON book_enrichment_results(methodology_compliance_gate_passed) WHERE methodology_compliance_gate_passed = true;

-- =============================================
-- METHODOLOGY COMPLIANCE TRIGGERS
-- =============================================

-- Stage 1 Methodology Compliance Trigger
CREATE OR REPLACE FUNCTION update_stage1_methodology_compliance()
RETURNS TRIGGER AS $$
BEGIN
    -- Check individual methodology requirements
    NEW.websearch_requirement_met = NEW.websearch_performed AND NEW.book_content_verified;
    NEW.four_elements_requirement_met = (
        NEW.genre_classification IS NOT NULL AND
        NEW.methodological_foundation IS NOT NULL AND
        NEW.scholarly_perspective IS NOT NULL AND
        NEW.core_argumentative_thesis IS NOT NULL
    );
    NEW.network_description_requirement_met = (NEW.network_description IS NOT NULL AND NEW.network_description_addresses_all_four);
    NEW.file_creation_requirement_met = NEW.analysis_file_generated;
    
    -- Overall methodology compliance
    NEW.methodology_compliance_gate_passed = (
        NEW.websearch_requirement_met AND
        NEW.four_elements_requirement_met AND
        NEW.network_description_requirement_met AND
        NEW.structural_flowchart_requirement_met AND
        NEW.extreme_specificity_requirement_met AND
        NEW.file_creation_requirement_met
    );
    
    -- Quality gates
    NEW.quality_gate_passed = (NEW.analysis_quality_score >= 7);
    NEW.ready_for_stage2 = (NEW.quality_gate_passed AND NEW.methodology_compliance_gate_passed);
    NEW.updated_at = now();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_stage1_methodology_compliance
    BEFORE UPDATE ON book_analysis_results
    FOR EACH ROW
    EXECUTE FUNCTION update_stage1_methodology_compliance();

-- Stage 2 Methodology Compliance Trigger
CREATE OR REPLACE FUNCTION update_stage2_methodology_compliance()
RETURNS TRIGGER AS $$
BEGIN
    -- Check individual methodology requirements
    NEW.title_alias_criteria_compliance = (
        NEW.transliteration_variations IS NOT NULL AND
        NEW.definite_article_variants IS NOT NULL AND
        NEW.special_character_simplifications IS NOT NULL AND
        NEW.vowel_consonant_variations IS NOT NULL AND
        NEW.partial_memorable_titles IS NOT NULL AND
        NEW.conceptual_descriptive_titles IS NOT NULL
    );
    
    NEW.keywords_criteria_compliance = (
        NEW.core_concept_keywords IS NOT NULL AND
        NEW.associated_figures_keywords IS NOT NULL AND
        NEW.associated_places_keywords IS NOT NULL AND
        NEW.associated_events_keywords IS NOT NULL AND
        NEW.broader_subject_keywords IS NOT NULL AND
        NEW.synonyms_related_keywords IS NOT NULL
    );
    
    -- Individual quality gates
    NEW.enrichment_quality_gate_passed = (NEW.enrichment_quality_score >= 8);
    NEW.sql_validation_gate_passed = (NEW.sql_syntax_validated AND NEW.sql_schema_compliance_verified);
    NEW.execution_gate_passed = NEW.execution_successful;
    
    -- Overall methodology compliance
    NEW.methodology_compliance_gate_passed = (
        NEW.title_alias_criteria_compliance AND
        NEW.keywords_criteria_compliance AND
        NEW.description_word_count BETWEEN 100 AND 150 AND
        NEW.academic_encyclopedic_tone_maintained AND
        NEW.single_paragraph_flow_achieved
    );
    
    -- Overall quality gate (all must pass)
    NEW.overall_quality_gate_passed = (
        NEW.enrichment_quality_gate_passed AND 
        NEW.sql_validation_gate_passed AND 
        NEW.execution_gate_passed AND
        NEW.methodology_compliance_gate_passed
    );
    
    NEW.ready_for_pipeline_completion = NEW.overall_quality_gate_passed;
    NEW.updated_at = now();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_stage2_methodology_compliance
    BEFORE UPDATE ON book_enrichment_results  
    FOR EACH ROW
    EXECUTE FUNCTION update_stage2_methodology_compliance();

-- =============================================
-- METHODOLOGY COMPLIANCE MONITORING QUERIES
-- =============================================

COMMENT ON TABLE book_analysis_results IS 'Complete preservation reservoir for Stage 1 hybrid academic analysis with full Academic-Analysis-Prompt-V4-Hybrid.md methodology compliance tracking';
COMMENT ON TABLE book_enrichment_results IS 'Complete preservation reservoir for Stage 2 enrichment generation with full ENRICHMENT_CRITERIA.md methodology compliance tracking';
COMMENT ON VIEW stage1_methodology_compliance IS 'Academic-Analysis-Prompt-V4-Hybrid.md methodology compliance monitoring';
COMMENT ON VIEW stage2_methodology_compliance IS 'ENRICHMENT_CRITERIA.md methodology compliance monitoring';
COMMENT ON VIEW complete_pipeline_status IS 'Complete pipeline status with full methodology compliance tracking';

-- Example Methodology Compliance Monitoring Queries:
/*
-- Stage 1 Methodology Compliance Summary
SELECT 
    COUNT(*) as total_stage1,
    COUNT(CASE WHEN methodology_compliance_gate_passed THEN 1 END) as methodology_compliant,
    COUNT(CASE WHEN websearch_requirement_met THEN 1 END) as websearch_compliant,
    COUNT(CASE WHEN four_elements_requirement_met THEN 1 END) as four_elements_compliant,
    COUNT(CASE WHEN file_creation_requirement_met THEN 1 END) as file_creation_compliant
FROM stage1_methodology_compliance;

-- Stage 2 Methodology Compliance Summary  
SELECT 
    COUNT(*) as total_stage2,
    COUNT(CASE WHEN methodology_compliance_gate_passed THEN 1 END) as methodology_compliant,
    COUNT(CASE WHEN title_alias_criteria_compliance THEN 1 END) as title_alias_compliant,
    COUNT(CASE WHEN keywords_criteria_compliance THEN 1 END) as keywords_compliant,
    COUNT(CASE WHEN word_count_compliant THEN 1 END) as description_compliant
FROM stage2_methodology_compliance;

-- Overall Pipeline Methodology Status
SELECT 
    overall_methodology_status,
    COUNT(*) as count
FROM complete_pipeline_status 
GROUP BY overall_methodology_status
ORDER BY count DESC;
*/