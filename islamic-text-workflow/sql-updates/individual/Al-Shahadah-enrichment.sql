-- SQL enrichment for Al-Shahadah by Dr. Ali Shari'ati
-- Book ID: a06de1e1-b02c-4a25-82f5-289c6f76f03f
-- Author: Al-Shahid Dr. Ali Shari'ati
-- Research completed on: 2025-07-03

UPDATE books 
SET 
    title_alias = 'al-shahadah-testimony-martyrdom-shariati',
    keywords = ARRAY[
        'shahadah', 'testimony', 'martyrdom', 'ali shariati', 'red shiism', 
        'revolutionary islam', 'islamic revolution', 'sociology of religion',
        'intellectual awakening', 'resistance', 'social justice', 'iranian revolution',
        'shiite ideology', 'modern islamic thought', 'islamic sociology'
    ],
    description = 'Al-Shahadah (The Testimony) represents Dr. Ali Shari''ati''s profound exploration of the concept of testimony and martyrdom in Islamic revolutionary thought. This work embodies Shari''ati''s distinctive approach to "red Shiism" - a revolutionary interpretation of Shiite Islam that emphasizes active resistance against oppression rather than passive acceptance. Drawing from his background as a sociologist of religion and intellectual revolutionary, Shari''ati reinterprets traditional Islamic concepts of testimony (shahadah) within a modern framework of social justice and political awakening. The work reflects his broader mission to revive the revolutionary currents of Shiism, distinguishing between the passive "black Shiism" of traditional seminaries and the active "red Shiism" that calls for intellectual and spiritual awakening. As one of the most influential Iranian intellectuals of the 20th century, Shari''ati''s treatment of testimony and martyrdom served as ideological groundwork for the Islamic Revolution, combining Marxist and existentialist thought with religious and nationalist discourse to create a uniquely modern Islamic revolutionary ideology.',
    updated_at = NOW()
WHERE id = 'a06de1e1-b02c-4a25-82f5-289c6f76f03f';

-- Verification query
SELECT id, title, title_alias, keywords, description, updated_at
FROM books 
WHERE id = 'a06de1e1-b02c-4a25-82f5-289c6f76f03f';