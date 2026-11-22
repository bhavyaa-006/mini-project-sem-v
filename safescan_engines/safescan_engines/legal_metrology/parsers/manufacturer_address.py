import re

from pydantic import BaseModel


class ManufacturerParseResult(BaseModel):
    has_entity_declaration: bool
    entity_snippet: str | None
    pin_code: str | None
    has_valid_pin: bool
    country_of_origin: str | None
    consumer_care_phone: str | None
    consumer_care_email: str | None


def parse_manufacturer_and_contact(text: str | None) -> ManufacturerParseResult:
    if not text or not text.strip():
        return ManufacturerParseResult(
            has_entity_declaration=False, entity_snippet=None, pin_code=None,
            has_valid_pin=False, country_of_origin=None,
            consumer_care_phone=None, consumer_care_email=None,
        )

    normalized = re.sub(r"[ \t]+", " ", text)
    entity = re.search(
        r"(?:Mfd\.?\s*by|Manufactured\s+by|Marketed\s+by|Packed\s+by|Imported\s+by)"
        r"[^\n]*",
        normalized,
        re.I,
    )
    pin_match = re.search(r"\b[1-9][0-9]{5}\b", normalized)
    country_match = re.search(
        r"Country\s+of\s+Origin\s*[:\-]?\s*([A-Za-z][A-Za-z ]*)",
        normalized,
        re.I,
    )
    country = None
    if country_match:
        country = re.sub(r"\s+", " ", country_match.group(1)).strip(" ,")
    phone_match = re.search(
        r"(?:1800[\s\-]?\d{3}[\s\-]?\d{4}|\+91[\s\-]?\d{10}|"
        r"\b0\d{2,4}[\s\-]?\d{6,8}\b)",
        normalized,
        re.I,
    )
    email_match = re.search(
        r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
        normalized,
        re.I,
    )
    return ManufacturerParseResult(
        has_entity_declaration=entity is not None,
        entity_snippet=entity.group(0).strip() if entity else None,
        pin_code=pin_match.group(0) if pin_match else None,
        has_valid_pin=pin_match is not None,
        country_of_origin=country,
        consumer_care_phone=phone_match.group(0).strip() if phone_match else None,
        consumer_care_email=email_match.group(0).strip() if email_match else None,
    )