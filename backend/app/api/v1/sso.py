"""SSO authentication API endpoints — school unified identity integration."""

from fastapi import APIRouter

from app.integrations.sso_provider import SSOProvider
from app.schemas.voice import (
    SSOCallbackRequest,
    SSOLoginURLResponse,
    SSOUserInfoResponse,
)

router = APIRouter(prefix="/auth/sso", tags=["sso"])


@router.get("/login-url", response_model=SSOLoginURLResponse)
async def get_sso_login_url(
    redirect_url: str | None = None,
) -> SSOLoginURLResponse:
    """Get SSO login URL for frontend redirect."""
    provider = SSOProvider()
    url = provider.get_login_url(redirect_url)
    return SSOLoginURLResponse(login_url=url)


@router.post("/callback", response_model=SSOUserInfoResponse)
async def sso_callback(
    body: SSOCallbackRequest,
) -> SSOUserInfoResponse:
    """Handle SSO callback — validate ticket and return user info.

    The caller should then create/link a local user account and issue a JWT.
    """
    provider = SSOProvider()
    user_info = await provider.validate_ticket(body.ticket)
    if not user_info:
        from app.core.exceptions import NotFoundError
        raise NotFoundError("SSO ticket validation failed")

    return SSOUserInfoResponse(
        external_id=user_info.external_id,
        username=user_info.username,
        display_name=user_info.display_name,
        email=user_info.email,
        role=user_info.role,
        school_id=user_info.school_id,
        class_name=user_info.class_name,
        grade=user_info.grade,
    )


@router.get("/logout-url")
async def get_sso_logout_url(
    redirect_url: str | None = None,
) -> dict:
    """Get SSO logout URL."""
    provider = SSOProvider()
    url = provider.get_logout_url(redirect_url)
    return {"logout_url": url}
