from fastapi import APIRouter

from app.api.v1.academic import router as academic_router
from app.api.v1.auth import router as auth_router
from app.api.v1.career import router as career_router
from app.api.v1.chat import router as chat_router
from app.api.v1.classroom import router as classroom_router
from app.api.v1.creative import router as creative_router
from app.api.v1.emotional import router as emotional_router
from app.api.v1.health import router as health_router
from app.api.v1.users import router as users_router

router = APIRouter()


@router.get("/health", tags=["system"])
async def health_check() -> dict:
    return {"status": "healthy", "service": "jy-companion-api", "version": "0.1.0"}


router.include_router(auth_router)
router.include_router(users_router)
router.include_router(chat_router)
router.include_router(academic_router)
router.include_router(classroom_router)
router.include_router(emotional_router)
router.include_router(health_router)
router.include_router(creative_router)
router.include_router(career_router)
