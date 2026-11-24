# Scoring Formulas

## Display Scale Separation

SafeScan uses domain-specific health scales:

- **Foods:** 2017 Nutri-Score General Foods, calculated per 100 g, uses kcal energy values and raw points, displayed as **A–E**.
- **Personal care/cosmetics:** the Cosmetic Safety Score uses **0–100**, displayed as Good, Fair, Caution, or Avoid.

The scales must not be numerically mixed in the UI.

## Nutri-Score 2017 — General Foods

Negative (N) points come from energy, sugars, saturated fat, and sodium. Positive (P) points come from fiber, protein, and fruits/vegetables/nuts. Raw score = `N - P`.

Energy thresholds are the standard kcal conversion of the 2017 thresholds:

| Points | Energy kcal | Sugars g | Saturated fat g | Sodium mg |
|---:|---:|---:|---:|---:|
| 0 | <=80 | <=4.5 | <=1.0 | <=90 |
| 1 | <=160 | <=9.0 | <=2.0 | <=180 |
| 2 | <=240 | <=13.5 | <=3.0 | <=270 |
| 3 | <=320 | <=18.0 | <=4.0 | <=360 |
| 4 | <=400 | <=22.5 | <=5.0 | <=450 |
| 5 | <=480 | <=27.0 | <=6.0 | <=540 |
| 6 | <=560 | <=31.0 | <=7.0 | <=630 |
| 7 | <=640 | <=36.0 | <=8.0 | <=720 |
| 8 | <=720 | <=40.0 | <=9.0 | <=810 |
| 9 | <=800 | <=45.0 | <=10.0 | <=900 |
| 10 | >800 | >45.0 | >10.0 | >900 |

Fiber thresholds: 0.9 g = 1, 1.9 = 2, 2.8 = 3, 3.7 = 4, 4.7 = 5. Protein thresholds: 1.6 g = 1, 3.2 = 2, 4.8 = 3, 6.4 = 4, 8.0 = 5. Fruit/vegetable/nut points: >40% = 1, >60% = 2, >80% = 5.

If `N >= 11` and FVL points are less than `5`, protein points are excluded from P. Grade mapping: raw <= -1 A, <=2 B, <=10 C, <=18 D, otherwise E.

**Worked example: raw 19 = E.** With 454 kcal, 25 g sugars, 8 g saturated fat, and 400 mg sodium, energy/sugars/saturated-fat/sodium produce 5/5/7/4 = 21 negative points. Fiber 2 g = 2 positive points; FVL 0 = 0, and protein is excluded because `N >= 11` with FVL below 5. Raw = `21 - 2 = 19`.

**Worked example: raw -10 = A.** With 36 kcal, 2 g sugars, 0.2 g saturated fat, and 20 mg sodium, N = 0. Fiber 3 g, protein 4 g, and FVL 90% contribute 3 + 3 + 5 = 11 positive points, raw = -11. The engine and its 2017 boundary mapping both display grade A.

## Cosmetic Safety Score

`100 - sum(severity weight × position factor)`, with high-severity hits capped to a maximum final score of 49.

- High = 20, Moderate = 10, Low = 3.
- Positions 1–5 = 1.0, 6–10 = 0.7, >10 = 0.4.
- Bands: 80–100 Good, 60–79 Fair, 40–59 Caution, 0–39 Avoid.

**Worked example:** A high-severity hit at position 2 calculates `100 - 20 = 80`, then the <=49 cap applies, producing 49/Caution in the implemented band mapping.
