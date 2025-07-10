-- 📊 Book Enrichment Reservoir Table
-- Central information flow hub for collaborative agent enrichment

CREATE TABLE book_enrichment_reservoir (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL REFERENCES books(id),
    
    -- Book Context
    title TEXT NOT NULL,
    author_name TEXT,
    
    -- Agent Contributions
    flowchart_analysis JSONB,           -- Flowchart Mapper Agent findings
    network_analysis JSONB,             -- Network Mapper Agent findings  
    metadata_findings JSONB,            -- Metadata Hunter Agent discoveries
    content_synthesis JSONB,            -- Content Synthesizer Agent output
    
    -- Processing Tracking
    agents_completed TEXT[] DEFAULT '{}', -- Track which agents finished
    processing_stage TEXT DEFAULT 'pending', -- pending, in_progress, synthesis, completed
    
    -- Agent Status Flags
    flowchart_completed BOOLEAN DEFAULT FALSE,
    flowchart_completed_at TIMESTAMP,
    
    network_completed BOOLEAN DEFAULT FALSE,
    network_completed_at TIMESTAMP,
    
    metadata_completed BOOLEAN DEFAULT FALSE,
    metadata_completed_at TIMESTAMP,
    
    synthesis_completed BOOLEAN DEFAULT FALSE,
    synthesis_completed_at TIMESTAMP,
    
    -- Error Handling
    processing_errors JSONB DEFAULT '[]',
    retry_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for performance
CREATE INDEX idx_reservoir_book_id ON book_enrichment_reservoir(book_id);
CREATE INDEX idx_reservoir_stage ON book_enrichment_reservoir(processing_stage);
CREATE INDEX idx_reservoir_agents ON book_enrichment_reservoir USING GIN(agents_completed);
CREATE INDEX idx_reservoir_ready_for_synthesis ON book_enrichment_reservoir(flowchart_completed, network_completed, metadata_completed) 
    WHERE synthesis_completed = FALSE;

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_reservoir_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    
    -- Auto-update processing stage based on completion status
    IF NEW.synthesis_completed = TRUE THEN
        NEW.processing_stage = 'completed';
        NEW.completed_at = NOW();
    ELSIF NEW.flowchart_completed = TRUE AND NEW.network_completed = TRUE AND NEW.metadata_completed = TRUE THEN
        NEW.processing_stage = 'synthesis';
    ELSIF NEW.flowchart_completed = TRUE OR NEW.network_completed = TRUE OR NEW.metadata_completed = TRUE THEN
        NEW.processing_stage = 'in_progress';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_reservoir_timestamp
    BEFORE UPDATE ON book_enrichment_reservoir
    FOR EACH ROW
    EXECUTE FUNCTION update_reservoir_timestamp();

-- Agent coordination functions
CREATE OR REPLACE FUNCTION get_books_ready_for_agent(agent_type TEXT)
RETURNS TABLE(
    reservoir_id UUID,
    book_id UUID,
    title TEXT,
    author_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.book_id,
        r.title,
        r.author_name
    FROM book_enrichment_reservoir r
    WHERE r.processing_stage IN ('pending', 'in_progress')
    AND CASE 
        WHEN agent_type = 'flowchart' THEN r.flowchart_completed = FALSE
        WHEN agent_type = 'network' THEN r.network_completed = FALSE  
        WHEN agent_type = 'metadata' THEN r.metadata_completed = FALSE
        WHEN agent_type = 'synthesis' THEN (r.flowchart_completed = TRUE AND r.network_completed = TRUE AND r.metadata_completed = TRUE AND r.synthesis_completed = FALSE)
        ELSE FALSE
    END
    ORDER BY r.created_at ASC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- Initialize reservoir for books in processing queue
CREATE OR REPLACE FUNCTION initialize_reservoir_from_queue()
RETURNS TABLE(
    processed_count INTEGER,
    reservoir_entries INTEGER
) AS $$
DECLARE
    process_count INTEGER := 0;
    entry_count INTEGER := 0;
BEGIN
    -- Insert books from processing queue into reservoir
    INSERT INTO book_enrichment_reservoir (book_id, title, author_name)
    SELECT 
        b.id,
        b.title,
        a.name
    FROM book_processing_queue bpq
    JOIN books b ON b.id = bpq.book_id
    LEFT JOIN authors a ON a.id = b.author_id
    WHERE bpq.status = 'pending'
    AND NOT EXISTS (
        SELECT 1 FROM book_enrichment_reservoir ber 
        WHERE ber.book_id = b.id
    )
    LIMIT 100; -- Start with 100 books
    
    GET DIAGNOSTICS process_count = ROW_COUNT;
    
    SELECT COUNT(*) INTO entry_count FROM book_enrichment_reservoir;
    
    RETURN QUERY SELECT process_count, entry_count;
END;
$$ LANGUAGE plpgsql;

-- RLS Policies
ALTER TABLE book_enrichment_reservoir ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role full access on reservoir"
    ON book_enrichment_reservoir
    FOR ALL 
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Authenticated read access on reservoir"
    ON book_enrichment_reservoir
    FOR SELECT
    TO authenticated
    USING (true);

COMMENT ON TABLE book_enrichment_reservoir IS 'Central hub for collaborative agent enrichment - agents contribute findings that flow into final book enrichment';