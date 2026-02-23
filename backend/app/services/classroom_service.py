"""Classroom service — transcription, summarization, doubt detection, study plans."""

import uuid

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.classroom import (
    ClassroomDoubt,
    ClassroomSession,
    SessionStatus,
    StudyPlan,
    UserLearningProfile,
)
from app.services.asr_client import ASRClient
from app.services.llm_client import LLMClient

logger = structlog.get_logger()

SUMMARY_SYSTEM_PROMPT = (
    "你是一位教学助手。请根据课堂录音转写文本，生成结构化摘要。\n"
    "输出格式（JSON）：\n"
    '{"outline": [{"title": "章节标题", "points": ["要点1", "要点2"]}],\n'
    ' "concepts": ["核心概念1", "核心概念2"],\n'
    ' "key_points": ["重点1", "重点2"],\n'
    ' "teacher_emphasis": ["教师强调内容1"]}\n'
)

STUDY_PLAN_SYSTEM_PROMPT = (
    "你是一位教学助手。请根据课堂内容和学生画像，生成个性化学案。\n"
    "学案类型: {plan_type}\n"
    "- basic（基础巩固型）：侧重核心知识点巩固和基础练习\n"
    "- advanced（拓展探究型）：包含进阶题目和延伸阅读\n"
    "\n输出包含：复习要点、针对性练习题、拓展阅读建议。"
)


