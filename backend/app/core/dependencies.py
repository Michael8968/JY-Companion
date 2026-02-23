from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.exceptions import ForbiddenError, UnauthorizedError
from app.core.security import decode_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_current_user_id(token: str = Depends(oauth2_scheme)) -> str:
    payload = decode_token(token)
    if payload is None:
        raise UnauthorizedError()
    user_id: str | None = payload.get("sub")
    if user_id is None:
        raise UnauthorizedError()
    return user_id


async def get_current_user_role(token: str = Depends(oauth2_scheme)) -> str:
    payload = decode_token(token)
    if payload is None:
        raise UnauthorizedError()
    role: str | None = payload.get("role")
    if role is None:
        raise UnauthorizedError()
    return role


def require_role(*allowed_roles: str):
    async def role_checker(role: str = Depends(get_current_user_role)) -> str:
        if role not in allowed_roles:
            raise ForbiddenError(detail=f"Role '{role}' not allowed. Required: {allowed_roles}")
        return role
    return role_checker


async def get_db_session() -> AsyncSession:  # type: ignore[misc]
    async for session in get_db():
        yield session
