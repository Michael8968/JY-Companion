"""Academic service — error diagnosis, exercise recommendation, learning records."""

import uuid

import structlog
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.learning import (
    Difficulty,
    ErrorRecord,
    ErrorType,
    LearningRecord,
    MasteryStatus,
    Subject,
)
from app.services.llm_client import LLMClient
from app.services.prompt_templates.academic import build_error_diagnosis_messages

logger = structlog.get_logger()


class AcademicService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.llm = LLMClient()

    # ---- Learning Records ----

    async def create_learning_record(
        self,
        user_id: uuid.UUID,
        subject: Subject,
        question: str,
        *,
        conversation_id: uuid.UUID | None = None,
        answer: str | None = None,
        knowledge_points: dict | None = None,
        difficulty: Difficulty = Difficulty.MEDIUM,
        is_correct: bool | None = None,
        time_spent_seconds: int | None = None,
    ) -> LearningRecord:
        record = LearningRecord(
            user_id=user_id,
            conversation_id=conversation_id,
            subject=subject,
            question=question,
            answer=answer,
            knowledge_points=knowledge_points,
            difficulty=difficulty,
            is_correct=is_correct,
            time_spent_seconds=time_spent_seconds,
        )
        self.db.add(record)
        await self.db.flush()
        return record

    async def get_learning_records(
        self, user_id: uuid.UUID, *, subject: Subject | None = None, page: int = 1, size: int = 20
    ) -> tuple[list[LearningRecord], int]:
        base = select(LearningRecord).where(LearningRecord.user_id == user_id)
        if subject:
            base = base.where(LearningRecord.subject == subject)

        count_q = select(func.count()).select_from(base.subquery())
        total = (await self.db.execute(count_q)).scalar() or 0

        q = base.order_by(LearningRecord.created_at.desc()).offset((page - 1) * size).limit(size)
        rows = (await self.db.execute(q)).scalars().all()
        return list(rows), total

    # ---- Error Diagnosis ----

    async def diagnose_error(
        self,
        user_id: uuid.UUID,
        learning_record_id: uuid.UUID,
        subject: Subject,
        question: str,
        wrong_answer: str,
    ) -> ErrorRecord:
        """Use LLM to diagnose error type and analysis, then save error record."""
        # Build diagnosis prompt
        messages = build_error_diagnosis_messages(subject.value, question, wrong_answer)

        # Get LLM diagnosis
        error_type = ErrorType.CONCEPT_MISUNDERSTANDING
        error_analysis = ""
        try:
            result = await self.llm.generate(messages, temperature=0.3)
            analysis_text = result["content"]
            error_analysis = analysis_text

            # Parse error type from LLM response
            if "计算疏忽" in analysis_text:
                error_type = ErrorType.CALCULATION_ERROR
            elif "审题失误" in analysis_text:
                error_type = ErrorType.MISREAD_QUESTION
            elif "思路偏差" in analysis_text:
                error_type = ErrorType.WRONG_APPROACH
            else:
                error_type = ErrorType.CONCEPT_MISUNDERSTANDING
        except Exception:
            await logger.aexception("academic.diagnosis_failed")
            error_analysis = "诊断服务暂时不可用"

        record = ErrorRecord(
            learning_record_id=learning_record_id,
            user_id=user_id,
            subject=subject,
            question=question,
            wrong_answer=wrong_answer,
            error_type=error_type,
            error_analysis=error_analysis,
            mastery_status=MasteryStatus.WEAK,
        )
        self.db.add(record)
        await self.db.flush()
        return record

    # ---- Error Book ----

    async def get_error_book(
        self, user_id: uuid.UUID, *, subject: Subject | None = None, page: int = 1, size: int = 20
    ) -> tuple[list[ErrorRecord], int]:
        base = select(ErrorRecord).where(ErrorRecord.user_id == user_id)
        if subject:
            base = base.where(ErrorRecord.subject == subject)

        count_q = select(func.count()).select_from(base.subquery())
        total = (await self.db.execute(count_q)).scalar() or 0

        q = base.order_by(ErrorRecord.created_at.desc()).offset((page - 1) * size).limit(size)
        rows = (await self.db.execute(q)).scalars().all()
        return list(rows), total

    async def update_mastery(self, error_id: uuid.UUID, user_id: uuid.UUID) -> ErrorRecord | None:
        """Update mastery status after a review. weak → improving → mastered."""
        result = await self.db.execute(
            select(ErrorRecord).where(ErrorRecord.id == error_id, ErrorRecord.user_id == user_id)
        )
        record = result.scalar_one_or_none()
        if not record:
            return None

        record.review_count += 1

        if record.review_count >= 3:
            record.mastery_status = MasteryStatus.MASTERED
        elif record.review_count >= 1:
            record.mastery_status = MasteryStatus.IMPROVING

        await self.db.flush()
        return record

    # ---- Exercise Recommendation ----

    async def recommend_exercises(
        self,
        subject: Subject,
        knowledge_points: list[str],
        mastery_level: MasteryStatus = MasteryStatus.WEAK,
    ) -> str:
        """Use LLM to generate recommended exercises based on weak points."""
        from app.services.prompt_templates.academic import EXERCISE_RECOMMENDATION_PROMPT, SUBJECT_PROMPTS

        system_prompt = SUBJECT_PROMPTS.get(subject.value, "")
        rec_prompt = EXERCISE_RECOMMENDATION_PROMPT.format(mastery_level=mastery_level.value)

        messages = [
            {"role": "system", "content": f"{system_prompt}\n\n{rec_prompt}"},
            {
                "role": "user",
                "content": f"知识薄弱点: {', '.join(knowledge_points)}\n请推荐3-5道变式练习题。",
            },
        ]

        try:
            result = await self.llm.generate(messages, temperature=0.5)
            return result["content"]
        except Exception:
            await logger.aexception("academic.recommendation_failed")
            return "练习推荐服务暂时不可用，请稍后重试。"
