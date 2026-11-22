"""
LLM-powered summary using Google Gemini API (optional).
Falls back to rule-based summary if GEMINI_API_KEY is not set.
"""
import httpx
from app.core.config import settings
from app.engines.summary.rule_based_summary import build_summary


async def generate_llm_summary(product_name: str, score: float, flagged: list, lm_result) -> str:
    if not settings.GEMINI_API_KEY:
        return build_summary(product_name, score, flagged, lm_result)

    prompt = (
        f"You are a food/cosmetic safety expert. Summarize in 2 sentences:\n"
        f"Product: {product_name}\nHealth Score: {round(score)}/100\n"
        f"Flagged Ingredients: {[f.name for f in flagged]}\n"
        f"Legal Metrology Compliant: {lm_result.compliant}"
    )
    url = (
        f"https://generativelanguage.googleapis.com/v1beta/models/"
        f"gemini-1.5-flash:generateContent?key={settings.GEMINI_API_KEY}"
    )
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.post(url, json={
                "contents": [{"parts": [{"text": prompt}]}]
            })
            data = resp.json()
            return data["candidates"][0]["content"]["parts"][0]["text"]
    except Exception:
        return build_summary(product_name, score, flagged, lm_result)
