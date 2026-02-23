"""Schemas for health guardian API."""

import uuid
from datetime import datetime

from pydantic import BaseModel


class ScreenTimeRequest(BaseModel):
    duration_seconds: int
    posture_score: float | None = None
    face_distance_cm: float | None = None
    continuous_minutes: int = 0


class ScreenTimeResponse(BaseModel):
    id: uuid.UUID
    duration_seconds: int
    posture_score: float | None = None
    face_distance_cm: float | None = None
    continuous_minutes: int
    created_at: datetime

    model_config = {"from_attributes": True}


class ReminderConfigResponse(BaseModel):
    id: uuid.UUID
    reminder_interval_minutes: int
    forced_break_minutes: int
    break_duration_minutes: int
    eye_rest_enabled: bool
    exercise_enabled: bool
    posture_enabled: bool

    model_config = {"from_attributes": True}


class ReminderConfigUpdateRequest(BaseModel):
    reminder_interval_minutes: int | None = None
    forced_break_minutes: int | None = None
    break_duration_minutes: int | None = None
    eye_rest_enabled: bool | None = None
    exercise_enabled: bool | None = None
    posture_enabled: bool | None = None


class ExercisePlanResponse(BaseModel):
    id: uuid.UUID
    plan_type: str
    exercises: dict | None = None
    duration_minutes: int
    completed: bool
    created_at: datetime

    model_config = {"from_attributes": True}
