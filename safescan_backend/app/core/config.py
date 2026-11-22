from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql://safescan:safescan@localhost:5432/safescan_db"

    # JWT
    SECRET_KEY: str = "dev_secret_key_change_in_production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # App
    APP_ENV: str = "development"
    CORS_ORIGINS: str = "http://localhost:5173,http://localhost:3000"

    # Optional Gemini API
    GEMINI_API_KEY: str = ""

    @property
    def cors_origins_list(self) -> List[str]:
        return [o.strip() for o in self.CORS_ORIGINS.split(",")]

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
