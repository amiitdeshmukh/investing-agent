from fastapi import APIRouter

api_router = APIRouter()


@api_router.get("/health", tags=["system"])
async def versioned_health_check() -> dict[str, str]:
    """Versioned API-health endpoint for frontend connectivity checks."""

    return {"status": "ok", "api_version": "v1"}
