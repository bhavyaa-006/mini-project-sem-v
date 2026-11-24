# Data Sources and Licences

| Source | Use | Licence/attribution | Integration policy |
|---|---|---|---|
| Open Food Facts | Food products, nutrient data, categories | ODbL 1.0; credit and share-alike where applicable | API, custom User-Agent, polite caching in PostgreSQL/SQLite |
| Open Beauty Facts | Cosmetic products and ingredient text | ODbL 1.0 | API, custom User-Agent, cached normalized records |
| CureSkin Indian skincare ingredient flags | Initial Indian cosmetic hazard references | CC BY 4.0 attribution | Curated summaries only; record source URL |
| FSSAI Food Safety and Standards (Food Products Standards and Food Additives) Regulations | INS codes and regulatory reference | Official Government of India/FSSAI information | Attribution and current-regulation review |
| EWG Skin Deep | Curated hazard metadata | No bulk scraping | Concise original summaries plus explicit source URL |
| INCI Decoder | Ingredient naming and use context | Curated metadata only | Source URL attribution; no bulk extraction |

## API and Rate-Limiting Policy

OFF and OBF requests use `OFF_USER_AGENT`, request one barcode at a time, and support configurable delay. Optional robots-compliant web fallback checks `robots.txt`, caches domain rules in memory, and raises `PermissionError` when blocked.

## System Limitations and Disclaimer

This is a rule-based academic screening tool, not medical or legal advice. OFF/OBF records may be crowd-sourced or incomplete. OCR accuracy decreases with glare, curvature, small print, blurred text, and unusual fonts. Extracted compliance results should be reviewed against the package and current statutory requirements.
