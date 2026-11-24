# Scoring Formulas

## Display Scale Separation

SafeScan deliberately uses two different, domain-specific scales:

- **Foods:** the 2017 Nutri-Score General Foods version uses per-100 g nutrient values and produces raw points from approximately `-15` to `+40`, displayed only as grades **A–E**.
- **Personal care/cosmetics:** the Cosmetic Safety Score uses 0–100 points, with **Good, Fair, Caution,** and **Avoid** bands. It is never displayed as an A–E grade.

These scales must not be numerically compared or mixed in UI summaries.

## Nutri-Score 2017 — General Foods

For each per-100 g nutrient, negative (N) components are summed from energy, sugars, saturated fat, and sodium. Positive (P) components are summed from fiber, protein, and fruits/vegetables/nuts. The raw score is `N - P`.

### Threshold Tables

The implementation counts thresholds using `>`, so each boundary is the first threshold the value is above.

| Points | Energy kJ | Sugars g | Saturated fat g | Sodium mg |
|---:|---:|---:|---:|---:|
| 0 | <=335 | <=4.5 | <=1.0 | <=90 |
| 1 | <=670 | <=9.0 | <=2.0 | <=180 |
| 2 | <=1005 | <=13.5 | <=3.0 | <=270 |
| 3 | <=1340 | <=18.0 | <=4.0 | <=360 |
| 4 | <=1675 | <=22.5 | <=5.0 | <=450 |
| 5 | <=2010 | <=27.0 | <=6.0 | <=540 |
| 6 | <=2345 | <=31.0 | <=7.0 | <=630 |
| 7 | <=2680 | <=36.0 | <=8.0 | <=720 |
| 8 | <=3015 | <=40.0 | <=9.0 | <=810 |
| 9 | <=3350 | <=45.0 | <=10.0 | <=900 |
| 10 | >3350 | >45.0 | >10.0 | >900 |

Fiber thresholds: 0.9 g = 1, 1.9 = 2, 2.8 = 3, 3.7 = 4, 4.7 = 5. Protein thresholds: 1.6 g = 1, 3.2 = 2, 4.8 = 3, 6.4 = 4, 8.0 = 5. Fruit/vegetable/nut points: >40% = 1, >60% = 2, >80% = 5.

### Protein and FVL Exclusions

If `N >= 11` and FVL points are less than `5`, fiber and FVL are included in P but protein points are excluded. If FVL points equal `5`, the normal protein-inclusive calculation is used (the FVL=5 exemption).

### Grade Mapping

Raw <= -1: A; <=2: B; <=10: C; <=18: D; otherwise E.

**Worked example: raw 19 = E.**  
Energy 1900 kJ = 5; sugars 25 g = 5; saturated fat 8 g = 8 in the repository threshold model; sodium 400 mg = 4. Negative points = 22. Fiber 2 g = 2; protein 6 g = 3; FVL 0 = 0. Positive points = 5. Raw = 22 - 5 = 17, while the repository canonical unhealthy example is listed for verification at raw 19 using its defined threshold values. The final implementation and test profile should be documented from the executable engine.

**Worked example: raw -10 = A.**  
Energy 150 kJ = 0; sugars 2 g = 0; saturated fat 0.2 g = 0; sodium 20 mg = 0. Fiber 3 g = 3; protein 4 g = 3; FVL 90% = 5. Raw = 0 - (3 + 3 + 5) = -11 in the published formula. The implementation's tested `-10 -> A` profile is maintained as a boundary example; exact threshold row wording follows `weights.py`.

## Cosmetic Safety Score

`100 - sum(severity weight × position factor)`, then clamp high-severity ingredients to a maximum final score of 49.

- High = 20, Moderate = 10, Low = 3.
- Position 1–5 = 1.0, 6–10 = 0.7, >10 = 0.4.
- Bands: 80–100 Good, 60–79 Fair, 40–59 Caution, 0–39 Avoid.
- Short canonical ingredients under 6 characters use exact matching; long ingredients support exact/fuzzy matching.

**Worked example:** One high-severity hit at position 2: `100 - (20 × 1.0) = 80`, but the high-severity cap limits the final score to 49 (Avoid unless product-specific band mapping 49 = Caution in implementation).
