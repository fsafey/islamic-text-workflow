
# Book Enrichment Criteria for Enhanced Search

**Objective:** To provide a researcher agent with clear instructions and reasoning for enriching the `title_alias` and `keywords` columns of the `books` table. The goal is to significantly improve search result relevance and discoverability by anticipating a wide range of user search queries.

**Process:** The agent will process books in batches of 20, applying the following principles to generate high-quality, extensive metadata for each book.

---

## 1. Reasoning for Enrichment

To extensively improve search results, we must anticipate the various ways a user might look for a book. This includes different transliteration spellings, partial titles, conceptual searches, and related topics.

### 1.1. Reasoning for `title_alias` Column

The `title_alias` column should capture every conceivable way a user might write or remember the book's title.

- **Transliteration Variations:** Arabic has no single, universally accepted English transliteration scheme. A user might search using a simpler scheme than the one in our database (e.g., `_a` for `ع`, `_` for emphasis). We must include common variations.
- **Definite Article Handling:** The definite article "ال" can be written as `Al-`, `el-`, `Al `, or simply be omitted. All variations should be considered.
- **Special Character Simplification:** Characters like `_` in `al-Tara_ef` or `_a` in `_Aqaid` are not intuitive. Provide versions without them (`al-Taraef`) or with common phonetic replacements (`ayn` for `_a`, `gh` for `_`).
- **Vowel and Consonant Ambiguity:** Sounds like Qaf (ق) can be `q` or `k`. Tha' (ث) can be `th` or `s`. Dhad (ض) can be `d` or `dh`. Include these common phonetic variations.
- **Word Combination:** A user might type `AlHusayn`, `Al-Husayn`, or `Al Husayn`. All should be included.
- **Partial and Simplified Titles:** Users often remember only the most distinctive part of a title. Include shorter, more memorable versions.
- **Conceptual/Descriptive Titles:** The alias can include what the book is *about* in a title-like format, such as "The Verse of Cursing" for `Ayat al-Mubahala`.

### 1.2. Reasoning for `keywords` Column

The `keywords` column should connect the book to a web of related concepts, people, places, and ideas, enabling discovery through topical searches.

- **Core Concepts:** Extract the main nouns and ideas directly from the title (e.g., for `Al-Husayn Warith Adam Al-Shahid`, keywords are `Husayn`, `Adam`, `Warith` (Inheritor), `Shahid` (Martyr)).
- **Associated Figures, Places, and Events:** Add contextually relevant terms. For a book on Imam Al-Husayn, keywords like `Karbala`, `Ashura`, and `Ahl al-Bayt` are essential. For `Ayat al-Mubahala`, the `Christians of Najran` is a critical keyword.
- **Broader Subject Areas:** Include the academic or theological field the book belongs to, such as `Theology`, `Hadith`, `History`, `Shi'a Islam`, `Jurisprudence (Fiqh)`, `Polemics`, and `Kalam`.
- **Synonyms and Related Terms:** Add English synonyms (e.g., "Martyrdom" for `Shahid`, "Sects" for `Tawaif`) and the original Arabic terms transliterated simply. This captures users who know the concept but not the exact title.

---

## 2. Example Application

Here is an example of the expected output for the first 10 books, demonstrating the depth and breadth of the required enrichment.

| Original Title | Extensive `title_alias` | Extensive `keywords` |
| :--- | :--- | :--- |
| **Al-Husayn Warith Adam Al-Shahid** | Al-Husayn Inheritor of Adam the Martyr; Al-Hussein Warith Adam Al-Shahid; Al Husayn Waris Adam; The Martyr Husayn Inheritor of Adam; Husayn Warith Adam | Imam Husayn; Hussein ibn Ali; Karbala; Ashura; Martyrdom; Shahid; Inheritance; Warith; Adam; Prophets; Ahl al-Bayt; Shia Islam; History |
| **Al-Aman** | The Security; The Safety; El Aman; Al Aman | Security; Safety; Protection; Trust; Aman; Eschatology; Mahdi; End Times; Islamic Beliefs |
| **al-Mutahawilun** | The Transformers; The Converts; The Changed Ones; Al Mutahawilun; al-Mutahawwilun; El-Mutahawilun | Conversion; Transformation; Changing beliefs; Sunni to Shia; Shia to Sunni; Religious conversion; Sects; Madhhab; Aqidah; Polemics |
| **Ibtalat Al-Ummam** | Invalidations of the Nations; Refutations of the Peoples; Ibtalat al-Umam; Ibtalat al Umam | Refutation; Invalidation; Ibtal; Nations; Peoples; Ummam; Polemics; Kalam; Theology; Heresiography; Sects; Comparative Religion |
| **Ayat al-Mubahala** | The Verse of Mubahala; Ayat al Mubahalah; The Verse of Cursing; The Verse of Invocation; Ayat Mubahala; Event of Mubahala | Mubahala; Invocation; Cursing; Debate; Proof; Prophet Muhammad; Christians of Najran; Ali ibn Abi Talib; Fatima al-Zahra; Hasan; Husayn; Ahl al-Bayt; Quranic verses; Tafsir |
| **al-Tara_ef fi Madhahib al-Tawa_if** | al-Taraef fi Madhahib al-Tawaif; Al-Tara'if; Anecdotes on the Doctrines of Sects; The Anecdotes; Taraif fi Madhahib Tawaif | Anecdotes; Taraif; Doctrines; Madhahib; Sects; Tawaif; Shia; Sunni; Hadith; History; Sayyid Ibn Tawus; Religious differences; Polemics |
| **Al-Din Wal-Islam Aw Al-Da_wah Al-Islamiyyah** | Religion and Islam or The Islamic Call; Al Din Wal Islam; Al Dawah Al Islamiyyah; The Islamic Call; Religion and Islam | Religion; Din; Islam; Dawah; Islamic Call; Invitation to Islam; Islamic Culture; Theology; Aqidah; Islamic civilization |
| **al-Raj_a aw al-_awdah lil-Hayat al-Dunya** | The Return or the Return to Worldly Life; al-Raja; al-Awdah; The Return to Life; Raja; Raj'a; Rajah; The Return (Shia belief) | Raj'a; Return; Eschatology; Shia theology; Aqidah; Occultation; Mahdi; End of times; Return to life before resurrection; Awdah |
| **Al-Ghadir fi al-Kitab wa al-Sunnah wa al-Adab** | Al-Ghadir in the Book, Sunnah, and Literature; Ghadir Khumm; Ghadir in the Quran and Hadith; Al Ghadir; El-Ghadir | Ghadir Khumm; Event of Ghadir; Hadith of Ghadir; Imam Ali; Wilayah; Guardianship; Succession to the Prophet; Al-Amini; Shia-Sunni relations; Hadith studies; History |
| **Al-Hayat** | The Life; Al Hayat; El Hayat | Life; Islamic perspective on life; Philosophy of life; Purpose of life; Ethics; Morality; Islamic philosophy |

---

## 3. Required Tools

To accomplish this task, the agent should primarily use:

- **`google_web_search`**: To research the book titles, authors, and concepts to find common transliterations, related topics, and the historical or theological context.
- **`read_file`**: To access this document (`ENRICHMENT_CRITERIA.md`) for instructions.
