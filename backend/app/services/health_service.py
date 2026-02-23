"""Health guardian service — screen time tracking, reminders, exercise plans."""

import uuid

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.health import (
    ExercisePlan,
    HealthReminder,
    ReminderType,
    ScreenTimeRecord,
)

logger = structlog.get_logger()

# Pre-defined exercise templates
EXERCISE_TEMPLATES: dict[str, list[dict]] = {
    "stretch": [
        {"name": "颈部拉伸", "description": "左右各转头5次，上下点头5次", "duration_seconds": 60},
        {"name": "肩部环绕", "description": "双肩向前转10圈，向后转10圈", "duration_seconds": 60},
        {"name": "手腕旋转", "description": "双手腕向内向外各旋转10次", "duration_seconds": 30},
        {"name": "腰部扭转", "description": "双手叉腰，左右各扭转5次", "duration_seconds": 60},
        {"name": "小腿拉伸", "description": "脚尖着地，脚后跟上下提10次", "duration_seconds": 60},
    ],
    "strength": [
        {"name": "深蹲", "description": "双脚与肩同宽，缓慢下蹲10次", "duration_seconds": 90},
        {"name": "靠墙俯卧撑", "description": "面对墙壁，做10次俯卧撑", "duration_seconds": 60},
        {"name": "提踵", "description": "脚尖站立，缓慢上下提踵15次", "duration_seconds": 60},
        {"name": "原地高抬腿", "description": "原地交替高抬腿20次", "duration_seconds": 60},
    ],
    "coordination": [
        {"name": "眼保健操", "description": "按压太阳穴、睛明穴各30秒，远眺1分钟", "duration_seconds": 120},
        {"name": "手指操", "description": "十指交叉握拳放松10次，拇指依次触碰其他手指", "duration_seconds": 60},
        {"name": "单脚站立", "description": "左右脚各单脚站立30秒", "duration_seconds": 60},
    ],
}

# Contextual reminder messages
REMINDER_MESSAGES: dict[ReminderType, list[str]] = {
    ReminderType.BREAK: [
        "已经学习了一段时间，站起来活动活动吧！",
        "休息一下，去喝杯水，伸展一下身体。",
        "大脑也需要休息哦，起来走动几分钟再继续。",
    ],
    ReminderType.EYE_REST: [
        "让眼睛休息一下吧，看看窗外远处的风景。",
        "20-20-20法则：每20分钟，看20英尺外的东西20秒。",
        "闭眼轻轻按压眼周，让疲劳的眼睛放松一下。",
    ],
    ReminderType.EXERCISE: [
        "来做一组简单的拉伸运动吧，只需要5分钟！",
        "运动可以帮助大脑更好地工作，试试深蹲或原地踏步。",
    ],
    ReminderType.POSTURE: [
        "注意坐姿哦，挺直腰背，肩膀放松。",
        "检查一下你和屏幕的距离，建议保持50cm以上。",
    ],
    ReminderType.FORCED_BREAK: [
        "你已经连续使用超过40分钟了，请至少休息5分钟！",
        "强制休息时间到！离开屏幕，让眼睛和身体好好休息。",
    ],
}


class HealthService:
    """Service for health monitoring, reminders, and exercise plans."""

    def __init__(self, db: AsyncSession) -> None:
        self._db = db

    # ── Screen Time ──

    async def record_screen_time(
        self,
        user_id: uuid.UUID,
        duration_seconds: int,
        posture_score: float | None = None,
        face_distance_cm: float | None = None,
        continuous_minutes: int = 0,
    ) -> ScreenTimeRecord:
        """Record screen time data from client."""
        record = ScreenTimeRecord(
            user_id=user_id,
            duration_seconds=duration_seconds,
            posture_score=posture_score,
            face_distance_cm=face_distance_cm,
            continuous_minutes=continuous_minutes,
        )
        self._db.add(record)
        await self._db.flush()

        # Check if forced break needed
        reminder_type = None
        if continuous_minutes >= 40:
            reminder_type = ReminderType.FORCED_BREAK
        elif continuous_minutes >= 25:
            reminder_type = ReminderType.BREAK

        if reminder_type:
            logger.info(
                "health.reminder_triggered",
                user_id=str(user_id),
                type=reminder_type,
                continuous_minutes=continuous_minutes,
            )

        return record

    async def get_screen_time_history(
        self,
        user_id: uuid.UUID,
        limit: int = 50,
    ) -> list[ScreenTimeRecord]:
        """Get recent screen time records."""
        stmt = (
            select(ScreenTimeRecord)
            .where(ScreenTimeRecord.user_id == user_id)
            .order_by(ScreenTimeRecord.created_at.desc())
            .limit(limit)
        )
        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    # ── Reminders ──

    async def get_reminder_config(
        self,
        user_id: uuid.UUID,
    ) -> HealthReminder:
        """Get or create default reminder configuration."""
        stmt = select(HealthReminder).where(HealthReminder.user_id == user_id)
        result = await self._db.execute(stmt)
        config = result.scalar_one_or_none()

        if not config:
            config = HealthReminder(user_id=user_id)
            self._db.add(config)
            await self._db.flush()

        return config

    async def update_reminder_config(
        self,
        user_id: uuid.UUID,
        reminder_interval_minutes: int | None = None,
        forced_break_minutes: int | None = None,
        break_duration_minutes: int | None = None,
        eye_rest_enabled: bool | None = None,
        exercise_enabled: bool | None = None,
        posture_enabled: bool | None = None,
    ) -> HealthReminder:
        """Update reminder configuration."""
        config = await self.get_reminder_config(user_id)

        if reminder_interval_minutes is not None:
            config.reminder_interval_minutes = reminder_interval_minutes
        if forced_break_minutes is not None:
            config.forced_break_minutes = forced_break_minutes
        if break_duration_minutes is not None:
            config.break_duration_minutes = break_duration_minutes
        if eye_rest_enabled is not None:
            config.eye_rest_enabled = eye_rest_enabled
        if exercise_enabled is not None:
            config.exercise_enabled = exercise_enabled
        if posture_enabled is not None:
            config.posture_enabled = posture_enabled

        await self._db.flush()
        return config

    def get_reminder_message(
        self,
        reminder_type: ReminderType,
        continuous_minutes: int = 0,
    ) -> str:
        """Get a contextual reminder message."""
        import random
        messages = REMINDER_MESSAGES.get(reminder_type, REMINDER_MESSAGES[ReminderType.BREAK])
        return random.choice(messages)

    # ── Exercise Plans ──

    async def get_exercise_plan(
        self,
        user_id: uuid.UUID,
        plan_type: str = "stretch",
    ) -> ExercisePlan:
        """Get or generate an exercise plan for the user."""
        exercises = EXERCISE_TEMPLATES.get(plan_type, EXERCISE_TEMPLATES["stretch"])
        total_seconds = sum(e["duration_seconds"] for e in exercises)

        plan = ExercisePlan(
            user_id=user_id,
            plan_type=plan_type,
            exercises=exercises,
            duration_minutes=max(total_seconds // 60, 1),
        )
        self._db.add(plan)
        await self._db.flush()
        return plan

    async def complete_exercise(
        self,
        plan_id: uuid.UUID,
        user_id: uuid.UUID,
    ) -> ExercisePlan | None:
        """Mark an exercise plan as completed."""
        stmt = select(ExercisePlan).where(
            ExercisePlan.id == plan_id,
            ExercisePlan.user_id == user_id,
        )
        result = await self._db.execute(stmt)
        plan = result.scalar_one_or_none()

        if not plan:
            return None

        plan.completed = True
        await self._db.flush()
        return plan
