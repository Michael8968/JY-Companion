"""Career planning agent — SMART goals, learning paths, progress tracking."""

import structlog

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.models.conversation import AgentType
from app.services.llm_client import LLMClient
from app.services.prompt_manager import PromptManager

logger = structlog.get_logger()

CAREER_SYSTEM_PROMPT = (
    "\n\n--- 生涯规划专项指引 ---\n"
    "1. 帮助学生按 SMART 原则设定目标（具体、可衡量、可达成、相关、有时限）。\n"
    "2. 将大目标拆解为月度、周度、每日可执行的子任务。\n"
    "3. 基于学生兴趣和能力推荐课程、书籍、实践项目等学习资源。\n"
    "4. 提供进度复盘和偏差分析，帮助学生调整计划。\n"
    "5. 鼓励学生探索多元兴趣，不要过早锁定方向。\n"
    "6. 用数据和可视化帮助学生理解自己的进步。\n"
    "--- 指引结束 ---"
)


class CareerAgent(BaseAgent):
    """Career planning agent for goal management and learning path recommendations."""

    def __init__(self) -> None:
        self._llm = LLMClient()
        self._prompt_manager = PromptManager()

    async def process(self, context: AgentContext) -> AgentResponse:
        user_input = context.user_input
        if context.rag_context:
            user_input = f"{context.rag_context}\n\n用户消息: {user_input}"

        messages = self._prompt_manager.build_messages(
            AgentType.CAREER,
            context.history,
            user_input,
            persona=context.persona,
        )
        messages[0]["content"] += CAREER_SYSTEM_PROMPT

        try:
            result = await self._llm.generate(messages)
            content = result["content"]
        except Exception:
            await logger.aexception("career_agent.llm_failed")
            content = "抱歉，生涯规划服务暂时不可用，请稍后重试。"

        return AgentResponse(
            content=content,
            agent_type=AgentType.CAREER,
        )

    def get_capabilities(self) -> list[str]:
        return [
            "smart_goal_management",
            "learning_path_recommendation",
            "progress_tracking",
            "weekly_report",
            "interest_exploration",
        ]

    def get_agent_type(self) -> AgentType:
        return AgentType.CAREER
