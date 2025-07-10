-- Enrichment SQL for: Asl Al-Shia wa-Usulha
-- Book ID: 2e1f6d68-b7c2-4ff2-b947-d6d0708203c3
-- Author: al-Shaykh Muhammad Husayn Al-Kashif al-Ghita'
-- Agent: agent-database-integration-005 (Database Integration Manager)
-- Processing Date: 2025-07-04

UPDATE books SET 
  title_alias = 'The Origins of Shia Islam and Its Principles; Asl al-Shi''a wa Usuluha; The Foundation of Shia and Its Principles; Origins and Principles of Shi''ism; Shia Origin and Faith; Roots of Shia Islam; Foundations of Shi''ite Belief; Asl Ash-Shi''a Wa Usuluha; The Shia Origin and Faith; Principles of the Shi''a Denomination; Shi''a Fundamentals; Islamic Shi''a Doctrine',
  keywords = ARRAY[
    'Shia Islam origins', 'Shi''a principles', 'Imamate doctrine', 'Islamic sectarian studies', 
    'Comparative Islamic jurisprudence', 'Fiqh muqaran', 'Shi''a apologetics', 'Inter-sectarian dialogue',
    'Muhammad Husayn Kashif al-Ghita', 'Najaf scholarship', 'Shi''a orthodoxy', 'Usul al-Din',
    'Furu al-Din', 'Tawhid', 'Adl', 'Nubuwwa', 'Imamate', 'Ma''ad', 'Twelve Imams',
    'Ali ibn Abi Talib', 'Succession to Prophet', 'Caliphate vs Imamate', 'Divine appointment',
    'Isma infallibility', 'Shi''a Sunni unity', 'Islamic unity', 'Wahdat al-muslimin',
    'Ghuluw extremism', 'Taqiya', 'Ashura', 'Imam Husayn', 'Shafa''a intercession',
    'Ijtihad', 'Taqlid', 'Maraji''', 'Mujtahid', 'Ijma consensus', 'Aql reason',
    'Naql textual evidence', 'Quranic exegesis', 'Hadith analysis', 'Ayat al-Mubahala',
    'Ayat al-Wilaya', 'Hadith al-Thaqalayn', 'Ghadir Khumm', 'Prophetic traditions',
    'Early Islamic history', 'Salman al-Farisi', 'Abu Dharr al-Ghifari', 'Sahaba',
    'Tabi''in', 'Isnad', 'Sahih', 'Mutawatir', 'Salat', 'Hajj', 'Zakat', 'Khums',
    'Theological defense', 'Rational argumentation', 'Ecumenical approach', 'Scholarly consensus',
    'Religious authority', 'Spiritual guidance', 'Divine justice', 'Monotheism',
    'Prophethood', 'Resurrection', 'Afterlife', 'Judgment', 'Islamic law sources',
    'Marja''iyya', 'Shi''a jurisprudence', 'Islamic theology', 'Kalam', 'Comparative religion'
  ],
  description = 'A foundational apologetic treatise and systematic doctrinal exposition by the prominent Najaf scholar Muhammad Husayn Kashif al-Ghita'', presenting the historical origins and fundamental principles of Shi''a Islam. First published in 1932, this influential work employs comparative Islamic jurisprudence and historical analysis to defend Shi''a authenticity while promoting Islamic unity. The author systematically addresses misconceptions about Shi''ism, provides detailed explanations of the Five Pillars (Usul al-Din) including the distinctive doctrine of Imamate, and demonstrates commonalities with Sunni Islam. The work serves as both an academic resource for Islamic studies and a bridge for inter-sectarian understanding, establishing a model for ecumenical dialogue that maintains doctrinal integrity while fostering mutual respect between Islamic traditions.'
WHERE id = '2e1f6d68-b7c2-4ff2-b947-d6d0708203c3';