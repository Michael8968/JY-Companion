"""Schemas for admin management API."""

import uuid
from datetime import datetime

from pydantic import BaseModel


class UserSummary(BaseModel):
    id: uuid.UUID
    username: str
    role: str
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class UserListResponse(BaseModel):
    users: list[UserSummary]
    total: int
    page: int
    size: int


class PlatformStatsResponse(BaseModel):
    total_users: int
    active_users_today: int
    total_conversations: int
    total_messages: int
    active_crisis_alerts: int
    avg_response_time_ms: float | None = None


class ContentAuditItem(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    content_preview: str
    safety_level: str
    matched_keywords: list[str]
    reason: str
    created_at: datetime


class ContentAuditListResponse(BaseModel):
    items: list[ContentAuditItem]
    total: int
    page: int
    size: int


class CrisisAlertSummary(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    alert_level: str
    status: str
    trigger_type: str
    trigger_content: str
    created_at: datetime

    model_config = {"from_attributes": True}


class CrisisAlertListResponse(BaseModel):
    alerts: list[CrisisAlertSummary]
    total: int
    page: int
    size: int


class UpdateUserStatusRequest(BaseModel):
    is_active: bool
    reason: str | None = None
