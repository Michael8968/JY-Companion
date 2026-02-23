"""Emotional companion service — emotion recording, crisis flow, gratitude journal."""

import time
import uuid

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.emotion import (
    AlertStatus,
    CrisisAlert,
    EmotionRecord,
    EmotionSource,
    GratitudeEntry,
)
from app.services.crisis_alert import (
    check_crisis_keywords,
    create_crisis_alert,
)
from app.services.emotion_detector import EmotionDetector

logger = structlog.get_logger()


class EmotionalService:
    """Service layer for emotion recording, crisis alert flow, and gratitude journal."""

    def __init__(self, db: AsyncSession) -> None:
        self._db = db
        self._detector = EmotionDetector()

    # ── Emotion Recording ──

    async def record_emotion_from_text(
        self,
        user_id: uuid.UUID,
        text: str,
        conversation_id: uuid.UUID | None = None,
    ) -> EmotionRecord:
        """Detect emotion from text and save an EmotionRecord."""
        result = self._detector.detect_from_text(text)

        record = EmotionRecord(
            user_id=user_id,
            conversation_id=conversation_id,
            emotion_label=result.label,
            valence=result.valence,
            arousal=result.arousal,
            confidence=result.confidence,
            source=EmotionSource.TEXT,
            raw_scores=result.scores,
        )
        self._db.add(record)
        await self._db.flush()

        logger.info(
            "emotion.recorded",
            user_id=str(user_id),
            label=result.label.value,
            valence=result.valence,
            confidence=result.confidence,
        )
        return record

    async def get_emotion_history(
        self,
        user_id: uuid.UUID,
        limit: int = 20,
    ) -> list[EmotionRecord]:
        """Get recent emotion records for a user."""
        stmt = (
            select(EmotionRecord)
            .where(EmotionRecord.user_id == user_id)
            .order_by(EmotionRecord.created_at.desc())
            .limit(limit)
        )
        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    # ── Crisis Alert Flow ──

    async def check_and_alert(
        self,
        user_id: uuid.UUID,
        text: str,
        conversation_id: uuid.UUID | None = None,
    ) -> CrisisAlert | None:
        """Run crisis keyword check and create alert if triggered.

        Returns the CrisisAlert if crisis detected, None otherwise.
        """
        start_ns = time.time_ns()
        check_result = check_crisis_keywords(text)

        if not check_result.is_crisis:
            return None

        alert = await create_crisis_alert(
            db=self._db,
            user_id=user_id,
            check_result=check_result,
            trigger_content=text,
            conversation_id=conversation_id,
            start_time_ns=start_ns,
        )
        return alert

    async def get_active_alerts(
        self,
        user_id: uuid.UUID | None = None,
    ) -> list[CrisisAlert]:
        """Get active crisis alerts, optionally filtered by user."""
        stmt = select(CrisisAlert).where(
            CrisisAlert.status == AlertStatus.ACTIVE,
        )
        if user_id:
            stmt = stmt.where(CrisisAlert.user_id == user_id)
        stmt = stmt.order_by(CrisisAlert.created_at.desc())

        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    async def acknowledge_alert(
        self,
        alert_id: uuid.UUID,
        by_user_id: uuid.UUID,
    ) -> CrisisAlert | None:
        """Mark a crisis alert as acknowledged."""
        stmt = select(CrisisAlert).where(CrisisAlert.id == alert_id)
        result = await self._db.execute(stmt)
        alert = result.scalar_one_or_none()

        if not alert:
            return None

        alert.status = AlertStatus.ACKNOWLEDGED
        alert.resolved_by = by_user_id
        await self._db.flush()

        logger.info(
            "crisis_alert.acknowledged",
            alert_id=str(alert_id),
            by=str(by_user_id),
        )
        return alert

    async def resolve_alert(
        self,
        alert_id: uuid.UUID,
        by_user_id: uuid.UUID,
        notes: str | None = None,
    ) -> CrisisAlert | None:
        """Mark a crisis alert as resolved with optional notes."""
        stmt = select(CrisisAlert).where(CrisisAlert.id == alert_id)
        result = await self._db.execute(stmt)
        alert = result.scalar_one_or_none()

        if not alert:
            return None

        alert.status = AlertStatus.RESOLVED
        alert.resolved_by = by_user_id
        if notes:
            alert.resolution_notes = notes
        await self._db.flush()

        logger.info(
            "crisis_alert.resolved",
            alert_id=str(alert_id),
            by=str(by_user_id),
        )
        return alert

    # ── Sustained Depression Check ──

    async def check_sustained_depression(
        self,
        user_id: uuid.UUID,
        threshold_valence: float = -0.7,
        min_records: int = 5,
    ) -> bool:
        """Check if user has sustained negative emotion across recent records.

        Returns True if the last `min_records` records all have valence below threshold.
        """
        stmt = (
            select(EmotionRecord)
            .where(EmotionRecord.user_id == user_id)
            .order_by(EmotionRecord.created_at.desc())
            .limit(min_records)
        )
        result = await self._db.execute(stmt)
        records = list(result.scalars().all())

        if len(records) < min_records:
            return False

        return all(r.valence <= threshold_valence for r in records)

    # ── Gratitude Journal ──

    async def create_gratitude_entry(
        self,
        user_id: uuid.UUID,
        content: str,
    ) -> GratitudeEntry:
        """Create a gratitude journal entry."""
        entry = GratitudeEntry(
            user_id=user_id,
            content=content,
        )
        self._db.add(entry)
        await self._db.flush()

        logger.info("gratitude.created", user_id=str(user_id))
        return entry

    async def get_gratitude_entries(
        self,
        user_id: uuid.UUID,
        limit: int = 20,
    ) -> list[GratitudeEntry]:
        """Get recent gratitude entries for a user."""
        stmt = (
            select(GratitudeEntry)
            .where(GratitudeEntry.user_id == user_id)
            .order_by(GratitudeEntry.created_at.desc())
            .limit(limit)
        )
        result = await self._db.execute(stmt)
        return list(result.scalars().all())
