"""Health monitoring models — screen time, reminders, exercise plans."""

import enum
import uuid

from sqlalchemy import Boolean, Float, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class ReminderType(enum.StrEnum):
    BREAK = "break"           # 休息提醒
    EYE_REST = "eye_rest"     # 远眺放松
    EXERCISE = "exercise"     # 运动提醒
    POSTURE = "posture"       # 坐姿提醒
    FORCED_BREAK = "forced_break"  # 强制休息


class ScreenTimeRecord(BaseModel):
    """Records screen usage data reported by client every 5 minutes."""

    __tablename__ = "screen_time_records"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    duration_seconds: Mapped[int] = mapped_column(Integer, nullable=False)
    posture_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    face_distance_cm: Mapped[float | None] = mapped_column(Float, nullable=True)
    continuous_minutes: Mapped[int] = mapped_column(Integer, default=0, nullable=False)


class HealthReminder(BaseModel):
    """Health reminder configuration per user."""

    __tablename__ = "health_reminders"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    reminder_interval_minutes: Mapped[int] = mapped_column(Integer, default=25, nullable=False)
    forced_break_minutes: Mapped[int] = mapped_column(Integer, default=40, nullable=False)
    break_duration_minutes: Mapped[int] = mapped_column(Integer, default=5, nullable=False)
    eye_rest_enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    exercise_enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    posture_enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)


class ExercisePlan(BaseModel):
    """Daily micro-exercise plan generated for user."""

    __tablename__ = "exercise_plans"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    plan_type: Mapped[str] = mapped_column(String(30), nullable=False)  # stretch / strength / coordination
    exercises: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    duration_minutes: Mapped[int] = mapped_column(Integer, default=5, nullable=False)
    completed: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
