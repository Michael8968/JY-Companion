"""Persona models — companion characters, user bindings, memory entries."""

import uuid

from sqlalchemy import Boolean, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class Persona(BaseModel):
    """Companion persona definition with ≥20 configurable dimensions."""

    __tablename__ = "personas"

    # Identity
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    display_name: Mapped[str] = mapped_column(String(100), nullable=False)
    avatar_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Personality dimensions (≥20)
    personality_traits: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    # Expected keys: openness, conscientiousness, extraversion, agreeableness, neuroticism (Big Five)

    speaking_style: Mapped[str | None] = mapped_column(String(200), nullable=True)
    tone: Mapped[str | None] = mapped_column(String(100), nullable=True)  # warm / humorous / serious
    catchphrase: Mapped[str | None] = mapped_column(String(200), nullable=True)
    vocabulary_level: Mapped[str | None] = mapped_column(String(50), nullable=True)  # casual / academic / mixed
    emoji_usage: Mapped[str | None] = mapped_column(String(50), nullable=True)  # none / moderate / frequent
    humor_level: Mapped[str | None] = mapped_column(String(50), nullable=True)  # low / medium / high
    formality: Mapped[str | None] = mapped_column(String(50), nullable=True)  # formal / semi-formal / casual
    empathy_level: Mapped[str | None] = mapped_column(String(50), nullable=True)  # low / medium / high

    # Knowledge & capabilities
    knowledge_domains: Mapped[dict | None] = mapped_column(JSONB, nullable=True)  # ["math", "literature", ...]
    preferred_agent_types: Mapped[dict | None] = mapped_column(JSONB, nullable=True)  # ["academic", "emotional"]

    # Voice & appearance
    voice_style: Mapped[str | None] = mapped_column(String(100), nullable=True)
    voice_speed: Mapped[str | None] = mapped_column(String(50), nullable=True)  # slow / normal / fast
    animation_set: Mapped[str | None] = mapped_column(String(100), nullable=True)  # rive animation name

    # Behavioral traits
    response_length: Mapped[str | None] = mapped_column(String(50), nullable=True)  # concise / moderate / detailed
    encouragement_style: Mapped[str | None] = mapped_column(String(200), nullable=True)
    teaching_approach: Mapped[str | None] = mapped_column(String(200), nullable=True)

    # System
    is_preset: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    version: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)


class UserPersonaBinding(BaseModel):
    """User-persona binding — each user can have ≥5 companions."""

    __tablename__ = "user_persona_bindings"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    persona_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("personas.id"), nullable=False
    )
    nickname: Mapped[str | None] = mapped_column(String(50), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_default: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    interaction_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)


class PersonaMemoryEntry(BaseModel):
    """Cross-session memory entries for persona consistency."""

    __tablename__ = "persona_memory_entries"

    persona_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("personas.id"), nullable=False, index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    memory_type: Mapped[str] = mapped_column(String(50), nullable=False)
    # Types: commitment, preference, fact, relationship, emotional_context
    content: Mapped[str] = mapped_column(Text, nullable=False)
    importance: Mapped[int] = mapped_column(Integer, default=5, nullable=False)  # 1-10
    context: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    is_fulfilled: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
