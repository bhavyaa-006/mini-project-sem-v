from dataclasses import dataclass


@dataclass(frozen=True)
class LegalMetrologyRule:
    clause_id: str
    title: str
    mandatory: bool
    description: str


LM_RULES: dict[str, LegalMetrologyRule] = {
    "6(1)(a)": LegalMetrologyRule(
        "6(1)(a)", "Manufacturer / Packer / Importer Name & Address",
        True, "Requires entity declaration and a valid 6-digit Indian PIN code.",
    ),
    "6(1)(aa)": LegalMetrologyRule(
        "6(1)(aa)", "Country of Origin",
        False, "Mandatory for imported products; otherwise not applicable.",
    ),
    "6(1)(b)": LegalMetrologyRule(
        "6(1)(b)", "Common / Generic Name of Commodity",
        True, "Requires a common or generic commodity name.",
    ),
    "6(1)(c)": LegalMetrologyRule(
        "6(1)(c)", "Net Quantity",
        True, "Requires numeric quantity in g, kg, ml, l, or standard count units.",
    ),
    "6(1)(d)": LegalMetrologyRule(
        "6(1)(d)", "Month & Year of Manufacture / Packing",
        True, "Requires manufacturing, packing, or import month/year.",
    ),
    "6(1)(da)": LegalMetrologyRule(
        "6(1)(da)", "Best Before / Use By / Expiry",
        True, "Requires an explicit or relative shelf-life date.",
    ),
    "6(1)(e)": LegalMetrologyRule(
        "6(1)(e)", "Maximum Retail Price",
        True, "Requires MRP and an inclusive-of-all-taxes declaration.",
    ),
    "6(2)": LegalMetrologyRule(
        "6(2)", "Consumer Care Contact Details",
        True, "Requires a telephone/toll-free number or email address.",
    ),
    "6(3)": LegalMetrologyRule(
        "6(3)", "No Tampering / Dual-MRP Sticker",
        True, "Disallows conflicting MRP declarations on the same package.",
    ),
    "6(8)": LegalMetrologyRule(
        "6(8)", "Veg / Non-Veg Mark",
        False, "Cosmetics must be checked for a vegetarian/non-vegetarian mark when detected.",
    ),
}