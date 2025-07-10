-- SQL Enrichment for Muqattafat Wilaeyya by al-Shaykh al-Wahid al-Khurasani
-- UUID: 1ce5113c-50f3-4c40-ba09-74f23acc6f2f
-- Generated: 2025-07-03

UPDATE books 
SET 
    title_alias = 'Selections on Religious Authority',
    keywords = ARRAY[
        'Muqattafat Wilaeyya',
        'Selections on Religious Authority',
        'Wilayah doctrine',
        'Islamic jurisprudence',
        'Religious authority',
        'Wahid Khurasani',
        'Contemporary fiqh',
        'Wilayat al-Faqih',
        'Guardianship of Jurist',
        'Juridical fragments',
        'Usuli jurisprudence',
        'Ijtihad methodology',
        'Legal authority',
        'Family law Wilayah',
        'Political authority',
        'Commercial law',
        'Contemporary Islamic law',
        'Shia jurisprudence',
        'Legal guardianship',
        'Modern fatwas'
    ],
    description = 'A comprehensive juridical compendium that systematically applies the doctrine of religious authority (Wilayah) to contemporary Islamic legal issues. This work combines traditional Usul al-Fiqh methodology with modern legal reasoning to address complex questions of religious and legal authority in contemporary contexts. The collection covers theological foundations, institutional applications, and political dimensions of Wilayah, including family law, commercial transactions, and governance. Through selective compilation of juridical fragments (Muqattafat), the work provides both theoretical grounding and practical guidance for modern applications of Islamic authority principles, making it an essential resource for understanding how traditional concepts of Wilayah adapt to contemporary legal and social challenges.'
WHERE id = '1ce5113c-50f3-4c40-ba09-74f23acc6f2f';

-- Verification query
SELECT id, title, title_alias, keywords, description 
FROM books 
WHERE id = '1ce5113c-50f3-4c40-ba09-74f23acc6f2f';