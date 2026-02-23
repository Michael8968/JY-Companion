"""Classroom review agent — structured summaries, study plans, doubt resolution."""

import structlog

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.models.conversation import AgentType
from app.services.llm_client import LLMClient
from app.services.prompt_manager import PromptManager

logger = structlog.get_logger()


class ClassroomAgent(BaseAgent):
    """Classroom review agent for note-taking, summarization, and study planning."""

    def __init__(self) -> None:
        self._llm = LLMClient()
        self._prompt_manager = PromptManager()

    async def process(self, context: AgentContext) -> AgentResponse:
        user_input = context.user_input
        if context.rag_context:
            user_input = f"{context.rag_context}\n\n用户问题: {user_input}"

        messages = self._prompt_manager.build_messages(
            AgentType.CLASSROOM,
            context.history,
            user_input,
            persona=context.persona,
        )

        try:
            result = await self._llm.generate(messages)
            content = result["content"]
        except Exception:
            await logger.aexception("classroom_agent.llm_failed")
            content = "抱歉，课堂复盘服务暂时不可用，请稍后重试。"

        return AgentResponse(
            content=content,
            agent_type=AgentType.CLASSROOM,
        )

    def get_capabilities(self) -> list[str]:
        return [
            "classroom_review",
            "note_summarization",
            "study_plan_generation",
            "doubt_resolution",
        ]

    def get_agent_type(self) -> AgentType:
        return AgentType.CLASSROOM
