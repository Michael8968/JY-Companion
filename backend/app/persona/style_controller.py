"""Style controller — real-time persona parameter injection for text generation.

Ensures generated text matches the persona's speaking style, tone, and personality.
"""

import structlog

from app.models.persona import Persona

logger = structlog.get_logger()

# Style injection template with rich persona context
STYLE_INJECTION_TEMPLATE = (
    "\n\n--- 人设风格控制 ---\n"
    "角色名: {display_name}\n"
    "性格描述: {description}\n"
    "说话风格: {speaking_style}\n"
    "语气基调: {tone}\n"
    "口头禅: {catchphrase}\n"
    "词汇水平: {vocabulary_level}\n"
    "表情符号使用: {emoji_usage}\n"
    "幽默程度: {humor_level}\n"
    "正式程度: {formality}\n"
    "共情水平: {empathy_level}\n"
    "回复长度偏好: {response_length}\n"
    "鼓励方式: {encouragement_style}\n"
    "教学方式: {teaching_approach}\n"
    "--- 风格控制结束 ---\n"
    "严格按照上述人设风格特征生成回复。"
    "保持人格一致性，不要在对话中偏离角色设定。"
)

# Emotion-aware style modifiers
EMOTION_STYLE_MODIFIERS: dict[str, str] = {
    "happy": "语气更加轻松愉快，可以使用更多积极词汇。",
    "sad": "语气更加温柔体贴，放慢节奏，给予更多安慰。",
    "anxious": "语气更加沉稳冷静，提供具体可行的建议。",
    "angry": "语气保持平和包容，先接纳情绪再引导思考。",
    "encouraging": "增加肯定和赞美，强调进步和优点。",
    "empathy": "多使用共情表达，如'我理解你的感受'。",
    "curious": "以好奇和探索的口吻回应，激发学生的好奇心。",
    "serious": "减少口语化表达，增加逻辑性和条理性。",
}


class StyleController:
    """Controls text generation style based on persona parameters."""

    def build_style_prompt(
        self,
        persona: Persona,
        emotion_context: str | None = None,
    ) -> str:
        """Build a full style injection prompt for LLM.

        Args:
            persona: The persona model with all dimension parameters.
            emotion_context: Optional emotion label to modify style.

        Returns:
            Style injection string to append to system prompt.
        """
        style_prompt = STYLE_INJECTION_TEMPLATE.format(
            display_name=persona.display_name,
            description=persona.description or "学习伙伴",
            speaking_style=persona.speaking_style or "自然亲切",
            tone=persona.tone or "warm",
            catchphrase=persona.catchphrase or "",
            vocabulary_level=persona.vocabulary_level or "mixed",
            emoji_usage=persona.emoji_usage or "moderate",
            humor_level=persona.humor_level or "medium",
            formality=persona.formality or "semi-formal",
            empathy_level=persona.empathy_level or "medium",
            response_length=persona.response_length or "moderate",
            encouragement_style=persona.encouragement_style or "鼓励学生",
            teaching_approach=persona.teaching_approach or "引导式教学",
        )

        # Add emotion-aware modifiers
        if emotion_context and emotion_context in EMOTION_STYLE_MODIFIERS:
            style_prompt += f"\n当前情感语境调整: {EMOTION_STYLE_MODIFIERS[emotion_context]}"

        return style_prompt

    def get_personality_summary(self, persona: Persona) -> str:
        """Generate a one-line personality summary for quick injection."""
        traits = persona.personality_traits or {}
        dominant_traits = sorted(traits.items(), key=lambda x: x[1], reverse=True)[:3]
        trait_names = {
            "openness": "开放性",
            "conscientiousness": "尽责性",
            "extraversion": "外向性",
            "agreeableness": "宜人性",
            "neuroticism": "情绪稳定性(反)",
        }
        summary_parts = [
            f"{trait_names.get(k, k)}({v:.0%})"
            for k, v in dominant_traits
        ]
        return f"{persona.display_name}: {', '.join(summary_parts)}"

    def should_switch_persona(
        self,
        current_persona: Persona,
        detected_intent: str,
    ) -> bool:
        """Check if a persona switch is recommended based on intent change.

        Returns True if the detected intent doesn't match the current persona's domains.
        """
        preferred = current_persona.preferred_agent_types or []
        if not preferred:
            return False

        # Map intent labels to agent types
        intent_to_agent = {
            "academic": "academic",
            "classroom": "classroom",
            "emotional": "emotional",
            "health": "health",
            "creative": "creative",
            "career": "career",
        }

        agent_type = intent_to_agent.get(detected_intent)
        return bool(agent_type and agent_type not in preferred)
