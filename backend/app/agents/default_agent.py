"""Default agent — fallback LLM agent used when no specialized agent is registered."""

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.models.conversation import AgentType
from app.services.llm_client import LLMClient
from app.services.prompt_manager import PromptManager


class DefaultAgent(BaseAgent):
    """Generic LLM-powered agent that handles any agent type.

    Used as fallback when specialized agents (academic, emotional, etc.)
    are not yet registered. Delegates to the LLM with appropriate prompts.
    """

    def __init__(self, agent_type: AgentType) -> None:
        self._agent_type = agent_type
        self._llm = LLMClient()
        self._prompt_manager = PromptManager()

    async def process(self, context: AgentContext) -> AgentResponse:
        # Build messages with RAG context if available
        user_input = context.user_input
        if context.rag_context:
            user_input = f"{context.rag_context}\n\n用户问题: {user_input}"

        messages = self._prompt_manager.build_messages(
            context.agent_type,
            context.history,
            user_input,
            persona=context.persona,
        )

        try:
            result = await self._llm.generate(messages)
            content = result["content"]
        except Exception:
            content = "抱歉，AI 服务暂时不可用，请稍后重试。"

        return AgentResponse(
            content=content,
            agent_type=context.agent_type,
        )

    def get_capabilities(self) -> list[str]:
        return ["general_conversation", f"{self._agent_type.value}_support"]

    def get_agent_type(self) -> AgentType:
        return self._agent_type
