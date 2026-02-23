"""Emotional companion API endpoints."""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.core.exceptions import NotFoundError
from app.models.emotion import EmotionLabel
from app.schemas.emotional import (
    AlertActionRequest,
    CrisisAlertResponse,
    EmotionRecordResponse,
    GratitudeCreateRequest,
    GratitudeEntryResponse,
    InterventionStrategyResponse,
)
from app.services.emotional_service import EmotionalService
from app.services.intervention_strategies import get_strategies_for_emotion

router = APIRouter(prefix="/emotional", tags=["emotional"])


@router.get("/emotions", response_model=list[EmotionRecordResponse])
async def get_emotion_history(
    limit: int = Query(default=20, le=100),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[EmotionRecordResponse]:
    """Get current user's emotion history."""
    service = EmotionalService(db)
    records = await service.get_emotion_history(uuid.UUID(user_id), limit=limit)
    return [EmotionRecordResponse.model_validate(r) for r in records]


@router.get("/interventions/{emotion}", response_model=list[InterventionStrategyResponse])
async def get_interventions(
    emotion: EmotionLabel,
    max_results: int = Query(default=5, le=10),
) -> list[InterventionStrategyResponse]:
    """Get intervention strategies for a given emotion."""
    strategies = get_strategies_for_emotion(emotion, max_results=max_results)
    return [
        InterventionStrategyResponse(
            id=s.id,
            name=s.name,
            category=s.category,
            description=s.description,
            instructions=s.instructions,
            duration_minutes=s.duration_minutes,
        )
        for s in strategies
    ]


@router.post("/gratitude", response_model=GratitudeEntryResponse)
async def create_gratitude_entry(
    body: GratitudeCreateRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> GratitudeEntryResponse:
    """Create a gratitude journal entry."""
    service = EmotionalService(db)
    entry = await service.create_gratitude_entry(uuid.UUID(user_id), body.content)
    return GratitudeEntryResponse.model_validate(entry)


@router.get("/gratitude", response_model=list[GratitudeEntryResponse])
async def get_gratitude_entries(
    limit: int = Query(default=20, le=100),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[GratitudeEntryResponse]:
    """Get current user's gratitude journal entries."""
    service = EmotionalService(db)
    entries = await service.get_gratitude_entries(uuid.UUID(user_id), limit=limit)
    return [GratitudeEntryResponse.model_validate(e) for e in entries]


# ── Admin Alert Management ──


@router.get("/alerts", response_model=list[CrisisAlertResponse])
async def get_active_alerts(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[CrisisAlertResponse]:
    """Get active crisis alerts (teacher/counselor view)."""
    service = EmotionalService(db)
    alerts = await service.get_active_alerts()
    return [CrisisAlertResponse.model_validate(a) for a in alerts]


@router.put("/alerts/{alert_id}/acknowledge", response_model=CrisisAlertResponse)
async def acknowledge_alert(
    alert_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> CrisisAlertResponse:
    """Acknowledge a crisis alert."""
    service = EmotionalService(db)
    alert = await service.acknowledge_alert(alert_id, uuid.UUID(user_id))
    if not alert:
        raise NotFoundError("Alert not found")
    return CrisisAlertResponse.model_validate(alert)


@router.put("/alerts/{alert_id}/resolve", response_model=CrisisAlertResponse)
async def resolve_alert(
    alert_id: uuid.UUID,
    body: AlertActionRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> CrisisAlertResponse:
    """Resolve a crisis alert with optional notes."""
    service = EmotionalService(db)
    alert = await service.resolve_alert(
        alert_id, uuid.UUID(user_id), notes=body.notes,
    )
    if not alert:
        raise NotFoundError("Alert not found")
    return CrisisAlertResponse.model_validate(alert)
