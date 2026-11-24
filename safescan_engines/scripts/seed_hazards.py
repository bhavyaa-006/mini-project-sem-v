import argparse
import sys
from pathlib import Path
from safescan_engines.config import settings
from safescan_engines.db import Base, get_engine, SessionLocal
from sqlalchemy.orm import sessionmaker
from safescan_engines.hazard_db.loader import merge_hazard_csvs, upsert_hazards
from safescan_engines.hazard_db.validators import read_validated_csv
import safescan_engines.hazard_db.schema


def main() -> int:
    parser = argparse.ArgumentParser(description="Merge and seed hazard CSV data")
    parser.add_argument("--csv-dir", type=Path, default=settings.HAZARDS_DIR)
    parser.add_argument("--db-url", default=None)
    args = parser.parse_args()

    hazards_dir = args.csv_dir.resolve()
    source_paths = [
        hazards_dir / "ewg_skin_deep.csv",
        hazards_dir / "fssai_additives.csv",
        hazards_dir / "inci_decoder.csv",
    ]
    master_path = hazards_dir / "master.csv"
    merged = merge_hazard_csvs(source_paths, master_path)
    rows, errors = read_validated_csv(master_path)
    if errors:
        print("Validation errors:")
        for error in errors:
            print(f"  {error}")
        raise SystemExit(1)

    engine = get_engine(args.db_url) if args.db_url else get_engine()
    Base.metadata.create_all(engine)
    session_factory = sessionmaker(bind=engine, autoflush=False, autocommit=False, expire_on_commit=False)
    with session_factory() as session:
        counts = upsert_hazards(session, rows)
        session.commit()
    print(
        f"Merged {merged} hazard entries: "
        f"inserted={counts['inserted']}, updated={counts['updated']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())