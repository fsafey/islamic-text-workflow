-- BOOK ENRICHMENT: Al-Mar'a fi Nahj Al-Balagha
-- UUID: 5231a689-93f7-49f2-879b-4e916af61eca
-- Author: Dr. Najwa Saleh Al-Jawad
-- Generated: July 4, 2025

UPDATE books 
SET 
    title_alias = 'Women in Nahj al-Balagha; Al-Mar''a fi Nahj Al-Balagha; Al Maraa fi Nahj Al Balagha; Women in the Path of Eloquence; Al-Mar''ah fi Nahj al-Balaghah; Women in Ali''s Teachings; Feminist Analysis of Nahj al-Balagha; Gender in Nahj al-Balagha; Al-Maraa fi Nahj al-Balagha; Women in Imam Ali''s Sermons; Islamic Feminism and Nahj al-Balagha; Al-Mar''a fi Nahj al-Balaghah',
    
    keywords = ARRAY[
        'Women in Islam', 'Nahj al-Balagha', 'Imam Ali ibn Abi Talib', 'Islamic feminism', 'Gender studies', 
        'Shia Islam', 'Women''s rights', 'Islamic theology', 'Feminist hermeneutics', 'Classical Islamic texts',
        'Dr. Najwa Saleh Al-Jawad', 'Contemporary Islamic scholarship', 'Gender discourse', 'Ahl al-Bayt',
        'Sayyida Fatima', 'Women''s status', 'Islamic law', 'Fiqh', 'Mujtahidat', 'Female scholars',
        'Karbala narrative', 'Wilayah', 'Guardianship', 'Spiritual equality', 'Quranic teachings',
        'Hadith literature', 'Social commentary', 'Religious doctrine', 'Hermeneutical analysis',
        'Feminist theology', 'Progressive Islam', 'Modern Muslim women', 'Islamic societies',
        'Textual analysis', 'Exegesis', 'Commentary traditions', 'Arabian society', 'Early Islam',
        'Women''s education', 'Leadership', 'Religious authority', 'Misogyny', 'Gender equality',
        'Islamic reform', 'Contemporary applications', 'Theological implications', 'Cultural context'
    ],
    
    description = 'This scholarly work examines the status and rights of women in Islam through the lens of Imam Ali ibn Abi Talib''s teachings in Nahj al-Balagha. Dr. Najwa Saleh Al-Jawad employs feminist hermeneutical analysis to address controversial passages about women in this classical Shia text, arguing for contextual reinterpretation that bridges traditional Islamic scholarship with contemporary gender studies. The book systematically analyzes specific sermons and letters, particularly those addressing women''s intellectual and spiritual capacity, while providing historical contextualization of 7th-century Arabian society. Through comparative analysis with Quranic teachings and modern Islamic feminist theology, the work demonstrates how apparent contradictions in Ali''s statements about women can be reconciled through sophisticated textual analysis, contributing to progressive Shia Islamic feminism and contemporary debates about women''s roles in Islamic societies.'

WHERE id = '5231a689-93f7-49f2-879b-4e916af61eca';

-- Verify the update
SELECT title, title_alias, array_length(keywords, 1) as keyword_count, length(description) as desc_length 
FROM books 
WHERE id = '5231a689-93f7-49f2-879b-4e916af61eca';