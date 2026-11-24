import json
from collections.abc import Sequence

import httpx

from safescan_engines.alternatives.recommender import AlternativeRecommendation
from safescan_engines.config import settings
from safescan_engines.schemas import ComplianceResult, HealthResult, NormalizedProduct
from safescan_engines.summary.rule_based_summary import generate_rule_based_highlights


async def generate_summary_highlights(
    product: NormalizedProduct,
    health: HealthResult,
    compliance: ComplianceResult,
    alternatives: Sequence[AlternativeRecommendation] = (),
    client: httpx.AsyncClient | None = None,
) -> list[str]:
    baseline = generate_rule_based_highlights(product, health, compliance, alternatives)
    if not settings.llm_api_key or not settings.llm_api_key.strip():
        return baseline

    payload = {
        "model": settings.llm_model,
        "messages": [
            {
                "role": "system",
                "content": (
                    "Rephrase these verified audit highlights into concise, consumer-friendly "
                    "bullet points. Do NOT alter numbers, grades, scores, ingredient names, "
                    "or legal statuses."
                ),
            },
            {"role": "user", "content": json.dumps(baseline)},
        ],
        "response_format": {"type": "json_object"},
    }
    try:
        if client is not None:
            response = await client.post(
                f"{settings.llm_base_url.rstrip('/')}/chat/completions",
                headers={"Authorization": f"Bearer {settings.llm_api_key}"},
                json=payload,
                timeout=settings.http_timeout_seconds,
            )
        else:
            async with httpx.AsyncClient() as active_client:
                response = await active_client.post(
                    f"{settings.llm_base_url.rstrip('/')}/chat/completions",
                    headers={"Authorization": f"Bearer {settings.llm_api_key}"},
                    json=payload,
                    timeout=settings.http_timeout_seconds,
                )
        response.raise_for_status()
        body = response.json()
        content = body["choices"][0]["message"]["content"]
        parsed = json.loads(content)
        if isinstance(parsed, dict):
            parsed = parsed.get("bullets") or parsed.get("highlights")
        if not isinstance(parsed, list) or not parsed:
            return baseline
        if not all(isinstance(item, str) and item.strip() for item in parsed):
            return baseline
        return parsed
    except Exception:
        return baseline