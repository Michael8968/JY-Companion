"""Schemas for emotional companion API."""

import uuid
from datetime import datetime

from pydantic import BaseModel

from app.models.emotion import AlertLevel, AlertStatus, EmotionLabel, EmotionSource


class EmotionRecordResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    emotion_label: EmotionLabel
    valence: float
    arousal: float
    confidence: float
    source: EmotionSource
    raw_scores: dict | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class CrisisAlertResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    alert_level: AlertLevel
    status: AlertStatus
    trigger_type: str
    trigger_content: str
    matched_keywords: dict | None = None
    notified_roles: dict | None = None
    response_time_ms: int | None = None
    resolution_notes: str | None = None
    resolved_by: uuid.UUID | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class GratitudeCreateRequest(BaseModel):
    content: str


class GratitudeEntryResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    content: str
    feedback: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class AlertActionRequest(BaseModel):
    notes: str | None = None


class InterventionStrategyResponse(BaseModel):
    id: str
    name: str
    category: str
    description: str
    instructions: str
    duration_minutes: int
