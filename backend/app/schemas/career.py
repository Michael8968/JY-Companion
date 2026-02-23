"""Schemas for career planning API."""

import uuid
from datetime import datetime

from pydantic import BaseModel

from app.models.career import GoalPriority, GoalStatus


class CreateGoalRequest(BaseModel):
    title: str
    description: str | None = None
    parent_id: uuid.UUID | None = None
    priority: GoalPriority = GoalPriority.MEDIUM
    deadline: str | None = None
    estimated_hours: float | None = None


class GoalResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    parent_id: uuid.UUID | None = None
    title: str
    description: str | None = None
    status: GoalStatus
    priority: GoalPriority
    progress_percent: float
    estimated_hours: float | None = None
    deadline: str | None = None
    smart_criteria: dict | None = None
    sub_tasks: dict | None = None
    level: int
    created_at: datetime

    model_config = {"from_attributes": True}


class UpdateGoalRequest(BaseModel):
    progress_percent: float | None = None
    status: GoalStatus | None = None


class LearningPathResponse(BaseModel):
    id: uuid.UUID
    title: str
    description: str | None = None
    resources: dict | None = None
    current_stage: int
    total_stages: int
    interest_tags: dict | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class GenerateLearningPathRequest(BaseModel):
    interests: list[str]
    goal_description: str


class ProgressReportResponse(BaseModel):
    id: uuid.UUID
    report_type: str
    period_start: str
    period_end: str
    completion_stats: dict | None = None
    deviation_analysis: dict | None = None
    recommendations: dict | None = None
    content: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class GenerateReportRequest(BaseModel):
    period_start: str
    period_end: str
