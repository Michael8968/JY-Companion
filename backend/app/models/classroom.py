"""Classroom session and user profile models."""

import enum
import uuid

from sqlalchemy import Enum, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import BaseModel


class SessionStatus(enum.StrEnum):
    UPLOADING = "uploading"
    TRANSCRIBING = "transcribing"
    SUMMARIZING = "summarizing"
    COMPLETED = "completed"
    FAILED = "failed"


class ClassroomSession(BaseModel):
    """A classroom recording session with transcription and summary."""

    __tablename__ = "classroom_sessions"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    subject: Mapped[str] = mapped_column(String(50), nullable=False)
    audio_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    duration_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    status: Mapped[SessionStatus] = mapped_column(
        Enum(SessionStatus), default=SessionStatus.UPLOADING, nullable=False
    )

    # ASR output
    transcript: Mapped[str | None] = mapped_column(Text, nullable=True)
    segments: Mapped[dict | None] = mapped_column(JSONB, nullable=True)

    # Summary output
    summary_outline: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    summary_concepts: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    key_points: Mapped[dict | None] = mapped_column(JSONB, nullable=True)

    doubts: Mapped[list["ClassroomDoubt"]] = relationship(back_populates="session")
    study_plans: Mapped[list["StudyPlan"]] = relationship(back_populates="session")


class ClassroomDoubt(BaseModel):
    """Automatically detected doubt/question points in a classroom session."""

    __tablename__ = "classroom_doubts"

    session_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("classroom_sessions.id"), nullable=False, index=True
    )
    timestamp_start: Mapped[float] = mapped_column(Float, nullable=False)
    timestamp_end: Mapped[float] = mapped_column(Float, nullable=False)
    text_excerpt: Mapped[str] = mapped_column(Text, nullable=False)
    doubt_type: Mapped[str] = mapped_column(String(50), nullable=False)  # slow_pace / repetition / student_question
    importance: Mapped[float] = mapped_column(Float, default=0.5, nullable=False)
    context: Mapped[str | None] = mapped_column(Text, nullable=True)

    session: Mapped["ClassroomSession"] = relationship(back_populates="doubts")


class StudyPlan(BaseModel):
    """Personalized study plan generated from classroom session."""

    __tablename__ = "study_plans"

    session_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("classroom_sessions.id"), nullable=False, index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    plan_type: Mapped[str] = mapped_column(String(50), nullable=False)  # basic / advanced
    review_points: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    exercises: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    extensions: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    content: Mapped[str | None] = mapped_column(Text, nullable=True)

    session: Mapped["ClassroomSession"] = relationship(back_populates="study_plans")


class UserLearningProfile(BaseModel):
    """Extended learning profile for personalization — dynamic updates."""

    __tablename__ = "user_learning_profiles"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, unique=True, index=True
    )
    learning_level: Mapped[str] = mapped_column(String(20), default="standard", nullable=False)  # basic / standard / advanced
    weak_subjects: Mapped[dict | None] = mapped_column(JSONB, nullable=True)  # {"math": 0.3, "physics": 0.6}
    strong_subjects: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    knowledge_mastery: Mapped[dict | None] = mapped_column(JSONB, nullable=True)  # {"二次函数": 0.8, ...}
    study_habits: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    total_study_hours: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    total_questions_answered: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_errors: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    accuracy_rate: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
