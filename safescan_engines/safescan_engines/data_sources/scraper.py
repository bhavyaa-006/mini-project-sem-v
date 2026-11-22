import asyncio
import time

import httpx

from safescan_engines.config import settings
from safescan_engines.data_sources.robots_check import can_fetch_url


_last_request: dict[str, float] = {}


async def polite_get(
    url: str,
    min_delay_seconds: float = 1.5,
    client: httpx.AsyncClient | None = None,
) -> httpx.Response:
    if not can_fetch_url(url):
        raise PermissionError(f"robots.txt blocks this URL: {url}")

    from urllib.parse import urlparse

    origin = urlparse(url).netloc
    now = time.monotonic()
    previous = _last_request.get(origin)
    if previous is not None:
        delay = min_delay_seconds - (now - previous)
        if delay > 0:
            await asyncio.sleep(delay)
    _last_request[origin] = time.monotonic()

    headers = {"User-Agent": settings.off_user_agent}
    if client is not None:
        return await client.get(
            url,
            headers=headers,
            timeout=settings.http_timeout_seconds,
        )
    async with httpx.AsyncClient() as active_client:
        return await active_client.get(
            url,
            headers=headers,
            timeout=settings.http_timeout_seconds,
        )