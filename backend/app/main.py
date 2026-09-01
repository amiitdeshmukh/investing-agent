from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.config import get_settings

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    description="Backend API for the Investing Agent paper-trading system.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.frontend_origin],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.api_v1_prefix)


@app.get("/health", tags=["system"])
async def health_check() -> dict[str, str]:
    """Unversioned process-health endpoint for local and host monitoring."""

    return {
        "status": "ok",
        "service": "investing-agent-api",
        "mode": settings.trading_mode,
    }
