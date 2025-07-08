import os
import json
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # --- General Settings ---
    PROJECT_NAME: str = "在线图片库系统"
    API_V1_STR: str = "/api/v1"

    # CORS配置 - 支持环境变量配置
    BACKEND_CORS_ORIGINS: str = ""
    
    @property
    def get_backend_cors_origins(self) -> list[str]:
        """获取CORS允许的源列表，支持环境变量配置"""
        if self.BACKEND_CORS_ORIGINS:
            # 从环境变量读取，支持逗号分隔的字符串
            origins = [origin.strip() for origin in self.BACKEND_CORS_ORIGINS.split(",") if origin.strip()]
            return origins
        else:
            # 默认开发环境配置
            return [
                "http://localhost:3300",
                "http://127.0.0.1:3300"
            ]
    DATABASE_URL: str = "mysql+pymysql:/user:password@ip:3306/gallerydb?charset=utf8mb4"
    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        return self.DATABASE_URL

    # --- Security (JWT) ---
    # 使用 `openssl rand -hex 32` 生成一个随机密钥
    SECRET_KEY: str ="09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 天

    # --- First Superuser ---
    FIRST_SUPERUSER: str = "admin"
    FIRST_SUPERUSER_EMAIL: str = "36178831@qq.com"
    FIRST_SUPERUSER_PASSWORD: str = "admin123"

    # --- File Storage ---
    UPLOAD_DIRECTORY: str = "uploads"

    # --- Watermark Settings ---
    WATERMARK_TEXT: str = "Image Gallery"
    WATERMARK_FONT_PATH: str = "/app/fonts/default.ttf"
    WATERMARK_FONT_SIZE: int = 36


    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",  # 忽略额外的字段，避免启动失败
    )
settings = Settings() 