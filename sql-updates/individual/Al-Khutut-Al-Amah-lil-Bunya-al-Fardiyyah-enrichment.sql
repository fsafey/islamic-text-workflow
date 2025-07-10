-- SQL Enrichment for Al-Khutut Al-_Amah lil-Bunya al-Fardiyyah
-- Book ID: 3ba2188d-6758-4809-87ab-9f6cf658ba37
-- Author: Al-Sheikh Yasin Hasan Isa Al-Amili

UPDATE books 
SET 
    title_alias = 'General Principles for Individual Islamic Structure',
    keywords = ARRAY[
        'Islamic jurisprudence', 'individual obligations', 'personal development', 
        'Shia Imami fiqh', 'Jabal Amil scholars', 'usul al-fiqh', 
        'spiritual development', 'Islamic character', 'practical guidance',
        'religious structure', 'personal worship', 'Islamic conduct',
        'individual responsibility', 'Islamic identity', 'spiritual discipline',
        'daily practice', 'religious obligations', 'Islamic lifestyle',
        'character building', 'personal purification', 'Islamic ethics'
    ],
    description = 'A comprehensive jurisprudential treatise by Al-Sheikh Yasin Hasan Isa Al-Amili that establishes foundational principles (al-khutut al-amah) for structuring individual Islamic identity and practice. Drawing from the rich Jabal Amil scholarly tradition, this work systematically addresses the balance between personal religious obligations and their practical implementation in daily life. The book covers fundamental Islamic principles, personal worship, spiritual development, social dimensions of individual practice, and contemporary applications of Islamic law. It serves as both a practical guide for individual Muslim development and a theoretical framework bridging traditional jurisprudential principles with modern spiritual guidance. The work emphasizes the integration of Islamic law with personal character building, making it an essential resource for understanding how to structure one''s life according to Islamic principles while maintaining spiritual growth and ethical conduct in contemporary contexts.'
WHERE id = '3ba2188d-6758-4809-87ab-9f6cf658ba37';

-- Verification query
SELECT id, title, title_alias, array_length(keywords, 1) as keyword_count, 
       length(description) as description_length 
FROM books 
WHERE id = '3ba2188d-6758-4809-87ab-9f6cf658ba37';