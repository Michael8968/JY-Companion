"""SSO provider — school unified identity authentication integration.

Supports:
  - CAS (Central Authentication Service) — common in Chinese schools
  - OAuth2 / OIDC generic providers
  - Custom school API-based authentication

Flow:
  1. Frontend redirects user to SSO login URL
  2. SSO server authenticates and redirects back with a ticket/code
  3. Backend validates ticket with SSO server
  4. Creates or links local user account
"""

import httpx
import structlog

from app.config.settings import get_settings

logger = structlog.get_logger()


class SSOUserInfo:
    """User information returned from SSO provider."""

    def __init__(
        self,
        external_id: str,
        username: str,
        display_name: str,
        email: str | None = None,
        role: str | None = None,
        school_id: str | None = None,
        class_name: str | None = None,
        grade: str | None = None,
        extra: dict | None = None,
    ):
        self.external_id = external_id
        self.username = username
        self.display_name = display_name
        self.email = email
        self.role = role  # student / teacher / parent / admin
        self.school_id = school_id
        self.class_name = class_name
        self.grade = grade
        self.extra = extra or {}


class SSOProvider:
    """Base SSO provider for school authentication systems.

    Supports CAS protocol (widely used in Chinese educational institutions).
    """

    def __init__(
        self,
        sso_base_url: str | None = None,
        service_url: str | None = None,
        protocol: str = "cas",
    ) -> None:
        settings = get_settings()
        self._sso_base_url = (
            sso_base_url
            or getattr(settings, "sso_base_url", "https://sso.example.edu.cn")
        ).rstrip("/")
        self._service_url = (
            service_url
            or getattr(settings, "sso_service_url", "https://companion.example.edu.cn/api/v1/auth/sso/callback")
        )
        self._protocol = protocol

    def get_login_url(self, redirect_url: str | None = None) -> str:
        """Generate SSO login URL for frontend redirect.

        Args:
            redirect_url: Override callback URL (defaults to configured service_url).
        """
        service = redirect_url or self._service_url
        if self._protocol == "cas":
            return f"{self._sso_base_url}/login?service={service}"
        # OAuth2 / OIDC
        return f"{self._sso_base_url}/authorize?response_type=code&client_id=jy-companion&redirect_uri={service}"

    def get_logout_url(self, redirect_url: str | None = None) -> str:
        """Generate SSO logout URL."""
        service = redirect_url or self._service_url
        if self._protocol == "cas":
            return f"{self._sso_base_url}/logout?service={service}"
        return f"{self._sso_base_url}/logout?redirect_uri={service}"

    async def validate_ticket(self, ticket: str) -> SSOUserInfo | None:
        """Validate a CAS ticket and retrieve user information.

        Args:
            ticket: The CAS service ticket from the SSO callback.

        Returns:
            SSOUserInfo if validation succeeds, None otherwise.
        """
        if self._protocol == "cas":
            return await self._validate_cas_ticket(ticket)
        return await self._validate_oauth_code(ticket)

    async def _validate_cas_ticket(self, ticket: str) -> SSOUserInfo | None:
        """Validate CAS service ticket via serviceValidate endpoint."""
        validate_url = (
            f"{self._sso_base_url}/serviceValidate"
            f"?ticket={ticket}&service={self._service_url}&format=JSON"
        )

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(validate_url)
                resp.raise_for_status()
                data = resp.json()

            # CAS 3.0 JSON response format
            service_response = data.get("serviceResponse", {})
            success = service_response.get("authenticationSuccess")
            if not success:
                failure = service_response.get("authenticationFailure", {})
                logger.warning(
                    "sso.cas_validation_failed",
                    code=failure.get("code"),
                    description=failure.get("description"),
                )
                return None

            user = success.get("user", "")
            attributes = success.get("attributes", {})

            return SSOUserInfo(
                external_id=user,
                username=user,
                display_name=attributes.get("cn", attributes.get("displayName", user)),
                email=attributes.get("mail"),
                role=self._map_cas_role(attributes.get("eduPersonAffiliation", "")),
                school_id=attributes.get("organizationId"),
                class_name=attributes.get("className"),
                grade=attributes.get("grade"),
                extra=attributes,
            )

        except httpx.HTTPError:
            logger.exception("sso.cas_validation_error")
            return None

    async def _validate_oauth_code(self, code: str) -> SSOUserInfo | None:
        """Exchange OAuth2 authorization code for user info."""
        settings = get_settings()
        client_id = getattr(settings, "sso_client_id", "jy-companion")
        client_secret = getattr(settings, "sso_client_secret", "")

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                # Step 1: Exchange code for access token
                token_resp = await client.post(
                    f"{self._sso_base_url}/token",
                    data={
                        "grant_type": "authorization_code",
                        "code": code,
                        "redirect_uri": self._service_url,
                        "client_id": client_id,
                        "client_secret": client_secret,
                    },
                )
                token_resp.raise_for_status()
                token_data = token_resp.json()
                access_token = token_data.get("access_token")

                if not access_token:
                    logger.warning("sso.oauth_no_token")
                    return None

                # Step 2: Get user info
                userinfo_resp = await client.get(
                    f"{self._sso_base_url}/userinfo",
                    headers={"Authorization": f"Bearer {access_token}"},
                )
                userinfo_resp.raise_for_status()
                info = userinfo_resp.json()

            return SSOUserInfo(
                external_id=info.get("sub", info.get("id", "")),
                username=info.get("preferred_username", info.get("username", "")),
                display_name=info.get("name", info.get("nickname", "")),
                email=info.get("email"),
                role=self._map_oauth_role(info.get("role", info.get("roles", []))),
                school_id=info.get("organization_id"),
                class_name=info.get("class_name"),
                grade=info.get("grade"),
                extra=info,
            )

        except httpx.HTTPError:
            logger.exception("sso.oauth_validation_error")
            return None

    def _map_cas_role(self, affiliation: str) -> str:
        """Map CAS eduPersonAffiliation to platform role."""
        affiliation_lower = affiliation.lower()
        if "student" in affiliation_lower:
            return "student"
        if "faculty" in affiliation_lower or "teacher" in affiliation_lower:
            return "teacher"
        if "staff" in affiliation_lower or "admin" in affiliation_lower:
            return "admin"
        return "student"  # default for school context

    def _map_oauth_role(self, role: str | list) -> str:
        """Map OAuth2 role claim to platform role."""
        if isinstance(role, list):
            role = role[0] if role else ""
        role_lower = role.lower()
        role_map = {
            "student": "student",
            "teacher": "teacher",
            "parent": "parent",
            "admin": "admin",
            "staff": "admin",
        }
        return role_map.get(role_lower, "student")

    async def health_check(self) -> bool:
        """Check if SSO server is reachable."""
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(f"{self._sso_base_url}/health")
                return resp.status_code == 200
        except httpx.HTTPError:
            return False
