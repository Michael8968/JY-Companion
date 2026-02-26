"""Career planning API endpoints."""

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.core.exceptions import NotFoundError
from app.models.career import GoalStatus
from app.schemas.career import (
    CreateGoalRequest,
    GenerateLearningPathRequest,
    GenerateReportRequest,
    GoalResponse,
    LearningPathResponse,
    ProgressReportResponse,
    UpdateGoalRequest,
)
from app.services.career_service import CareerService

router = APIRouter(prefix="/career", tags=["career"])


# ── Goals ──


@router.post("/goals", response_model=GoalResponse)
async def create_goal(
    body: CreateGoalRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> GoalResponse:
    """Create a SMART goal."""
    service = CareerService(db)
    goal = await service.create_goal(
        user_id=uuid.UUID(user_id),
        title=body.title,
        description=body.description,
        parent_id=body.parent_id,
        priority=body.priority,
        deadline=body.deadline,
        estimated_hours=body.estimated_hours,
    )
    return GoalResponse.model_validate(goal)


@router.get("/goals", response_model=list[GoalResponse])
async def get_goals(
    status: GoalStatus | None = None,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[GoalResponse]:
    """Get user's goals."""
    service = CareerService(db)
    goals = await service.get_goals(uuid.UUID(user_id), status=status)
    return [GoalResponse.model_validate(g) for g in goals]


@router.put("/goals/{goal_id}", response_model=GoalResponse)
async def update_goal(
    goal_id: uuid.UUID,
    body: UpdateGoalRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> GoalResponse:
    """Update goal progress or status."""
    service = CareerService(db)
    goal = await service.update_goal_progress(
        goal_id=goal_id,
        user_id=uuid.UUID(user_id),
        progress_percent=body.progress_percent,
        status=body.status,
    )
    if not goal:
        raise NotFoundError("Goal not found")
    return GoalResponse.model_validate(goal)


@router.post("/goals/{goal_id}/decompose")
async def decompose_goal(
    goal_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """Decompose a goal into SMART sub-tasks using LLM."""
    service = CareerService(db)
    return await service.decompose_goal_with_llm(goal_id, uuid.UUID(user_id))


# ── Learning Paths ──


@router.get("/learning-path", response_model=list[LearningPathResponse])
async def get_learning_paths(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[LearningPathResponse]:
    """Get user's learning paths."""
    service = CareerService(db)
    paths = await service.get_learning_path(uuid.UUID(user_id))
    return [LearningPathResponse.model_validate(p) for p in paths]


@router.post("/learning-path", response_model=LearningPathResponse)
async def generate_learning_path(
    body: GenerateLearningPathRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> LearningPathResponse:
    """Generate a personalized learning path."""
    service = CareerService(db)
    path = await service.generate_learning_path(
        uuid.UUID(user_id), body.interests, body.goal_description,
    )
    return LearningPathResponse.model_validate(path)


# ── Progress Reports ──


@router.get("/progress-report", response_model=list[ProgressReportResponse])
async def get_progress_reports(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[ProgressReportResponse]:
    """Get user's progress reports ordered by most recent."""
    service = CareerService(db)
    reports = await service.get_progress_reports(uuid.UUID(user_id))
    return [ProgressReportResponse.model_validate(r) for r in reports]


@router.post("/progress-report", response_model=ProgressReportResponse)
async def generate_progress_report(
    body: GenerateReportRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ProgressReportResponse:
    """Generate a weekly progress report."""
    service = CareerService(db)
    report = await service.generate_progress_report(
        uuid.UUID(user_id), body.period_start, body.period_end,
    )
    return ProgressReportResponse.model_validate(report)
