"""Career planning service — SMART goals, learning paths, progress reports."""

import uuid

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.career import (
    Goal,
    GoalPriority,
    GoalStatus,
    LearningPath,
    ProgressReport,
)
from app.services.llm_client import LLMClient

logger = structlog.get_logger()

GOAL_DECOMPOSE_PROMPT = (
    "你是一位生涯规划顾问。请帮助学生将以下目标按照 SMART 原则进行拆解：\n"
    "S-具体(Specific): 目标具体是什么？\n"
    "M-可衡量(Measurable): 如何衡量是否达成？\n"
    "A-可达成(Achievable): 需要哪些具体行动？\n"
    "R-相关(Relevant): 与长期发展的关系？\n"
    "T-有时限(Time-bound): 截止日期是什么？\n\n"
    "请将目标拆解为 3 层子任务：月度计划 → 周计划 → 每日任务。\n"
    "以 JSON 格式返回。"
)

LEARNING_PATH_PROMPT = (
    "你是一位教育规划专家。请根据学生的兴趣和目标，推荐一条学习路径。\n"
    "包含：推荐书籍、在线课程、实践项目。\n"
    "按照从易到难的顺序排列，每个阶段都说明预期收获。"
)

PROGRESS_REPORT_PROMPT = (
    "你是一位学习分析师。请根据学生的目标进度数据生成周报告：\n"
    "1. 本周完成情况总结\n"
    "2. 完成率统计\n"
    "3. 偏差分析（哪些目标滞后？原因可能是什么？）\n"
    "4. 时间管理建议\n"
    "5. 下周重点任务推荐"
)


