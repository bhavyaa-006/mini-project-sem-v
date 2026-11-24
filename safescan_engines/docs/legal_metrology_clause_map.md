# Legal Metrology Clause Map

The implementation evaluates the Legal Metrology (Packaged Commodities) Rules, 2011 as amended. It is an informational audit, not a substitute for statutory legal review.

| Rule | Statutory requirement | Parser/module | PASS | FAIL | UNKNOWN |
|---|---|---|---|---|---|
| 6(1)(a) | Manufacturer/packer/importer name and address with Indian PIN | `manufacturer_address.py` | Entity keyword and valid 6-digit PIN | Entity present but PIN absent/invalid | Entity block unreadable or absent |
| 6(1)(aa) | Country of origin for imports | `manufacturer_address.py` | Origin text found for imported declaration | — | Imported declaration/origin text unreadable |
| 6(1)(b) | Common/generic commodity name | `compliance.py` | `product_name` provided | — | Name absent |
| 6(1)(c) | Net quantity in SI units/count | `net_quantity.py` | g/kg/ml/l/N | Found non-SI unit without metric equivalent | Quantity absent/unreadable |
| 6(1)(d) | Month and year of manufacture/packing/import | `expiry_date.py` | A valid manufacture/packing date found | — | Date absent/unreadable |
| 6(1)(da) | Best-before/use-by/expiry date | `expiry_date.py` | Explicit or relative shelf life found and not expired | Explicit expiry is before the reference month | Date absent/unreadable |
| 6(1)(e) | MRP inclusive of all taxes | `mrp.py` | MRP plus tax-inclusive phrase | MRP present without tax-inclusive phrase | MRP absent/unreadable |
| 6(2) | Consumer-care telephone/email | `manufacturer_address.py` | Phone or email found | — | No verified contact |
| 6(3) | No tampering/conflicting dual MRP | `dual_mrp.py` | One/no MRP with user-review rule | Two unique conflicting MRP values | No MRP found |
| 6(8) | Veg/non-veg visual mark for cosmetics | `compliance.py` | Detected text/visual mark | Explicitly contradictory declaration | OCR cannot read visual icon |
| 18 | Price alteration/sticker context | `dual_mrp.py` | Revised/offer wording documented | Conflicting MRP without lawful presentation | No MRP extracted |

OCR extraction uncertainty always maps to UNKNOWN rather than FAIL. A FAIL is reserved for an explicitly present declaration that violates a rule.

`6(1)(d)` identifies when a product was manufactured or packed. `6(1)(da)` identifies how long or until when it remains suitable for use. They are distinct declarations.
