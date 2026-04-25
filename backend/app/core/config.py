from pydantic_settings import BaseSettings
import os

class Settings(BaseSettings):
    PROJECT_NAME: str = "MitoGEx API"
    API_V1_STR: str = "/api/v1"
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-super-secret-key-for-jwt")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://mitogex:mitogex_pass@db/mitogex")
    
    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://redis:6379/0")
    
    # Storage (SeaweedFS)
    S3_ENDPOINT: str = os.getenv("S3_ENDPOINT", "http://seaweedfs:8334")
    S3_ACCESS_KEY: str = os.getenv("S3_ACCESS_KEY", "any")
    S3_SECRET_KEY: str = os.getenv("S3_SECRET_KEY", "any")
    S3_BUCKET: str = "mitogex-data"

    class Config:
        case_sensitive = True

settings = Settings()