class CareerService:
    """Service for career planning, goal management, and progress tracking."""

    def __init__(self, db: AsyncSession) -> None:
        self._db = db
        self._llm = LLMClient()

    # ── Goals ──

    async def create_goal(
        self,
        user_id: uuid.UUID,
        title: str,
        description: str | None = None,
        parent_id: uuid.UUID | None = None,
        priority: GoalPriority = GoalPriority.MEDIUM,
        deadline: str | None = None,
        estimated_hours: float | None = None,
    ) -> Goal:
        """Create a SMART goal."""
        level = 0
        if parent_id:
            parent_stmt = select(Goal).where(Goal.id == parent_id)
            parent_result = await self._db.execute(parent_stmt)
            parent = parent_result.scalar_one_or_none()
            if parent:
                level = parent.level + 1

        goal = Goal(
            user_id=user_id,
            parent_id=parent_id,
            title=title,
            description=description,
            priority=priority,
            deadline=deadline,
            estimated_hours=estimated_hours,
            level=level,
        )
        self._db.add(goal)
        await self._db.flush()

        logger.info("career.goal_created", user_id=str(user_id), goal_id=str(goal.id), level=level)
        return goal

    async def get_goals(
        self,
        user_id: uuid.UUID,
        status: GoalStatus | None = None,
    ) -> list[Goal]:
        """Get user's goals, optionally filtered by status."""
        stmt = select(Goal).where(Goal.user_id == user_id)
        if status:
            stmt = stmt.where(Goal.status == status)
        stmt = stmt.order_by(Goal.level, Goal.created_at.desc())

        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    async def update_goal_progress(
        self,
        goal_id: uuid.UUID,
        user_id: uuid.UUID,
        progress_percent: float | None = None,
        status: GoalStatus | None = None,
    ) -> Goal | None:
        """Update goal progress and cascade to parent."""
        stmt = select(Goal).where(Goal.id == goal_id, Goal.user_id == user_id)
        result = await self._db.execute(stmt)
        goal = result.scalar_one_or_none()

        if not goal:
            return None

        if progress_percent is not None:
            goal.progress_percent = min(max(progress_percent, 0.0), 100.0)
        if status:
            goal.status = status
        if goal.progress_percent >= 100.0:
            goal.status = GoalStatus.COMPLETED

        # Cascade: update parent progress
        if goal.parent_id:
            await self._update_parent_progress(goal.parent_id, user_id)

        await self._db.flush()
        return goal

    async def _update_parent_progress(
        self, parent_id: uuid.UUID, user_id: uuid.UUID,
    ) -> None:
        """Recalculate parent goal progress from children."""
        children_stmt = select(Goal).where(
            Goal.parent_id == parent_id, Goal.user_id == user_id,
        )
        result = await self._db.execute(children_stmt)
        children = list(result.scalars().all())

        if not children:
            return

        avg_progress = sum(c.progress_percent for c in children) / len(children)

        parent_stmt = select(Goal).where(Goal.id == parent_id)
        parent_result = await self._db.execute(parent_stmt)
        parent = parent_result.scalar_one_or_none()
        if parent:
            parent.progress_percent = avg_progress

    async def decompose_goal_with_llm(
        self,
        goal_id: uuid.UUID,
        user_id: uuid.UUID,
    ) -> dict:
        """Use LLM to decompose a goal into SMART sub-tasks."""
        stmt = select(Goal).where(Goal.id == goal_id, Goal.user_id == user_id)
        result = await self._db.execute(stmt)
        goal = result.scalar_one_or_none()

        if not goal:
            return {"error": "Goal not found"}

        messages = [
            {"role": "system", "content": GOAL_DECOMPOSE_PROMPT},
            {"role": "user", "content": f"目标：{goal.title}\n说明：{goal.description or '无'}"},
        ]

        try:
            llm_result = await self._llm.generate(messages)
            goal.smart_criteria = {"llm_analysis": llm_result["content"]}
            await self._db.flush()
            return {"decomposition": llm_result["content"], "goal_id": str(goal_id)}
        except Exception:
            await logger.aexception("career.decompose_failed")
            return {"error": "目标拆解服务暂时不可用"}

    # ── Learning Paths ──

    async def get_learning_path(
        self,
        user_id: uuid.UUID,
    ) -> list[LearningPath]:
        """Get user's learning paths."""
        stmt = (
            select(LearningPath)
            .where(LearningPath.user_id == user_id)
            .order_by(LearningPath.created_at.desc())
        )
        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    async def generate_learning_path(
        self,
        user_id: uuid.UUID,
        interests: list[str],
        goal_description: str,
    ) -> LearningPath:
        """Generate a personalized learning path using LLM."""
        messages = [
            {"role": "system", "content": LEARNING_PATH_PROMPT},
            {"role": "user", "content": f"兴趣方向：{', '.join(interests)}\n目标：{goal_description}"},
        ]

        content = "学习路径生成中..."
        try:
            result = await self._llm.generate(messages)
            content = result["content"]
        except Exception:
            await logger.aexception("career.learning_path_failed")

        path = LearningPath(
            user_id=user_id,
            title=f"基于{interests[0]}的学习路径" if interests else "个性化学习路径",
            description=content,
            interest_tags=interests,
            total_stages=3,
        )
        self._db.add(path)
        await self._db.flush()
        return path

    # ── Progress Reports ──

    async def get_progress_reports(
        self,
        user_id: uuid.UUID,
    ) -> list[ProgressReport]:
        """Get user's progress reports ordered by most recent."""
        stmt = (
            select(ProgressReport)
            .where(ProgressReport.user_id == user_id)
            .order_by(ProgressReport.created_at.desc())
        )
        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    async def generate_progress_report(
        self,
        user_id: uuid.UUID,
        period_start: str,
        period_end: str,
    ) -> ProgressReport:
        """Generate a weekly progress report."""
        goals = await self.get_goals(user_id, status=GoalStatus.ACTIVE)
        goals_summary = "\n".join(
            f"- {g.title}: {g.progress_percent:.0f}%完成"
            for g in goals[:10]
        )

        messages = [
            {"role": "system", "content": PROGRESS_REPORT_PROMPT},
            {"role": "user", "content": f"报告周期：{period_start} ~ {period_end}\n\n目标进度：\n{goals_summary}"},
        ]

        content = "报告生成中..."
        completion_stats = {
            "total_goals": len(goals),
            "avg_progress": sum(g.progress_percent for g in goals) / max(len(goals), 1),
        }

        try:
            result = await self._llm.generate(messages)
            content = result["content"]
        except Exception:
            await logger.aexception("career.report_failed")

        report = ProgressReport(
            user_id=user_id,
            period_start=period_start,
            period_end=period_end,
            completion_stats=completion_stats,
            content=content,
        )
        self._db.add(report)
        await self._db.flush()
        return report
