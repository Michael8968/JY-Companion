"""Career planning models — goals, learning paths, progress reports."""

import enum
import uuid

from sqlalchemy import Enum, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class GoalStatus(enum.StrEnum):
    ACTIVE = "active"
    COMPLETED = "completed"
    PAUSED = "paused"
    ABANDONED = "abandoned"


class GoalPriority(enum.StrEnum):
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class Goal(BaseModel):
    """SMART goal with hierarchical sub-task support."""

    __tablename__ = "goals"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    parent_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("goals.id"), nullable=True
    )
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[GoalStatus] = mapped_column(
        Enum(GoalStatus), default=GoalStatus.ACTIVE, nullable=False
    )
    priority: Mapped[GoalPriority] = mapped_column(
        Enum(GoalPriority), default=GoalPriority.MEDIUM, nullable=False
    )
    progress_percent: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    estimated_hours: Mapped[float | None] = mapped_column(Float, nullable=True)
    deadline: Mapped[str | None] = mapped_column(String(20), nullable=True)  # ISO date
    smart_criteria: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    sub_tasks: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    level: Mapped[int] = mapped_column(Integer, default=0, nullable=False)  # 0=root, 1=month, 2=week, 3=daily


class LearningPath(BaseModel):
    """Personalized learning path recommendation."""

    __tablename__ = "learning_paths"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    resources: Mapped[dict | None] = mapped_column(JSONB, nullable=True)  # [{type, title, url, order}]
    current_stage: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_stages: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    interest_tags: Mapped[dict | None] = mapped_column(JSONB, nullable=True)


class ProgressReport(BaseModel):
    """Weekly progress report with analytics."""

    __tablename__ = "progress_reports"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    report_type: Mapped[str] = mapped_column(String(20), default="weekly", nullable=False)
    period_start: Mapped[str] = mapped_column(String(20), nullable=False)
    period_end: Mapped[str] = mapped_column(String(20), nullable=False)
    completion_stats: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    deviation_analysis: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    recommendations: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    content: Mapped[str | None] = mapped_column(Text, nullable=True)
