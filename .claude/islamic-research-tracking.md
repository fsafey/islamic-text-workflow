# Islamic Research Automatic Tracking Protocol

This file contains specialized tracking protocols for Islamic text analysis instances.

## 🕌 Islamic Text Analysis Automation

### Manuscript Processing Tracking
- **WHEN processing Arabic texts**: Auto-execute text analysis and entity extraction
- **WHEN discovering manuscripts**: Auto-store manuscript metadata and provenance
- **WHEN analyzing hadith chains**: Auto-record sanad (transmission chain) analysis
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "MANUSCRIPT ANALYSIS: [text/manuscript] - [entities found] - [scholarly significance]"`

### Scholar and Entity Discovery
- **WHEN identifying scholars**: Auto-store scholar information with time periods and schools
- **WHEN finding places**: Auto-record geographical locations with historical context
- **WHEN discovering concepts**: Auto-store Islamic jurisprudence, theology, and philosophical terms
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "ISLAMIC ENTITY: [type] - [name/concept] - [historical context] - [relationships]"`

### Hadith Authentication Tracking
- **WHEN analyzing hadith authenticity**: Auto-record authentication methodology
- **WHEN evaluating narrator reliability**: Auto-store narrator assessment criteria
- **WHEN cross-referencing chains**: Auto-record sanad comparison results
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "HADITH AUTHENTICATION: [hadith reference] - [authentication method] - [reliability assessment]"`

### Quranic Analysis Tracking
- **WHEN analyzing Quranic verses**: Auto-store verse relationships and thematic connections
- **WHEN finding commentary**: Auto-record exegetical insights and scholarly interpretations
- **WHEN cross-referencing**: Auto-store verse-to-verse connections and parallel themes
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "QURANIC ANALYSIS: [verse reference] - [thematic connection] - [scholarly interpretation]"`

### Arabic NLP and Linguistic Analysis
- **WHEN processing RTL text**: Auto-log text processing challenges and solutions
- **WHEN analyzing morphology**: Auto-store Arabic linguistic patterns and structures
- **WHEN handling encoding**: Auto-record Arabic text encoding solutions
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "ARABIC NLP: [linguistic challenge] - [processing method] - [outcome]"`

### Historical and Temporal Tracking
- **WHEN establishing dates**: Auto-record historical dating methodology and evidence
- **WHEN mapping relationships**: Auto-store temporal connections between scholars and texts
- **WHEN analyzing historical context**: Auto-record period-specific insights
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "HISTORICAL ANALYSIS: [time period] - [event/relationship] - [historical significance]"`

### Research Methodology Tracking
- **WHEN choosing analysis approaches**: Auto-record Islamic scholarship methodology decisions
- **WHEN validating sources**: Auto-store source verification and reliability assessment
- **WHEN comparing traditions**: Auto-record comparative analysis results
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "ISLAMIC METHODOLOGY: [research approach] - [validation method] - [scholarly justification]"`

### Session Conclusion for Islamic Research
- **END OF RESEARCH SESSION**: Auto-summarize Islamic text analysis accomplishments
- **FORMAT**: `source tools/scripts/graphiti-commands.sh && graph_remember "ISLAMIC RESEARCH SESSION END: [manuscripts analyzed] - [scholars identified] - [concepts discovered] - [authentication results] - [scholarly insights]"`

## Usage Notes

This tracking protocol should be loaded automatically when in Islamic text analysis mode. The specialized tracking captures the unique aspects of Islamic scholarship, Arabic text processing, and historical research methodology.