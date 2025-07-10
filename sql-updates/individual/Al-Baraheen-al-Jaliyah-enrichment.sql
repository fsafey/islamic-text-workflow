-- Enrichment SQL for: al-Baraheen al-Jaliyah
-- Book ID: f6682612-0fd0-4a84-a3ae-fba13bc47067
-- Author: al-Sayyid Muhammad Hasan al-Mousawi
-- Agent: agent-database-integration-005 (Database Integration Manager)
-- Processing Date: 2025-07-04

UPDATE books SET 
  title_alias = 'The Clear Proofs; Al-Baraheen al-Jaliyah; The Evident Proofs; Clear Demonstrations; Rational Proofs; Theological Proofs; The Manifest Proofs; Islamic Rational Arguments; Demonstrative Proofs; Clear Evidence; Theological Demonstrations; Rational Theology',
  keywords = ARRAY[
    'Theological proofs', 'Rational arguments', 'Burhan', 'Islamic epistemology', 'Kalam theology',
    'Muhammad Hasan al-Mousawi', 'Sayyid scholarship', 'Shi''a rational theology', 'Demonstrative proof',
    'Divine existence proofs', 'Rational argumentation', 'Textual evidence', 'Burhan aqli', 'Burhan naqli',
    'Tawhid proofs', 'Divine attributes', 'Divine unity', 'Divine justice', 'Adl',
    'Prophethood proofs', 'Prophetic mission', 'Revelation authenticity', 'Quranic miracle', 'Ijaz al-Quran',
    'Imamate proofs', 'Succession arguments', 'Ali ibn Abi Talib', 'Twelve Imams', 'Ahl al-Bayt',
    'Isma infallibility', 'Divine guidance', 'Hujja divine proof', 'Lutf divine grace', 'Rational necessity',
    'Eschatological proofs', 'Resurrection arguments', 'Raj''a return', 'Ghayba occultation', 'Mahdi',
    'Divine recompense', 'Final judgment', 'Shafa''a intercession', 'Afterlife proofs', 'Bodily resurrection',
    'Philosophical refutation', 'Theological debate', 'Ash''ari critique', 'Mu''tazila response', 'Sunni objections',
    'Materialist refutation', 'Determinist critique', 'Rationalist response', 'Contemporary challenges', 'Scientific integration',
    'Logical demonstration', 'Epistemological principles', 'Religious knowledge', 'Proof methodology', 'Dialectical method',
    'Jadal argumentation', 'Theological systematization', 'Rational theology', 'Scholastic tradition', 'Islamic philosophy',
    'Contingency argument', 'Causation proof', 'Design argument', 'Motion argument', 'First mover',
    'Cosmic order', 'Intelligent design', 'Divine omniscience', 'Divine omnipotence', 'Divine wisdom',
    'Prophetic criteria', 'Miracle authentication', 'Historical fulfillment', 'Moral transformation', 'Spiritual guidance',
    'Quranic preservation', 'Hadith authenticity', 'Revelation protection', 'Genealogical succession', 'Imam authority',
    'Soul survival', 'Death philosophy', 'Recompense justice', 'Eternal consequences', 'Free will',
    'Human responsibility', 'Divine sovereignty', 'Proof integration', 'Reason revelation harmony', 'Comprehensive theology'
  ],
  description = 'A systematic theological treatise by al-Sayyid Muhammad Hasan al-Mousawi presenting rational and textual proofs for fundamental Islamic beliefs, particularly those distinctive to Shi''a Islam. This work integrates rational argumentation with textual evidence from the Quran and authenticated traditions, following the Shi''a Imami scholastic tradition that emphasizes harmony between reason and revelation. The treatise systematically addresses proofs for divine existence and attributes, prophethood and revelation, the Imamate doctrine, and eschatological beliefs, while refuting opposing philosophical and theological positions. As a contribution to Islamic rational theology, this work demonstrates how demonstrative proofs can establish religious truths through logical demonstration, making it a valuable resource for understanding the rational foundations of Islamic belief and the methodological approaches of Shi''a theological scholarship.'
WHERE id = 'f6682612-0fd0-4a84-a3ae-fba13bc47067';