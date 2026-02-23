"""Schemas for academic tutoring API."""

import uuid
from datetime import datetime

from pydantic import BaseModel

from app.models.learning import Difficulty, ErrorType, MasteryStatus, Subject


class CreateLearningRecordRequest(BaseModel):
    subject: Subject
    question: str
    answer: str | None = None
    knowledge_points: dict | None = None
    difficulty: Difficulty = Difficulty.MEDIUM
    is_correct: bool | None = None
    conversation_id: uuid.UUID | None = None


class LearningRecordResponse(BaseModel):
    id: uuid.UUID
    subject: Subject
    question: str
    answer: str | None = None
    knowledge_points: dict | None = None
    difficulty: Difficulty
    is_correct: bool | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class DiagnoseErrorRequest(BaseModel):
    learning_record_id: uuid.UUID
    subject: Subject
    question: str
    wrong_answer: str


class ErrorRecordResponse(BaseModel):
    id: uuid.UUID
    subject: Subject
    question: str
    wrong_answer: str
    correct_answer: str | None = None
    error_type: ErrorType
    error_analysis: str | None = None
    mastery_status: MasteryStatus
    review_count: int
    knowledge_points: dict | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class ErrorBookResponse(BaseModel):
    errors: list[ErrorRecordResponse]
    total: int
    page: int
    size: int


class RecommendExercisesRequest(BaseModel):
    subject: Subject
    knowledge_points: list[str]
    mastery_level: MasteryStatus = MasteryStatus.WEAK


class RecommendExercisesResponse(BaseModel):
    content: str
