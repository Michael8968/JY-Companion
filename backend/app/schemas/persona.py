"""Schemas for persona interaction API."""

import uuid
from datetime import datetime

from pydantic import BaseModel


class PersonaResponse(BaseModel):
    id: uuid.UUID
    name: str
    display_name: str
    avatar_url: str | None = None
    description: str | None = None
    personality_traits: dict | None = None
    speaking_style: str | None = None
    tone: str | None = None
    catchphrase: str | None = None
    vocabulary_level: str | None = None
    emoji_usage: str | None = None
    humor_level: str | None = None
    formality: str | None = None
    empathy_level: str | None = None
    knowledge_domains: dict | None = None
    preferred_agent_types: dict | None = None
    voice_style: str | None = None
    voice_speed: str | None = None
    animation_set: str | None = None
    response_length: str | None = None
    encouragement_style: str | None = None
    teaching_approach: str | None = None
    is_preset: bool
    is_active: bool
    version: int
    created_at: datetime

    model_config = {"from_attributes": True}


class BindPersonaRequest(BaseModel):
    persona_id: uuid.UUID
    nickname: str | None = None


class UserPersonaBindingResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    persona_id: uuid.UUID
    nickname: str | None = None
    is_active: bool
    is_default: bool
    interaction_count: int
    created_at: datetime

    model_config = {"from_attributes": True}


class MemoryEntryResponse(BaseModel):
    id: uuid.UUID
    persona_id: uuid.UUID
    user_id: uuid.UUID
    memory_type: str
    content: str
    importance: int
    context: dict | None = None
    is_fulfilled: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class AddMemoryRequest(BaseModel):
    memory_type: str
    content: str
    importance: int = 5
    context: dict | None = None