class ClassroomService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.asr = ASRClient()
        self.llm = LLMClient()

    # ---- Session CRUD ----

    async def create_session(
        self,
        user_id: uuid.UUID,
        title: str,
        subject: str,
        audio_url: str | None = None,
        duration_seconds: int | None = None,
    ) -> ClassroomSession:
        session = ClassroomSession(
            user_id=user_id,
            title=title,
            subject=subject,
            audio_url=audio_url,
            duration_seconds=duration_seconds,
        )
        self.db.add(session)
        await self.db.flush()
        return session

    async def get_session(self, session_id: uuid.UUID, user_id: uuid.UUID) -> ClassroomSession | None:
        result = await self.db.execute(
            select(ClassroomSession).where(
                ClassroomSession.id == session_id, ClassroomSession.user_id == user_id
            )
        )
        return result.scalar_one_or_none()

    # ---- Transcription ----

    async def transcribe(self, session_id: uuid.UUID, user_id: uuid.UUID) -> ClassroomSession | None:
        """Trigger ASR transcription for a session."""
        session = await self.get_session(session_id, user_id)
        if not session or not session.audio_url:
            return None

        session.status = SessionStatus.TRANSCRIBING
        await self.db.flush()

        try:
            asr_result = await self.asr.recognize_url(session.audio_url)
            session.transcript = asr_result.text
            session.segments = [
                {"start": s.get("start"), "end": s.get("end"), "text": s.get("text")}
                for s in asr_result.segments
            ]
            session.status = SessionStatus.SUMMARIZING
        except Exception:
            await logger.aexception("classroom.transcription_failed", session_id=str(session_id))
            session.status = SessionStatus.FAILED
            await self.db.flush()
            return session

        await self.db.flush()

        # Auto-generate summary
        await self._generate_summary(session)
        # Auto-detect doubts
        await self._detect_doubts(session)

        session.status = SessionStatus.COMPLETED
        await self.db.flush()
        return session

    # ---- Summary Generation ----

    async def _generate_summary(self, session: ClassroomSession) -> None:
        if not session.transcript:
            return

        messages = [
            {"role": "system", "content": SUMMARY_SYSTEM_PROMPT},
            {"role": "user", "content": f"课堂录音转写文本:\n{session.transcript[:8000]}"},
        ]

        try:
            result = await self.llm.generate(messages, temperature=0.3)
            import orjson

            summary = orjson.loads(result["content"])
            session.summary_outline = summary.get("outline")
            session.summary_concepts = summary.get("concepts")
            session.key_points = summary.get("key_points")
        except Exception:
            await logger.aexception("classroom.summary_failed", session_id=str(session.id))

    # ---- Doubt Detection ----

    async def _detect_doubts(self, session: ClassroomSession) -> None:
        """Detect doubt points from transcript segments."""
        if not session.segments:
            return

        segments = session.segments
        doubts: list[ClassroomDoubt] = []

        for i, seg in enumerate(segments):
            text = seg.get("text", "")
            start = seg.get("start", 0.0)
            end = seg.get("end", 0.0)

            # Heuristic: detect repetition
            if i > 0 and _text_similarity(text, segments[i - 1].get("text", "")) > 0.7:
                doubts.append(ClassroomDoubt(
                    session_id=session.id,
                    timestamp_start=start,
                    timestamp_end=end,
                    text_excerpt=text,
                    doubt_type="repetition",
                    importance=0.7,
                    context="与前一段重复度高",
                ))

            # Heuristic: detect slow pace (short text for long duration)
            duration = end - start
            if duration > 0 and len(text) / duration < 2.0 and duration > 5.0:
                doubts.append(ClassroomDoubt(
                    session_id=session.id,
                    timestamp_start=start,
                    timestamp_end=end,
                    text_excerpt=text,
                    doubt_type="slow_pace",
                    importance=0.6,
                    context=f"语速较慢({len(text)/duration:.1f}字/秒)",
                ))

            # Heuristic: detect student questions
            if "?" in text or "？" in text or "老师" in text:
                doubts.append(ClassroomDoubt(
                    session_id=session.id,
                    timestamp_start=start,
                    timestamp_end=end,
                    text_excerpt=text,
                    doubt_type="student_question",
                    importance=0.8,
                    context="可能包含学生提问",
                ))

        self.db.add_all(doubts)
        await self.db.flush()

    async def get_doubts(self, session_id: uuid.UUID) -> list[ClassroomDoubt]:
        result = await self.db.execute(
            select(ClassroomDoubt)
            .where(ClassroomDoubt.session_id == session_id)
            .order_by(ClassroomDoubt.importance.desc())
        )
        return list(result.scalars().all())

    # ---- Personalized Study Plan ----

    async def generate_study_plan(
        self, session_id: uuid.UUID, user_id: uuid.UUID
    ) -> StudyPlan | None:
        session = await self.get_session(session_id, user_id)
        if not session or not session.transcript:
            return None

        # Get user learning profile
        profile = await self._get_or_create_profile(user_id)
        plan_type = "basic" if profile.learning_level == "basic" else "advanced"

        prompt = STUDY_PLAN_SYSTEM_PROMPT.format(plan_type=plan_type)
        messages = [
            {"role": "system", "content": prompt},
            {
                "role": "user",
                "content": (
                    f"课堂内容: {session.title} ({session.subject})\n"
                    f"核心知识点: {session.key_points}\n"
                    f"学生薄弱科目: {profile.weak_subjects}\n"
                    f"知识掌握度: {profile.knowledge_mastery}\n"
                    f"请生成个性化学案。"
                ),
            },
        ]

        try:
            result = await self.llm.generate(messages, temperature=0.4)
            content = result["content"]
        except Exception:
            await logger.aexception("classroom.study_plan_failed")
            content = "学案生成暂时不可用"

        plan = StudyPlan(
            session_id=session_id,
            user_id=user_id,
            plan_type=plan_type,
            content=content,
        )
        self.db.add(plan)
        await self.db.flush()
        return plan

    # ---- User Learning Profile ----

    async def _get_or_create_profile(self, user_id: uuid.UUID) -> UserLearningProfile:
        result = await self.db.execute(
            select(UserLearningProfile).where(UserLearningProfile.user_id == user_id)
        )
        profile = result.scalar_one_or_none()
        if not profile:
            profile = UserLearningProfile(user_id=user_id)
            self.db.add(profile)
            await self.db.flush()
        return profile

    async def get_learning_profile(self, user_id: uuid.UUID) -> UserLearningProfile:
        return await self._get_or_create_profile(user_id)

    async def update_learning_profile(
        self, user_id: uuid.UUID, **kwargs: dict
    ) -> UserLearningProfile:
        profile = await self._get_or_create_profile(user_id)
        for key, value in kwargs.items():
            if hasattr(profile, key):
                setattr(profile, key, value)
        await self.db.flush()
        return profile


def _text_similarity(a: str, b: str) -> float:
    """Simple character-level Jaccard similarity."""
    if not a or not b:
        return 0.0
    set_a = set(a)
    set_b = set(b)
    intersection = set_a & set_b
    union = set_a | set_b
    return len(intersection) / len(union) if union else 0.0
