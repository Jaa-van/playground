from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    PROJECT_NAME: str = "My Project"
    API_V1_STR: str = "/api/v1"
    DATABASE_URL: str = "sqlite:///./data/app.db"
    SECRET_KEY: str = "change-this-in-production"
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost",
        "http://localhost:3000",
        "http://localhost:8000",
    ]

    model_config = {"env_file": ".env"}


settings = Settings()
