-- SQL Enrichment for "Qisas Abrar"
-- Book ID: a752f60f-0f84-4746-8785-57bc777d08bd
-- Author: al-Sayyid Murtada al-Milani

UPDATE books 
SET 
    title_alias = 'Stories of the Righteous',
    keywords = ARRAY[
        'stories', 'narratives', 'biography', 'righteous', 'pious', 'saints',
        'abrar', 'spiritual biography', 'Islamic hagiography', 'pious predecessors',
        'awliya', 'religious figures', 'moral instruction', 'spiritual guidance',
        'Islamic literature', 'edifying stories', 'character development',
        'Islamic ethics', 'righteousness', 'piety', 'spiritual exemplars',
        'Islamic spirituality', 'moral stories', 'spiritual narratives',
        'Islamic biographical literature', 'saintly figures', 'devotional literature',
        'Islamic moral instruction', 'exemplary lives', 'virtue stories',
        'Islamic wisdom literature', 'spiritual teachings', 'moral exemplars'
    ],
    description = 'A collection of biographical narratives documenting the lives and spiritual achievements of righteous individuals (Abrar) in Islamic tradition. This work by al-Sayyid Murtada al-Milani presents inspiring stories of pious figures who exemplified Islamic virtues and spiritual excellence throughout history. The term "Abrar" refers to those who have attained a high level of righteousness and piety, often regarded as spiritual exemplars for the Muslim community. These narratives serve both as moral instruction and spiritual guidance, illustrating the various paths to righteousness in Islamic tradition. The stories encompass a range of figures from early Islamic history to later saints and scholars, demonstrating how individuals from different backgrounds and circumstances achieved spiritual distinction through their devotion, knowledge, and exemplary character. This genre of Islamic literature combines historical documentation with spiritual teaching, providing readers with both knowledge of significant religious figures and practical guidance for spiritual development.'
WHERE id = 'a752f60f-0f84-4746-8785-57bc777d08bd';