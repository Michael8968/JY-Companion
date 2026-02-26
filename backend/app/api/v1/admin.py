"""Admin management API — user management, statistics, content audit, alerts."""

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_db_session, require_role
from app.core.exceptions import NotFoundError
from app.models.conversation import Conversation, Message
from app.models.emotion import AlertStatus, CrisisAlert
from app.models.user import User
from app.schemas.admin import (
    CrisisAlertListResponse,
    CrisisAlertSummary,
    PlatformStatsResponse,
    UpdateUserStatusRequest,
    UserListResponse,
    UserSummary,
)
from app.services.data_masking import DataMaskingEngine

router = APIRouter(prefix="/admin", tags=["admin"])

_masker = DataMaskingEngine()


# ── User Management ────────────────────────────────────────────


@router.get("/users", response_model=UserListResponse)
async def list_users(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    role: str | None = None,
    _admin: str = Depends(require_role("admin")),
    db: AsyncSession = Depends(get_db_session),
) -> UserListResponse:
    """List all users with pagination (admin only)."""
    stmt = select(User)
    count_stmt = select(func.count()).select_from(User)

    if role:
        stmt = stmt.where(User.role == role)
        count_stmt = count_stmt.where(User.role == role)

    total = (await db.execute(count_stmt)).scalar() or 0

    stmt = stmt.order_by(User.created_at.desc()).offset((page - 1) * size).limit(size)
    result = await db.execute(stmt)
    users = list(result.scalars().all())

    return UserListResponse(
        users=[UserSummary.model_validate(u) for u in users],
        total=total,
        page=page,
        size=size,
    )


@router.put("/users/{user_id}/status")
async def update_user_status(
    user_id: uuid.UUID,
    body: UpdateUserStatusRequest,
    _admin: str = Depends(require_role("admin")),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """Activate or deactivate a user account (admin only)."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise NotFoundError("User not found")

    user.is_active = body.is_active
    await db.flush()
    return {"status": "updated", "user_id": str(user_id), "is_active": body.is_active}


# ── Platform Statistics ────────────────────────────────────────


@router.get("/stats", response_model=PlatformStatsResponse)
async def get_platform_stats(
    _admin: str = Depends(require_role("admin")),
    db: AsyncSession = Depends(get_db_session),
) -> PlatformStatsResponse:
    """Get platform-wide statistics (admin only)."""
    total_users = (await db.execute(select(func.count()).select_from(User))).scalar() or 0
    total_convs = (await db.execute(select(func.count()).select_from(Conversation))).scalar() or 0
    total_msgs = (await db.execute(select(func.count()).select_from(Message))).scalar() or 0

    # Active crisis alerts
    active_alerts = (
        await db.execute(
            select(func.count())
            .select_from(CrisisAlert)
            .where(CrisisAlert.status == AlertStatus.ACTIVE)
        )
    ).scalar() or 0

    # Count users who logged in today
    today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    active_today = (
        await db.execute(
            select(func.count())
            .select_from(User)
            .where(User.last_login_at >= today_start)
        )
    ).scalar() or 0

    return PlatformStatsResponse(
        total_users=total_users,
        active_users_today=active_today,
        total_conversations=total_convs,
        total_messages=total_msgs,
        active_crisis_alerts=active_alerts,
    )


# ── Crisis Alert Management ───────────────────────────────────


@router.get("/alerts", response_model=CrisisAlertListResponse)
async def list_crisis_alerts(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: str | None = None,
    _admin: str = Depends(require_role("admin", "teacher")),
    db: AsyncSession = Depends(get_db_session),
) -> CrisisAlertListResponse:
    """List crisis alerts with pagination (admin/teacher only)."""
    stmt = select(CrisisAlert)
    count_stmt = select(func.count()).select_from(CrisisAlert)

    if status:
        stmt = stmt.where(CrisisAlert.status == status)
        count_stmt = count_stmt.where(CrisisAlert.status == status)

    total = (await db.execute(count_stmt)).scalar() or 0

    stmt = stmt.order_by(CrisisAlert.created_at.desc()).offset((page - 1) * size).limit(size)
    result = await db.execute(stmt)
    alerts = list(result.scalars().all())

    return CrisisAlertListResponse(
        alerts=[
            CrisisAlertSummary(
                id=a.id,
                user_id=a.user_id,
                alert_level=a.alert_level,
                status=a.status,
                trigger_type=a.trigger_type,
                trigger_content=_masker.truncate(a.trigger_content, 50),
                created_at=a.created_at,
            )
            for a in alerts
        ],
        total=total,
        page=page,
        size=size,
    )


@router.put("/alerts/{alert_id}/resolve")
async def resolve_alert(
    alert_id: uuid.UUID,
    notes: str | None = None,
    _admin: str = Depends(require_role("admin", "teacher")),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """Resolve a crisis alert (admin/teacher only)."""
    result = await db.execute(select(CrisisAlert).where(CrisisAlert.id == alert_id))
    alert = result.scalar_one_or_none()
    if not alert:
        raise NotFoundError("Alert not found")

    alert.status = AlertStatus.RESOLVED
    if notes:
        alert.resolution_notes = notes
    await db.flush()
    return {"status": "resolved", "alert_id": str(alert_id)}
