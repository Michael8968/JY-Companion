"""Health guardian API endpoints."""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.core.exceptions import NotFoundError
from app.schemas.health import (
    ExercisePlanResponse,
    ReminderConfigResponse,
    ReminderConfigUpdateRequest,
    ScreenTimeRequest,
    ScreenTimeResponse,
)
from app.services.health_service import HealthService

router = APIRouter(prefix="/health", tags=["health"])


@router.post("/screen-time", response_model=ScreenTimeResponse)
async def report_screen_time(
    body: ScreenTimeRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ScreenTimeResponse:
    """Report screen usage data (client calls every 5 min)."""
    service = HealthService(db)
    record = await service.record_screen_time(
        user_id=uuid.UUID(user_id),
        duration_seconds=body.duration_seconds,
        posture_score=body.posture_score,
        face_distance_cm=body.face_distance_cm,
        continuous_minutes=body.continuous_minutes,
    )
    return ScreenTimeResponse.model_validate(record)


@router.get("/screen-time", response_model=list[ScreenTimeResponse])
async def get_screen_time_history(
    limit: int = Query(default=50, le=200),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[ScreenTimeResponse]:
    """Get screen time history."""
    service = HealthService(db)
    records = await service.get_screen_time_history(uuid.UUID(user_id), limit=limit)
    return [ScreenTimeResponse.model_validate(r) for r in records]


@router.get("/reminders", response_model=ReminderConfigResponse)
async def get_reminder_config(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ReminderConfigResponse:
    """Get current reminder configuration."""
    service = HealthService(db)
    config = await service.get_reminder_config(uuid.UUID(user_id))
    return ReminderConfigResponse.model_validate(config)


@router.put("/reminders", response_model=ReminderConfigResponse)
async def update_reminder_config(
    body: ReminderConfigUpdateRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ReminderConfigResponse:
    """Update reminder configuration."""
    service = HealthService(db)
    config = await service.update_reminder_config(
        user_id=uuid.UUID(user_id),
        **body.model_dump(exclude_none=True),
    )
    return ReminderConfigResponse.model_validate(config)


@router.get("/exercise-plan", response_model=ExercisePlanResponse)
async def get_exercise_plan(
    plan_type: str = Query(default="stretch", pattern="^(stretch|strength|coordination)$"),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ExercisePlanResponse:
    """Get a micro-exercise plan."""
    service = HealthService(db)
    plan = await service.get_exercise_plan(uuid.UUID(user_id), plan_type=plan_type)
    return ExercisePlanResponse.model_validate(plan)


@router.post("/exercise-plan/{plan_id}/complete", response_model=ExercisePlanResponse)
async def complete_exercise(
    plan_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ExercisePlanResponse:
    """Mark an exercise plan as completed."""
    service = HealthService(db)
    plan = await service.complete_exercise(plan_id, uuid.UUID(user_id))
    if not plan:
        raise NotFoundError("Exercise plan not found")
    return ExercisePlanResponse.model_validate(plan)
