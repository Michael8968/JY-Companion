"""Academic tutoring agent — multi-subject Q&A with CoT reasoning."""

import structlog

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.models.conversation import AgentType
from app.services.llm_client import LLMClient
from app.services.prompt_templates.academic import build_cot_messages

logger = structlog.get_logger()

# Subject detection keywords
_SUBJECT_KEYWORDS: dict[str, list[str]] = {
    "math": ["方程", "函数", "几何", "概率", "数列", "不等式", "向量", "矩阵", "最值", "导数", "积分"],
    "physics": ["力", "电磁", "光", "热", "牛顿", "动量", "能量", "电路", "磁场", "加速度", "速度"],
    "chemistry": ["化学", "反应", "元素", "摩尔", "氧化", "有机", "无机", "酸碱", "化合物", "离子"],
    "chinese": ["作文", "古诗", "文言文", "阅读", "修辞", "诗词", "散文", "议论文", "记叙文"],
    "english": ["英语", "grammar", "vocabulary", "English", "语法", "翻译", "写作", "阅读理解"],
}


def _detect_subject(text: str) -> str:
    """Detect subject from input text based on keywords."""
    scores: dict[str, int] = {}
    for subject, keywords in _SUBJECT_KEYWORDS.items():
        score = sum(1 for kw in keywords if kw in text)
        if score > 0:
            scores[subject] = score

    if not scores:
        return "math"  # default to math
    return max(scores, key=scores.get)


class AcademicAgent(BaseAgent):
    """Academic tutoring agent with CoT-based reasoning.

    Handles multi-subject Q&A (math, physics, chemistry, chinese, english).
    Uses CoT prompts to guide students through problem-solving steps.
    """

    def __init__(self) -> None:
        self._llm = LLMClient()

    async def process(self, context: AgentContext) -> AgentResponse:
        # Detect subject from user input
        subject = _detect_subject(context.user_input)

        # Build CoT messages with RAG context
        messages = build_cot_messages(
            subject=subject,
            user_input=context.user_input,
            history=context.history,
            rag_context=context.rag_context,
        )

        try:
            result = await self._llm.generate(messages)
            content = result["content"]
        except Exception:
            await logger.aexception("academic_agent.llm_failed")
            content = "抱歉，学业辅导服务暂时不可用，请稍后重试。"

        return AgentResponse(
            content=content,
            agent_type=AgentType.ACADEMIC,
            metadata={"subject": subject},
        )

    def get_capabilities(self) -> list[str]:
        return [
            "academic_math_question",
            "academic_physics_question",
            "academic_chemistry_question",
            "academic_chinese_question",
            "academic_english_question",
            "error_diagnosis",
            "exercise_recommendation",
        ]

    def get_agent_type(self) -> AgentType:
        return AgentType.ACADEMIC
