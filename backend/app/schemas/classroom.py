"""Schemas for classroom session API."""

import uuid
from datetime import datetime

from pydantic import BaseModel

from app.models.classroom import SessionStatus


class CreateSessionRequest(BaseModel):
    title: str
    subject: str
    audio_url: str | None = None
    duration_seconds: int | None = None


class ClassroomSessionResponse(BaseModel):
    id: uuid.UUID
    title: str
    subject: str
    audio_url: str | None = None
    duration_seconds: int | None = None
    status: SessionStatus
    summary_outline: dict | None = None
    summary_concepts: dict | None = None
    key_points: dict | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class DoubtResponse(BaseModel):
    id: uuid.UUID
    timestamp_start: float
    timestamp_end: float
    text_excerpt: str
    doubt_type: str
    importance: float
    context: str | None = None

    model_config = {"from_attributes": True}


class StudyPlanResponse(BaseModel):
    id: uuid.UUID
    plan_type: str
    content: str | None = None
    review_points: dict | None = None
    exercises: dict | None = None
    extensions: dict | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class LearningProfileResponse(BaseModel):
    learning_level: str
    weak_subjects: dict | None = None
    strong_subjects: dict | None = None
    knowledge_mastery: dict | None = None
    total_study_hours: float
    total_questions_answered: int
    total_errors: int
    accuracy_rate: float

    model_config = {"from_attributes": True}
