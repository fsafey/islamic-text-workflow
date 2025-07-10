-- SQL Enrichment for Al-Istiqaamah Wa Al-Thabat Fi Shakhssiyat Al-Qiyadah
-- Book UUID: 2773a505-9939-46ec-a281-6b9b836d012e
-- Generated: 2025-07-03 by Islamic Text Processing Workflow

UPDATE books 
SET 
    title_alias = 'Steadfastness and Firmness in Leadership Personality; Al-Istiqaamah Wa Al-Thabat Fi Shakhssiyat Al-Qiyadah; Uprightness and Stability in Leadership Character; Al Istiqaamah Wa Al Thabat; Istiqamah and Thabat in Leadership; Steadfastness in Leadership; Islamic Leadership Ethics; Moral Leadership in Islam; Character and Leadership; Leadership Personality Development',
    
    keywords = ARRAY['Istiqaamah', 'Steadfastness', 'Thabat', 'Firmness', 'Leadership', 'Qiyadah', 'Islamic Leadership', 'Leadership Ethics', 'Moral Leadership', 'Character Development', 'Shakhssiyat', 'Personality', 'Islamic Governance', 'Leadership Character', 'Steadfast Leader', 'Firm Character', 'Moral Authority', 'Religious Leadership', 'Islamic Politics', 'Leadership Principles', 'Uprightness', 'Stability', 'Character Traits', 'Leadership Qualities', 'Islamic Values', 'Moral Integrity', 'Righteous Leadership', 'Leadership Development', 'Islamic Ethics', 'Governance', 'Authority', 'Leadership Psychology', 'Character Building', 'Moral Foundations', 'Leadership Training', 'Islamic Management', 'Leadership Philosophy', 'Principled Leadership', 'Ethical Leadership', 'Character Formation', 'Leadership Wisdom', 'Islamic Leadership Theory', 'Leadership Accountability', 'Moral Responsibility', 'Leadership Guidance', 'Character Strength', 'Leadership Excellence', 'Islamic Leadership Models', 'Leadership Conduct', 'Moral Leadership Development']::text[],
    
    description = 'A comprehensive treatise on Islamic leadership ethics focusing on the essential character traits of steadfastness (Istiqaamah) and firmness (Thabat) required for authentic Islamic leadership. This work examines how moral steadfastness and character firmness serve as foundational prerequisites for legitimate religious and political authority in Islamic contexts. The author develops a systematic framework integrating Quranic principles, prophetic examples, and historical analysis to demonstrate that effective Islamic leadership requires unwavering moral integrity and character stability. The book provides practical guidance for cultivating these essential leadership qualities while addressing contemporary challenges facing Muslim leaders. Through detailed analysis of exemplary leaders from Islamic history and examination of leadership failures, this work offers both theoretical foundations and practical applications for developing principled Islamic leadership in modern contexts.'

WHERE id = '2773a505-9939-46ec-a281-6b9b836d012e';

-- Verification query to confirm update
SELECT id, title, title_alias, keywords, description 
FROM books 
WHERE id = '2773a505-9939-46ec-a281-6b9b836d012e';