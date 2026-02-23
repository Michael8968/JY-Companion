"""Health guardian agent — screen time monitoring, exercise plans, break reminders."""

import structlog

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.models.conversation import AgentType
from app.services.llm_client import LLMClient
from app.services.prompt_manager import PromptManager

logger = structlog.get_logger()

# Health-specific prompt enhancement
HEALTH_SYSTEM_PROMPT = (
    "\n\n--- 健康守护专项指引 ---\n"
    "1. 关注学生的用眼健康、坐姿和运动习惯。\n"
    "2. 每隔一段时间温和地提醒学生休息和活动。\n"
    "3. 推荐适合课间进行的微运动（拉伸、眼保健操等）。\n"
    "4. 不要过度干预，保持温和鼓励的语气。\n"
    "5. 根据时间段调整提醒内容（上午/下午/晚间）。\n"
    "--- 指引结束 ---"
)


class HealthAgent(BaseAgent):
    """Health guardian agent for screen time, exercise, and break reminders."""

    def __init__(self) -> None:
        self._llm = LLMClient()
        self._prompt_manager = PromptManager()

    async def process(self, context: AgentContext) -> AgentResponse:
        user_input = context.user_input
        if context.rag_context:
            user_input = f"{context.rag_context}\n\n用户消息: {user_input}"

        messages = self._prompt_manager.build_messages(
            AgentType.HEALTH,
            context.history,
            user_input,
            persona=context.persona,
        )
        messages[0]["content"] += HEALTH_SYSTEM_PROMPT

        try:
            result = await self._llm.generate(messages)
            content = result["content"]
        except Exception:
            await logger.aexception("health_agent.llm_failed")
            content = (
                "我暂时无法完整回应，但温馨提醒你：如果已经学习超过40分钟，"
                "请站起来活动一下，做几次深呼吸，让眼睛远眺窗外。"
            )

        return AgentResponse(
            content=content,
            agent_type=AgentType.HEALTH,
        )

    def get_capabilities(self) -> list[str]:
        return [
            "screen_time_monitoring",
            "break_reminder",
            "exercise_plan",
            "posture_check",
            "eye_health",
        ]

    def get_agent_type(self) -> AgentType:
        return AgentType.HEALTH
