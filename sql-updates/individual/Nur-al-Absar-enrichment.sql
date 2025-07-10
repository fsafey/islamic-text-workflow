-- Enrichment for Nur al-Absar fi Manaqib Al Bayt al-Nabi al-Mukhtar
-- Book ID: ef299581-b29f-4ac1-bc05-9702829eec33
-- Author: al-Shaykh Mu_min al-Shiblaji
-- Islamic-Text-Processor-8 - 2025-07-04

UPDATE books 
SET 
    title_alias = 'Nur al-Absar fi Manaqib Al Bayt al-Nabi al-Mukhtar; Light of the Eyes on the Virtues of the Prophet''s Household; Noor ul Absar; Nur al Absar fi Manaqib Aal Bayt; The Light of Vision; Virtues of the Prophet''s Family; Manaqib Ahl al-Bayt; Light of the Eyes; Nur al-Absar Shablanji; The Illumination of Sight',
    
    keywords = ARRAY[
        'Ahl al-Bayt', 'Prophet''s Household', 'Manaqib', 'Virtues', 'Fourteen Infallibles', 
        'Imam Ali', 'Imam Hasan', 'Imam Husayn', 'Fatima al-Zahra', 'Khadija', 
        'Twelve Imams', 'Sadat', 'Biographical literature', 'Hagiography', 'Sunni perspective',
        'Shafi''i school', 'Al-Azhar', 'Karamat', 'Miracles', 'Fadail', 'Excellences',
        'Intercession', 'Tawassul', 'Ziyarat', 'Visitation', 'Devotional practices',
        'Inter-sectarian', 'Sunni-Shia relations', 'Islamic biography', 'Sira literature',
        'Sufi influence', 'Mystical Islam', 'Sayyida Nafisa', 'Vow fulfillment',
        'Four Caliphs', 'Abu Bakr', 'Umar', 'Uthman', 'Rightly-Guided Caliphs',
        'Karbala', 'Martyrdom', 'Shahada', 'Ghaybah', 'Occultation', 'Mahdi',
        'Zayn al-Abidin', 'Ali ibn Husayn', 'Muhammad al-Baqir', 'Ja''far al-Sadiq',
        'Musa al-Kazim', 'Ali al-Rida', 'Muhammad al-Jawad', 'Ali al-Hadi',
        'Hasan al-Askari', 'Muhammad al-Mahdi', 'Imam al-Muntazar', 'Hidden Imam',
        'Four Sunni Imams', 'Abu Hanifa', 'Malik', 'Shafi''i', 'Ahmad ibn Hanbal',
        'Madhahib', 'Schools of jurisprudence', 'Fiqh', 'Islamic law', 'Hadith',
        'Baraka', 'Blessing', 'Spiritual inheritance', 'Noble lineage', 'Sharaf',
        'Purity', 'Tahara', 'Chastity', 'Iffah', 'Asceticism', 'Zuhd',
        'Knowledge', 'Ilm', 'Wisdom', 'Hikma', 'Piety', 'Taqwa', 'Forbearance', 'Hilm',
        'Reconciliation', 'Sulh', 'Peace treaty', 'Unity', 'Harmony', 'Consensus',
        'Shrine visitation', 'Pilgrimage', 'Ziyarat practices', 'Devotional literature',
        'Religious poetry', 'Praise literature', 'Panegyric', 'Eulogy', 'Commemoration',
        'Mu''min Shablanji', 'Shablanji', 'Al-Shablanji', 'Egyptian scholar', 'Azhari scholar'
    ],
    
    description = 'A comprehensive biographical work on the virtues and merits of the Prophet''s household (Ahl al-Bayt) written by the Sunni Shafi''i scholar Mu''min al-Shablanji (d. c. 1834). Originally composed as a vow of gratitude to Sayyida Nafisa for the healing of the author''s eyes, this work bridges Sunni orthodoxy with reverence for the Prophet''s family. The book is structured in four parts: (1) the Prophet and the Four Caliphs, (2) the Twelve Imams from Hasan and Husayn through the Mahdi, (3) the blessed women of the household including Khadija and Fatima, and (4) the Prophet''s descendants and the Four Sunni Imams. Distinguished by its inter-sectarian approach, the work demonstrates how veneration of Ahl al-Bayt constitutes authentic Sunni devotion, providing both theological justification and practical guidance for popular religious practices. The author synthesizes biographical narratives, miracle accounts (karamat), and devotional literature to create a harmonious framework that validates traditional Islamic practices within orthodox bounds. This scholarly work serves as an important bridge between different Islamic traditions while maintaining credibility within mainstream Sunni scholarship.'

WHERE id = 'ef299581-b29f-4ac1-bc05-9702829eec33';

-- Verify the update
SELECT id, title, title_alias, array_length(keywords, 1) as keyword_count, 
       length(description) as description_length
FROM books 
WHERE id = 'ef299581-b29f-4ac1-bc05-9702829eec33';