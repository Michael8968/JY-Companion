"""Classroom session API endpoints."""

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.core.exceptions import NotFoundError
from app.schemas.classroom import (
    ClassroomSessionResponse,
    CreateSessionRequest,
    DoubtResponse,
    LearningProfileResponse,
    StudyPlanResponse,
)
from app.services.classroom_service import ClassroomService

router = APIRouter(prefix="/classroom", tags=["classroom"])


@router.post("/sessions", response_model=ClassroomSessionResponse)
async def create_session(
    body: CreateSessionRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ClassroomSessionResponse:
    service = ClassroomService(db)
    session = await service.create_session(
        user_id=uuid.UUID(user_id),
        title=body.title,
        subject=body.subject,
        audio_url=body.audio_url,
        duration_seconds=body.duration_seconds,
    )
    return ClassroomSessionResponse.model_validate(session)


@router.post("/sessions/{session_id}/transcribe", response_model=ClassroomSessionResponse)
async def transcribe_session(
    session_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ClassroomSessionResponse:
    service = ClassroomService(db)
    session = await service.transcribe(session_id, uuid.UUID(user_id))
    if not session:
        raise NotFoundError("Session not found or missing audio")
    return ClassroomSessionResponse.model_validate(session)


@router.get("/sessions/{session_id}", response_model=ClassroomSessionResponse)
async def get_session(
    session_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ClassroomSessionResponse:
    service = ClassroomService(db)
    session = await service.get_session(session_id, uuid.UUID(user_id))
    if not session:
        raise NotFoundError("Session not found")
    return ClassroomSessionResponse.model_validate(session)


@router.get("/sessions/{session_id}/doubts", response_model=list[DoubtResponse])
async def get_session_doubts(
    session_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[DoubtResponse]:
    service = ClassroomService(db)
    # Verify user owns the session
    session = await service.get_session(session_id, uuid.UUID(user_id))
    if not session:
        raise NotFoundError("Session not found")
    doubts = await service.get_doubts(session_id)
    return [DoubtResponse.model_validate(d) for d in doubts]


@router.post("/sessions/{session_id}/study-plan", response_model=StudyPlanResponse)
async def generate_study_plan(
    session_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> StudyPlanResponse:
    service = ClassroomService(db)
    plan = await service.generate_study_plan(session_id, uuid.UUID(user_id))
    if not plan:
        raise NotFoundError("Session not found or no transcript available")
    return StudyPlanResponse.model_validate(plan)


@router.get("/profile", response_model=LearningProfileResponse)
async def get_learning_profile(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> LearningProfileResponse:
    service = ClassroomService(db)
    profile = await service.get_learning_profile(uuid.UUID(user_id))
    return LearningProfileResponse.model_validate(profile)
