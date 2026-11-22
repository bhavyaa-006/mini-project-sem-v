from typing import Literal

import httpx

from safescan_engines.config import settings
from safescan_engines.data_sources.normalizer import FIELDS_TO_REQUEST, normalize_off_product
from safescan_engines.schemas import NormalizedProduct, ProductDomain


class DataSourceError(RuntimeError):
    pass


async def fetch_off_product(
    barcode: str,
    client: httpx.AsyncClient | None = None,
) -> NormalizedProduct | None:
    url = f"{settings.off_base_url.rstrip('/')}/product/{barcode}?fields={FIELDS_TO_REQUEST}"
    headers = {"User-Agent": settings.off_user_agent}

    async def request(active_client: httpx.AsyncClient) -> httpx.Response:
        try:
            return await active_client.get(
                url,
                headers=headers,
                timeout=settings.http_timeout_seconds,
            )
        except httpx.TimeoutException as exc:
            raise DataSourceError(f"Open Food Facts request timed out: {barcode}") from exc

    if client is not None:
        try:
            response = await request(client)
        except DataSourceError:
            raise
    else:
        async with httpx.AsyncClient() as active_client:
            try:
                response = await request(active_client)
            except DataSourceError:
                raise

    if response.status_code == 404:
        return None
    if response.status_code >= 500:
        raise DataSourceError(
            f"Open Food Facts service error {response.status_code} for {barcode}"
        )
    try:
        response.raise_for_status()
    except httpx.HTTPStatusError as exc:
        raise DataSourceError(
            f"Open Food Facts HTTP error {response.status_code} for {barcode}"
        ) from exc
    return normalize_off_product(response.json(), domain=ProductDomain.FOOD, source="off")