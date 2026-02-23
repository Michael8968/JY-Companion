"""Shared pytest fixtures for JY-Companion backend tests."""

import uuid

import pytest
from httpx import ASGITransport, AsyncClient

from app.core.security import create_access_token
from app.main import app


@pytest.fixture
async def client():
    """Async HTTP test client."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest.fixture
def test_user_id() -> str:
    """A deterministic test user UUID."""
    return str(uuid.UUID("00000000-0000-0000-0000-000000000001"))


@pytest.fixture
def auth_headers(test_user_id: str) -> dict[str, str]:
    """Authorization headers with a valid JWT for test_user_id."""
    token = create_access_token({"sub": test_user_id, "role": "student"})
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def auth_token(test_user_id: str) -> str:
    """Raw JWT token string for WebSocket auth."""
    return create_access_token({"sub": test_user_id, "role": "student"})
