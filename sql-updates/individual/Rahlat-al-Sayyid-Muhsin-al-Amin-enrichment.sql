-- SQL Enrichment for "Rahlat al-Sayyid Muhsin al-Amin"
-- Book ID: 6dec3ad9-84c0-4262-afe3-dde263ea6b6a
-- Author: Al-Sayyid Muhsin al-Amin

UPDATE books 
SET 
    title_alias = 'The Travels of Sayyid Muhsin al-Amin',
    keywords = ARRAY[
        'memoir', 'autobiography', 'travels', 'biography', 'scholarly journey',
        'Damascus', 'Najaf', 'Jabal Amil', 'Lebanon', 'Iraq', 'Syria',
        'Shia scholar', 'Islamic education', 'religious education', 'jurisprudence',
        'A''yan al-Shi''a', 'mujtahid', 'ijtihad', 'Shi''a learning',
        'Islamic civilization', 'religious reform', 'scholarly tradition',
        'Najaf seminary', 'hawza', 'fiqh', 'usul al-fiqh',
        'al-Sayyida Zaynab', 'Arabic Scientific Assembly', 'Damascus mosque',
        'Jabal Amil scholars', 'Lebanese scholars', 'Syrian scholars',
        'biographical encyclopedia', 'cultural identity', 'religious teachings'
    ],
    description = 'A comprehensive memoir documenting the scholarly and spiritual journey of Al-Sayyid Muhsin al-Amin (1867-1952), one of the most prominent Shi''a scholars of the 20th century. This autobiographical work chronicles his travels between the major centers of Islamic learning: from his birthplace in Jabal Amil (Lebanon) to his formative years studying in Najaf (Iraq), and finally to his decades of scholarly and religious activities in Damascus (Syria). The memoir provides intimate insights into the traditional path of Shi''a religious education, the challenges of modernizing Islamic scholarship, and the interconnected network of scholars across the Muslim world. Al-Amin''s travels were not merely geographical but represented a profound intellectual and spiritual journey that culminated in his monumental work A''yan al-Shi''a, a vast biographical encyclopedia of Shi''a figures. The memoir serves as both a personal narrative and a historical document of Islamic scholarship during a period of significant social and political transformation in the Arab world.'
WHERE id = '6dec3ad9-84c0-4262-afe3-dde263ea6b6a';