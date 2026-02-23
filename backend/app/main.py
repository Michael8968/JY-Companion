from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI

from app.api.v1.router import router as v1_router
from app.config.logging_config import setup_logging
from app.config.settings import get_settings
from app.core.middleware import setup_middleware

settings = get_settings()
logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    setup_logging(debug=settings.debug)
    await logger.ainfo("startup", app=settings.app_name, version=settings.app_version)
    yield
    await logger.ainfo("shutdown", app=settings.app_name)


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="晋元中学 AI 智能学伴平台 API",
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
    lifespan=lifespan,
)

setup_middleware(app)
app.include_router(v1_router, prefix=settings.api_v1_prefix)
