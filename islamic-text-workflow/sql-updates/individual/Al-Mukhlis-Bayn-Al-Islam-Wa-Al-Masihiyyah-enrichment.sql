-- SQL Enrichment for Al-Mukhlis Bayn Al-Islam Wa-Al-Masihiyyah
-- Book ID: f3528457-7724-402e-8aac-3c1e828e39b3
-- Author: Basim Al-Hashimi

UPDATE books 
SET 
    title_alias = 'The Sincere One Between Islam and Christianity',
    keywords = ARRAY[
        'interfaith dialogue', 'comparative theology', 'Islam Christianity', 
        'sincere faith', 'ikhlas', 'religious sincerity', 'authentic devotion',
        'People of the Book', 'Ahl al-Kitab', 'monotheistic traditions',
        'spiritual common ground', 'theological comparison', 'interfaith relations',
        'religious dialogue', 'faith authenticity', 'devotional practices',
        'comparative religion', 'spiritual sincerity', 'religious understanding',
        'Christian-Muslim dialogue', 'theological bridge', 'faith traditions',
        'religious cooperation', 'spiritual devotion', 'interfaith engagement'
    ],
    description = 'A comprehensive comparative theological treatise by Basim Al-Hashimi examining the concept of sincere faith (al-mukhlis) as a bridge between Islam and Christianity. The work systematically analyzes the parallel concepts of spiritual sincerity and authentic devotion in both traditions, demonstrating how sincere faith serves as fundamental common ground for interfaith dialogue. Drawing from Quranic texts, Christian scriptures, and theological traditions, the book explores the concept of ikhlas (sincerity) in Islamic spirituality alongside Christian notions of authentic faith and devotion. The author provides practical guidelines for respectful interfaith engagement while maintaining doctrinal integrity, making it a valuable resource for understanding both commonalities and differences between Islamic and Christian spirituality. The work addresses contemporary challenges in interfaith relations, offering a model for how sincere believers can foster mutual understanding and cooperation in today''s pluralistic world while honoring the unique characteristics of each religious tradition.'
WHERE id = 'f3528457-7724-402e-8aac-3c1e828e39b3';

-- Verification query
SELECT id, title, title_alias, array_length(keywords, 1) as keyword_count, 
       length(description) as description_length 
FROM books 
WHERE id = 'f3528457-7724-402e-8aac-3c1e828e39b3';