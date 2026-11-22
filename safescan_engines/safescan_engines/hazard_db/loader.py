import csv
from collections import OrderedDict
from collections.abc import Sequence
from pathlib import Path

from sqlalchemy import select
from sqlalchemy.orm import Session

from safescan_engines.health.ingredient_matcher import HazardEntry, normalize_token
from safescan_engines.health import ingredient_matcher
from safescan_engines.hazard_db.schema import HazardIngredient, IngredientAlias
from safescan_engines.hazard_db.validators import HazardRowSchema, read_validated_csv
from safescan_engines.schemas import ProductDomain


CSV_HEADER = [
    "canonical_name",
    "aliases",
    "severity",
    "domain",
    "reason",
    "source_url",
]


def merge_hazard_csvs(source_paths: Sequence[Path], output_path: Path) -> int:
    merged: OrderedDict[str, dict[str, object]] = OrderedDict()
    for source_path in source_paths:
        with source_path.open("r", encoding="utf-8-sig", newline="") as handle:
            reader = csv.DictReader(handle)
            for row in reader:
                canonical = str(row.get("canonical_name") or "").strip()
                if not canonical:
                    continue
                norm = normalize_token(canonical)
                if not norm:
                    continue
                alias_text = str(row.get("aliases") or "")
                aliases = [
                    alias.strip()
                    for alias in alias_text.split("|")
                    if alias.strip()
                ]
                if norm not in merged:
                    merged[norm] = {
                        "canonical_name": canonical,
                        "aliases": OrderedDict(),
                        "severity": str(row.get("severity") or "").strip(),
                        "domain": str(row.get("domain") or "").strip(),
                        "reason": str(row.get("reason") or "").strip(),
                        "source_url": str(row.get("source_url") or "").strip(),
                    }
                entry = merged[norm]
                alias_map = entry["aliases"]
                assert isinstance(alias_map, OrderedDict)
                for alias in aliases:
                    alias_norm = normalize_token(alias)
                    if alias_norm:
                        alias_map.setdefault(alias_norm, alias)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_HEADER)
        writer.writeheader()
        for entry in merged.values():
            alias_map = entry["aliases"]
            assert isinstance(alias_map, OrderedDict)
            writer.writerow({
                "canonical_name": entry["canonical_name"],
                "aliases": "|".join(alias_map.values()),
                "severity": entry["severity"],
                "domain": entry["domain"],
                "reason": entry["reason"],
                "source_url": entry["source_url"],
            })
    return len(merged)


def upsert_hazards(session: Session, rows: Sequence[HazardRowSchema]) -> dict[str, int]:
    inserted = 0
    updated = 0
    for row in rows:
        canonical_norm = normalize_token(row.canonical_name)
        ingredient = session.scalar(
            select(HazardIngredient).where(HazardIngredient.canonical_norm == canonical_norm)
        )
        if ingredient is None:
            ingredient = HazardIngredient(
                canonical_name=row.canonical_name,
                canonical_norm=canonical_norm,
                severity=row.severity.value,
                domain=row.domain.value,
                reason=row.reason,
                source_url=row.source_url,
            )
            session.add(ingredient)
            inserted += 1
        else:
            ingredient.canonical_name = row.canonical_name
            ingredient.severity = row.severity.value
            ingredient.domain = row.domain.value
            ingredient.reason = row.reason
            ingredient.source_url = row.source_url
            updated += 1

        ingredient.aliases.clear()
        session.flush()
        aliases: dict[str, str] = {}
        for alias in row.aliases:
            alias_norm = normalize_token(alias)
            if alias_norm and alias_norm not in aliases:
                aliases[alias_norm] = alias
                ingredient.aliases.append(
                    IngredientAlias(alias_name=alias, alias_norm=alias_norm)
                )
    session.flush()
    return {"inserted": inserted, "updated": updated}


def load_catalog_from_db(
    session: Session,
    domain: ProductDomain | None = None,
) -> list[HazardEntry]:
    statement = select(HazardIngredient).order_by(HazardIngredient.canonical_name)
    if domain is not None:
        statement = statement.where(HazardIngredient.domain == domain.value)
    ingredients = session.scalars(statement).all()
    catalog: list[HazardEntry] = []
    for ingredient in ingredients:
        from safescan_engines.schemas import SeverityTier

        catalog.append(
            HazardEntry(
                canonical_name=ingredient.canonical_name,
                aliases=[alias.alias_name for alias in ingredient.aliases],
                severity=SeverityTier(ingredient.severity),
                domain=ProductDomain(ingredient.domain),
                reason=ingredient.reason,
                source_url=ingredient.source_url,
            )
        )
    return catalog