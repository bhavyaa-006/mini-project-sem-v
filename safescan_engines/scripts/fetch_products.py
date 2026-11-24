import argparse
import asyncio
import sys
import time
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[1]
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from safescan_engines.data_sources.off_client import fetch_off_product
from safescan_engines.data_sources.obf_client import fetch_obf_product
from safescan_engines.data_sources.cache import save_cached_product
from safescan_engines.db import session_scope
from safescan_engines.schemas import ProductDomain


DEFAULT_BARCODES = [
    "8901058851298",
    "8901725114068",
    "8906007280015",
    "8901063011456",
    "8901138830171",
    "8908001170001",
    "8904013200012",
    "8901499010220",
    "8901396373019",
    "8901030895554",
    "8901030868107",
    "8901088901236",
]


def read_barcodes(file_path: Path) -> list[str]:
    barcodes: list[str] = []
    with file_path.open("r", encoding="utf-8-sig") as handle:
        for line in handle:
            value = line.strip().strip(",")
            if value and value.isdigit():
                barcodes.append(value)
    return barcodes


async def fetch_all(
    barcodes: list[str],
    domain: ProductDomain,
    delay: float,
) -> tuple[list, list[str], list[str]]:
    fetched = []
    not_found = []
    cached = []
    for index, barcode in enumerate(barcodes):
        if index:
            time.sleep(delay)
        if domain == ProductDomain.FOOD:
            product = await fetch_off_product(barcode)
        else:
            product = await fetch_obf_product(barcode)
        if product is None:
            not_found.append(barcode)
        else:
            fetched.append(product)
            cached.append(barcode)
    return fetched, not_found, cached


def main() -> int:
    parser = argparse.ArgumentParser(description="Fetch and cache Indian package products")
    parser.add_argument("--barcodes", help="Comma-separated 890... barcode list")
    parser.add_argument("--file", type=Path, help="Text/CSV file containing barcodes")
    parser.add_argument("--domain", choices=("food", "cosmetic"), default="food")
    parser.add_argument("--delay", type=float, default=1.0)
    args = parser.parse_args()

    if args.barcodes:
        barcodes = [item.strip() for item in args.barcodes.split(",") if item.strip()]
    elif args.file:
        barcodes = read_barcodes(args.file)
    else:
        barcodes = DEFAULT_BARCODES

    if args.delay < 0:
        parser.error("--delay must be zero or greater")
    fetched, not_found, cached = asyncio.run(
        fetch_all(barcodes, ProductDomain(args.domain), args.delay)
    )
    with session_scope() as session:
        for product in fetched:
            save_cached_product(session, product)

    print(f"fetched={len(fetched)} not_found={len(not_found)} cached={len(cached)}")
    if not_found:
        print("not_found_barcodes=" + ",".join(not_found))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
