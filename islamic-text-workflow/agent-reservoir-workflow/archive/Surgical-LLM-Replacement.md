# Claude Code Integration Plan: Surgical LLM Replacement

## Overview

PRESERVE the sophisticated existing agent
infrastructure while REPLACING only the
rule-based intelligence functions with
Claude Code CLI calls.

### What to Keep (Infrastructure):

Express server setup and all endpoints
(/health, /process, /agent-tokens,
/reset-tokens)

Supabase database integration and
connection

get_books_ready_for_agent database queries

Database update logic for
book_enrichment_reservoir

TokenTracker integration (extend for
Claude Code)

Processing loops and error handling

Methodology guidance loading

Statistics tracking (processedBooks,
errors)

All API contracts the orchestrator depends
on

### What to Replace (Intelligence):

analyzeIntellectualArchitecture() → Claude
Code CLI call with Islamic scholarship
expertise

conductBibliographicResearch() → Claude
Code CLI call with metadata research

All rule-based pattern matching functions
(identifyIslamicGenre(), etc.)

Massive hardcoded structures like
generateHadithCommentaryArchitecture()

### Implementation Strategy:

Extend TokenTracker to handle Claude Code
CLI response format

Create Claude Code execution function
within each existing agent

Replace intelligence functions with
Claude Code calls using agent-specific
system prompts

Maintain identical database update
structure

Keep all existing error handling and
logging

Preserve Docker deployment but integrate
Claude Code CLI into existing containers

### Benefits:

No orchestrator changes needed

All existing monitoring and health checks
preserved

Database integration unchanged

API contracts maintained

Sophisticated infrastructure kept intact

Only intelligence upgraded to actual LLM

This approach respects your sophisticated
orchestration while gaining true LLM
capabilities.


 first thing, update the 
  documentation'/Users/faried
    
  s/imam-lib-masha-allah/islamic-text-workflow/agent-
    
  reservoir-workflow/production/CLAUDE-CODE-STEP-BY-S
    TEP-INTEGRATION-PLAN.md', then 
    
  proceed'/Users/farieds/imam-lib-masha-allah/islamic
    
  -text-workflow/agent-reservoir-workflow/production/
    CLAUDE-CODE-INTEGRATION-PLAN.md' update this as 
    well


    Current Gap Analysis:

  - ❌ Migration needed: Move proven integration to secure
  container

  Execution Plan - Secure Container Migration

  Phase 1: Build Docker Infrastructure (Critical Foundation) - accomplished 

  Phase 2: Migrate Proven Flowchart Mapper

  1. Container build and startup testing
  2. Validate Claude Code CLI works within security constraints
  3. Test API endpoint compatibility (orchestrator
  communication)
  4. Verify database integration from containerized environment
  5. Validate token tracking and session management


  Phase 4: Orchestrator Integration Update

  1. Modify orchestrator to spawn Docker containers instead of
  direct Node.js processes
  2. Update health monitoring for containerized agents
  3. Test full processing pipeline with secure containers
