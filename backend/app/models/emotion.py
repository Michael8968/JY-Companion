"""Emotion records and crisis alert models [SAFETY-CRITICAL]."""

import enum
import uuid

from sqlalchemy import Enum, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class EmotionLabel(enum.StrEnum):
    HAPPY = "happy"
    ANXIOUS = "anxious"
    DEPRESSED = "depressed"
    CALM = "calm"
    ANGRY = "angry"
    SAD = "sad"
    FEARFUL = "fearful"


class AlertLevel(enum.StrEnum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class AlertStatus(enum.StrEnum):
    ACTIVE = "active"
    ACKNOWLEDGED = "acknowledged"
    RESOLVED = "resolved"


class EmotionSource(enum.StrEnum):
    TEXT = "text"
    VOICE = "voice"
    VISUAL = "visual"
    FUSED = "fused"


class EmotionRecord(BaseModel):
    """Records emotion state detected from user interactions."""

    __tablename__ = "emotion_records"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    conversation_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("conversations.id"), nullable=True
    )
    emotion_label: Mapped[EmotionLabel] = mapped_column(Enum(EmotionLabel), nullable=False)
    valence: Mapped[float] = mapped_column(Float, nullable=False)  # [-1, 1]
    arousal: Mapped[float] = mapped_column(Float, nullable=False)  # [0, 1]
    confidence: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    source: Mapped[EmotionSource] = mapped_column(Enum(EmotionSource), default=EmotionSource.TEXT, nullable=False)
    raw_scores: Mapped[dict | None] = mapped_column(JSONB, nullable=True)


class CrisisAlert(BaseModel):
    """Crisis alert records [SAFETY-CRITICAL].

    Each alert must track: trigger, notification targets, response time.
    Target: ≤30s response, 100% recall for high-risk keywords.
    """

    __tablename__ = "crisis_alerts"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    conversation_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("conversations.id"), nullable=True
    )
    alert_level: Mapped[AlertLevel] = mapped_column(Enum(AlertLevel), nullable=False)
    status: Mapped[AlertStatus] = mapped_column(
        Enum(AlertStatus), default=AlertStatus.ACTIVE, nullable=False, index=True
    )
    trigger_type: Mapped[str] = mapped_column(String(50), nullable=False)  # keyword / emotion_threshold
    trigger_content: Mapped[str] = mapped_column(Text, nullable=False)  # desensitized
    matched_keywords: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    notified_roles: Mapped[dict | None] = mapped_column(JSONB, nullable=True)  # ["teacher", "parent", "counselor"]
    response_time_ms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    resolution_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    resolved_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)


class GratitudeEntry(BaseModel):
    """Gratitude journal entries for positive psychology intervention."""

    __tablename__ = "gratitude_entries"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    content: Mapped[str] = mapped_column(Text, nullable=False)
    feedback: Mapped[str | None] = mapped_column(Text, nullable=True)
