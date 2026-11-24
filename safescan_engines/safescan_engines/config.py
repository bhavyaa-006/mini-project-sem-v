from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


ROOT_DIR: Path = Path(__file__).resolve().parents[1]
DATA_DIR: Path = ROOT_DIR / "data"
HAZARDS_DIR: Path = DATA_DIR / "hazards"
REPORTS_DIR: Path = ROOT_DIR / "reports"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=ROOT_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    database_url: str = "sqlite:///./safescan_dev.db"
    off_base_url: str = "https://world.openfoodfacts.org/api/v2"
    obf_base_url: str = "https://world.openbeautyfacts.org/api/v2"
    off_user_agent: str = "SafeScanPackCheckAI/0.1 (BMSITM-CSE-StudentProject)"
    http_timeout_seconds: float = Field(default=10.0, gt=0)
    fuzzy_match_threshold: int = Field(default=85, ge=0, le=100)
    min_fuzzy_token_length: int = Field(default=6, ge=1)
    llm_api_key: str | None = None
    llm_base_url: str = "https://api.openai.com/v1"
    llm_model: str = "gpt-4o-mini"

    @property
    def ROOT_DIR(self) -> Path:
        return ROOT_DIR

    @property
    def DATA_DIR(self) -> Path:
        return DATA_DIR

    @property
    def HAZARDS_DIR(self) -> Path:
        return HAZARDS_DIR

    @property
    def REPORTS_DIR(self) -> Path:
        return REPORTS_DIR


settings = Settings()