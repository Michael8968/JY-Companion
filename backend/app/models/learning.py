"""Learning record and error record models for academic tutoring."""

import enum
import uuid

from sqlalchemy import Enum, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import BaseModel


class Subject(enum.StrEnum):
    MATH = "math"
    PHYSICS = "physics"
    CHEMISTRY = "chemistry"
    CHINESE = "chinese"
    ENGLISH = "english"
    BIOLOGY = "biology"
    HISTORY = "history"
    GEOGRAPHY = "geography"
    POLITICS = "politics"


class ErrorType(enum.StrEnum):
    CONCEPT_MISUNDERSTANDING = "concept_misunderstanding"  # 概念误解
    WRONG_APPROACH = "wrong_approach"  # 思路偏差
    MISREAD_QUESTION = "misread_question"  # 审题失误
    CALCULATION_ERROR = "calculation_error"  # 计算疏忽


class MasteryStatus(enum.StrEnum):
    WEAK = "weak"
    IMPROVING = "improving"
    MASTERED = "mastered"


class Difficulty(enum.StrEnum):
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"


class LearningRecord(BaseModel):
    """Records a learning interaction (question asked, answer given)."""

    __tablename__ = "learning_records"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    conversation_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("conversations.id"), nullable=True
    )
    subject: Mapped[Subject] = mapped_column(Enum(Subject), nullable=False, index=True)
    question: Mapped[str] = mapped_column(Text, nullable=False)
    answer: Mapped[str | None] = mapped_column(Text, nullable=True)
    knowledge_points: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    difficulty: Mapped[Difficulty] = mapped_column(Enum(Difficulty), default=Difficulty.MEDIUM, nullable=False)
    is_correct: Mapped[bool | None] = mapped_column(nullable=True)
    time_spent_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)

    error_records: Mapped[list["ErrorRecord"]] = relationship(back_populates="learning_record")


class ErrorRecord(BaseModel):
    """Detailed error analysis for wrong answers."""

    __tablename__ = "error_records"

    learning_record_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("learning_records.id"), nullable=False, index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    subject: Mapped[Subject] = mapped_column(Enum(Subject), nullable=False, index=True)
    question: Mapped[str] = mapped_column(Text, nullable=False)
    wrong_answer: Mapped[str] = mapped_column(Text, nullable=False)
    correct_answer: Mapped[str | None] = mapped_column(Text, nullable=True)
    error_type: Mapped[ErrorType] = mapped_column(Enum(ErrorType), nullable=False)
    error_analysis: Mapped[str | None] = mapped_column(Text, nullable=True)
    knowledge_points: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    mastery_status: Mapped[MasteryStatus] = mapped_column(
        Enum(MasteryStatus), default=MasteryStatus.WEAK, nullable=False
    )
    review_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    recommended_exercises: Mapped[dict | None] = mapped_column(JSONB, nullable=True)

    learning_record: Mapped["LearningRecord"] = relationship(back_populates="error_records")
