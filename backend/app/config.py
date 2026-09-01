from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Environment-backed settings used by the foundation application."""

    app_name: str = "Investing Agent API"
    app_env: str = "development"
    api_v1_prefix: str = "/api/v1"
    frontend_origin: str = "http://localhost:3000"
    trading_mode: str = "paper"
    market_timezone: str = "Asia/Kolkata"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
