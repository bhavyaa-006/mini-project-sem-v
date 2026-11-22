from safescan_engines.config import settings
from safescan_engines.db import Base, get_engine, session_scope
from safescan_engines.hazard_db.loader import merge_hazard_csvs, upsert_hazards
from safescan_engines.hazard_db.validators import read_validated_csv
import safescan_engines.hazard_db.schema


def main() -> None:
    hazards_dir = settings.HAZARDS_DIR
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

    engine = get_engine()
    Base.metadata.create_all(engine)
    with session_scope() as session:
        counts = upsert_hazards(session, rows)
    print(
        f"Merged {merged} hazard entries: "
        f"inserted={counts['inserted']}, updated={counts['updated']}"
    )


if __name__ == "__main__":
    main()