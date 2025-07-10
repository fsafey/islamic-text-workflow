-- SQL Enrichment for Al-Wajibat Al-Zawjiyyah lil-Mar_a fi Al-Islam
-- Book ID: 99686a00-c0a5-4505-8de1-0f5ce10d19b7
-- Author: Doctor Reza Bak Najad

UPDATE books 
SET 
    title_alias = 'The Marital Duties of Women in Islam: A Jurisprudential Analysis',
    keywords = ARRAY[
        'Islamic family law',
        'marital duties',
        'women in Islam',
        'Islamic jurisprudence',
        'matrimonial obligations',
        'spousal rights',
        'gender roles',
        'religious obligations',
        'family structure',
        'conjugal responsibilities',
        'Islamic marriage',
        'women''s rights',
        'matrimonial law',
        'religious duties',
        'marital relationships',
        'Islamic ethics',
        'family jurisprudence',
        'contemporary scholarship',
        'legal obligations',
        'religious guidance'
    ],
    description = 'A comprehensive jurisprudential analysis of the marital duties and obligations of women within Islamic family law by Doctor Reza Bak Najad. This scholarly work examines the traditional jurisprudential framework that governs women''s roles and responsibilities in Islamic marriage, exploring the balance between religious obligations and contemporary understandings of gender relations. The author provides a detailed examination of the legal foundations for marital duties as established in Islamic law, including the concepts of obedience (ṭāʿa), domestic responsibilities, and the reciprocal nature of spousal rights and obligations. The work addresses the tensions between classical jurisprudential constructions and modern perspectives on women''s rights, offering scholarly insights into how Islamic family law principles can be understood and applied in contemporary contexts while maintaining fidelity to religious teachings.'
WHERE id = '99686a00-c0a5-4505-8de1-0f5ce10d19b7';