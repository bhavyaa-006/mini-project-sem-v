import csv
from collections.abc import Iterable
from pathlib import Path
from typing import Any

from pydantic import BaseModel, Field, field_validator

from safescan_engines.schemas import ProductDomain, SeverityTier


class HazardRowSchema(BaseModel):
    canonical_name: str = Field(min_length=1)
    aliases: list[str] = Field(default_factory=list)
    severity: SeverityTier
    domain: ProductDomain
    reason: str = Field(min_length=3)
    source_url: str | None = None

    @field_validator("canonical_name", "reason", mode="before")
    @classmethod
    def strip_required_text(cls, value: Any) -> Any:
        return value.strip() if isinstance(value, str) else value

    @field_validator("aliases", mode="before")
    @classmethod
    def split_aliases(cls, value: Any) -> list[str]:
        if value is None:
            return []
        if isinstance(value, list):
            parts = value
        else:
            parts = str(value).split("|")
        return list(dict.fromkeys(part.strip() for part in parts if str(part).strip()))

    @field_validator("source_url", mode="before")
    @classmethod
    def validate_source_url(cls, value: Any) -> str | None:
        if value is None:
            return None
        value = str(value).strip()
        if not value:
            return None
        if not value.startswith(("http://", "https://")):
            raise ValueError("source_url must start with http:// or https://")
        return value


def validate_csv_rows(rows: Iterable[dict[str, str]]) -> tuple[list[HazardRowSchema], list[str]]:
    valid: list[HazardRowSchema] = []
    errors: list[str] = []
    for line_number, row in enumerate(rows, start=2):
        try:
            valid.append(HazardRowSchema.model_validate(row))
        except Exception as exc:
            errors.append(f"Line {line_number}: {exc}")
    return valid, errors


def read_validated_csv(path: Path) -> tuple[list[HazardRowSchema], list[str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return validate_csv_rows(csv.DictReader(handle))