from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.core.exceptions import NotFoundError
from app.schemas.user import UserProfileResponse, UserResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> UserResponse:
    service = AuthService(db)
    user = await service.get_user_by_id(user_id)
    if not user:
        raise NotFoundError("User not found")
    return UserResponse.model_validate(user)


@router.get("/me/profile", response_model=UserProfileResponse)
async def get_current_user_profile(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> UserProfileResponse:
    service = AuthService(db)
    user = await service.get_user_by_id(user_id)
    if not user or not user.profile:
        raise NotFoundError("Profile not found")
    return UserProfileResponse.model_validate(user.profile)
