from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql+asyncpg://pupuji:pupuji_dev@localhost:5432/pupuji"
    JWT_SECRET: str = "dev-secret-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_MINUTES: int = 60 * 24 * 30
    SMS_CODE_LENGTH: int = 6
    SMS_CODE_TTL: int = 300
    SMS_RESEND_SECONDS: int = 60

    model_config = {"env_file": ".env", "extra": "ignore"}


settings = Settings()
