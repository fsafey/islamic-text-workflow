# SQL Schema Guide for Islamic Text Workflow

## Critical Database Field Types

### `books.keywords` Field
**Type**: `text[]` (PostgreSQL array)
**Format Required**: `ARRAY['keyword1', 'keyword2', 'keyword3']`

**Correct SQL Syntax**:
```sql
UPDATE books SET 
  keywords = ARRAY['Islamic theology', 'Aqidah', 'Kalam', 'Shia Islam']
WHERE id = 'book-uuid-here';
```

**Incorrect Syntax** (will fail):
```sql
-- DON'T DO THIS:
UPDATE books SET 
  keywords = 'Islamic theology, Aqidah, Kalam'  -- Missing ARRAY[]
WHERE id = 'book-uuid-here';
```

### `books.title_alias` Field
**Type**: `text`
**Format**: Semicolon-separated string
**Example**: `'Al-Dhunub al-Kabirah; The Major Sins; Al Dhunub al Kabirah'`

### SQL Template for Book Enrichment
```sql
UPDATE books SET 
  title_alias = 'Title Variation 1; Title Variation 2; Title Variation 3',
  keywords = ARRAY[
    'keyword1', 'keyword2', 'keyword3', 'keyword4', 'keyword5'
  ],
  description = 'Academic description of the book content...'
WHERE id = 'BOOK_UUID_HERE';
```

## Common Error Patterns

1. **Array Syntax Missing**: Forgetting `ARRAY[]` wrapper for keywords
2. **Quote Escaping**: Single quotes in content need escaping: `'Imam''s teachings'`
3. **UUID Format**: Must be valid UUID format with hyphens

## Validation Before Execution
Always test SQL with small subset before bulk operations:
```sql
-- Test query first
SELECT 
  ARRAY['test', 'array'] as test_keywords,
  'test; alias' as test_alias;
```