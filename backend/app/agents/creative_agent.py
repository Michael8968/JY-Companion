"""Creative writing agent — AIGC text generation, writing assistance, work evaluation."""

import structlog

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.models.conversation import AgentType
from app.services.llm_client import LLMClient
from app.services.prompt_manager import PromptManager

logger = structlog.get_logger()

CREATIVE_SYSTEM_PROMPT = (
    "\n\n--- 创意创作专项指引 ---\n"
    "1. 激发学生的创作灵感，鼓励原创思维。\n"
    "2. 提供多种创作方向和思路，而不是给出唯一答案。\n"
    "3. 给予建设性的创作反馈，肯定优点的同时指出改进方向。\n"
    "4. 写作辅助时，提供修辞推荐、情节结构优化建议。\n"
    "5. 当学生遇到创作瓶颈时，通过提问引导、头脑风暴激发思路。\n"
    "6. 作品评价从叙事完整性、语言表达、情感深度、结构逻辑、创意独特性等维度分析。\n"
    "--- 指引结束 ---"
)


class CreativeAgent(BaseAgent):
    """Creative writing agent for AIGC text generation and writing assistance."""

    def __init__(self) -> None:
        self._llm = LLMClient()
        self._prompt_manager = PromptManager()

    async def process(self, context: AgentContext) -> AgentResponse:
        user_input = context.user_input
        if context.rag_context:
            user_input = f"{context.rag_context}\n\n用户消息: {user_input}"

        messages = self._prompt_manager.build_messages(
            AgentType.CREATIVE,
            context.history,
            user_input,
            persona=context.persona,
        )
        messages[0]["content"] += CREATIVE_SYSTEM_PROMPT

        try:
            result = await self._llm.generate(messages)
            content = result["content"]
        except Exception:
            await logger.aexception("creative_agent.llm_failed")
            content = "抱歉，创意创作服务暂时不可用，请稍后重试。"

        return AgentResponse(
            content=content,
            agent_type=AgentType.CREATIVE,
        )

    def get_capabilities(self) -> list[str]:
        return [
            "creative_writing",
            "story_generation",
            "writing_optimization",
            "work_evaluation",
            "inspiration_brainstorm",
        ]

    def get_agent_type(self) -> AgentType:
        return AgentType.CREATIVE
