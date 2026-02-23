"""Schemas for voice dialogue API."""

import uuid

from pydantic import BaseModel


class VoiceDialogueRequest(BaseModel):
    conversation_id: uuid.UUID
    audio_base64: str | None = None
    audio_url: str | None = None
    speaker: str = "default"


class VoiceDialogueResponse(BaseModel):
    recognized_text: str
    response_text: str
    has_audio: bool
    audio_base64: str | None = None
    emotion_label: str | None = None
    emotion_valence: float | None = None
    emotion_arousal: float | None = None
    emotion_confidence: float | None = None
    voice_params: dict | None = None
    animation_params: dict | None = None
    intent: str | None = None


class TTSSynthesizeRequest(BaseModel):
    text: str
    speaker: str = "default"
    emotion_label: str | None = None


class TTSSynthesizeResponse(BaseModel):
    has_audio: bool
    audio_base64: str | None = None
    voice_params: dict | None = None


class SSOLoginURLResponse(BaseModel):
    login_url: str


class SSOCallbackRequest(BaseModel):
    ticket: str


class SSOUserInfoResponse(BaseModel):
    external_id: str
    username: str
    display_name: str
    email: str | None = None
    role: str | None = None
    school_id: str | None = None
    class_name: str | None = None
    grade: str | None = None
