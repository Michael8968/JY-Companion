from fastapi import APIRouter

router = APIRouter()


@router.get("/health", tags=["system"])
async def health_check() -> dict:
    return {"status": "healthy", "service": "jy-companion-api", "version": "0.1.0"}
