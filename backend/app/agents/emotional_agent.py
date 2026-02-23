"""Emotional companion agent — empathetic dialogue with crisis-aware safety."""

import structlog

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.models.conversation import AgentType
from app.services.crisis_alert import CRISIS_RESPONSES, check_crisis_keywords
from app.services.emotion_detector import EmotionDetector
from app.services.intervention_strategies import get_strategies_for_emotion
from app.services.llm_client import LLMClient
from app.services.prompt_manager import PromptManager

logger = structlog.get_logger()

# Empathetic system prompt extension
EMPATHY_SYSTEM_PROMPT = (
    "\n\n--- 情感陪伴专项指引 ---\n"
    "1. 始终以接纳、不评判的态度回应学生的感受。\n"
    "2. 使用「我听到你说……」「你的感受是可以理解的」等共情表达。\n"
    "3. 多用开放式问题引导学生表达，如「你愿意多说说吗？」。\n"
    "4. 适时推荐具体的心理调节技巧（呼吸练习、正念练习等）。\n"
    "5. 不要给出简单的建议或说教，而是陪伴学生探索自己的感受。\n"
    "6. 如果学生持续低落，温柔地建议寻求学校心理咨询师的帮助。\n"
    "--- 指引结束 ---"
)


class EmotionalAgent(BaseAgent):
    """Emotional companion agent with empathetic dialogue and crisis detection."""

    def __init__(self) -> None:
        self._llm = LLMClient()
        self._prompt_manager = PromptManager()
        self._detector = EmotionDetector()

    async def process(self, context: AgentContext) -> AgentResponse:
        user_input = context.user_input

        # Step 1: Crisis keyword pre-check (synchronous, <100ms)
        crisis_result = check_crisis_keywords(user_input)
        if crisis_result.is_crisis:
            logger.warning(
                "emotional_agent.crisis_detected",
                user_id=context.user_id,
                level=crisis_result.alert_level,
                keywords=crisis_result.matched_keywords,
            )
            safe_response = CRISIS_RESPONSES.get(
                crisis_result.alert_level,
                CRISIS_RESPONSES[list(CRISIS_RESPONSES.keys())[0]],
            )
            return AgentResponse(
                content=safe_response,
                agent_type=AgentType.EMOTIONAL,
                emotion_label="crisis",
                metadata={
                    "crisis": True,
                    "alert_level": crisis_result.alert_level,
                    "matched_keywords": crisis_result.matched_keywords,
                },
            )

        # Step 2: Detect emotion from text
        emotion_result = self._detector.detect_from_text(user_input)

        # Step 3: Build context-enriched prompt
        enriched_input = user_input
        if context.rag_context:
            enriched_input = f"{context.rag_context}\n\n用户消息: {user_input}"

        # Add detected emotion context for the LLM
        emotion_hint = (
            f"\n\n[系统提示：检测到学生当前情绪为「{emotion_result.label.value}」，"
            f"情感效价={emotion_result.valence:.2f}，唤醒度={emotion_result.arousal:.2f}，"
            f"置信度={emotion_result.confidence:.2f}。请据此调整回应的语气和方向。]"
        )

        messages = self._prompt_manager.build_messages(
            AgentType.EMOTIONAL,
            context.history,
            enriched_input + emotion_hint,
            persona=context.persona,
        )
        # Inject empathy guidelines into system prompt
        messages[0]["content"] += EMPATHY_SYSTEM_PROMPT

        # Step 4: Get intervention suggestions for negative emotions
        intervention_note = ""
        if emotion_result.valence < -0.3:
            strategies = get_strategies_for_emotion(emotion_result.label, max_results=3)
            if strategies:
                suggestions = "、".join(s.name for s in strategies)
                intervention_note = (
                    f"\n\n💚 你可以试试这些放松技巧：{suggestions}。"
                    "需要我详细介绍其中一个吗？"
                )

        # Step 5: Generate empathetic response via LLM
        try:
            result = await self._llm.generate(messages)
            content = result["content"]
            if intervention_note:
                content += intervention_note
        except Exception:
            await logger.aexception("emotional_agent.llm_failed")
            content = (
                "我感受到你现在可能不太舒服。虽然我暂时无法完整回应，"
                "但请记住你的感受是重要的。如果需要帮助，可以找学校心理咨询师聊聊。"
            )

        return AgentResponse(
            content=content,
            agent_type=AgentType.EMOTIONAL,
            emotion_label=emotion_result.label.value,
            emotion_score=emotion_result.confidence,
            metadata={
                "valence": emotion_result.valence,
                "arousal": emotion_result.arousal,
                "scores": emotion_result.scores,
            },
        )

    def get_capabilities(self) -> list[str]:
        return [
            "empathetic_dialogue",
            "emotion_detection",
            "crisis_detection",
            "intervention_recommendation",
            "gratitude_journaling",
        ]

    def get_agent_type(self) -> AgentType:
        return AgentType.EMOTIONAL
