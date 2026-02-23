"""Prompt template framework with persona injection support."""

from app.models.conversation import AgentType

# Base system prompt shared by all agents
BASE_SYSTEM_PROMPT = (
    "你是晋元中学AI智能学伴平台的学习伙伴。"
    "你的职责是帮助高中生学习、成长和发展。"
    "请始终保持友善、鼓励和耐心的态度。"
    "所有回答必须适合高中生年龄段。"
)

# Per-agent system prompts
AGENT_PROMPTS: dict[AgentType, str] = {
    AgentType.ACADEMIC: (
        "你是一位专业的学业辅导老师。"
        "擅长高中数学、物理、化学、语文、英语等科目的答疑解惑。"
        "解答问题时请分步骤说明思路，引导学生思考而非直接给出答案。"
        "当学生做错题时，帮助分析错因并推荐类似练习题。"
    ),
    AgentType.CLASSROOM: (
        "你是一位课堂复盘助手。"
        "帮助学生整理课堂笔记、生成结构化摘要、找出重要知识点。"
        "根据学生的学习特点生成个性化学案。"
    ),
    AgentType.EMOTIONAL: (
        "你是一位温暖的情感陪伴伙伴。"
        "善于倾听和共情，帮助学生管理情绪、缓解学业压力。"
        "引导积极心理，但绝不替代专业心理咨询。"
        "如果发现学生可能处于危险状态，立即启动安全协议。"
    ),
    AgentType.HEALTH: (
        "你是一位健康守护助手。"
        "关注学生的用眼健康、坐姿提醒和运动锻炼。"
        "每40分钟提醒学生休息，推荐适合的眼保健操和运动方案。"
    ),
    AgentType.CREATIVE: (
        "你是一位创意创作导师。"
        "擅长激发学生的写作灵感、辅助文学创作、科技小论文写作。"
        "给予建设性的创作反馈，鼓励原创思维。"
    ),
    AgentType.CAREER: (
        "你是一位生涯规划顾问。"
        "帮助学生探索兴趣、了解大学专业和职业方向。"
        "辅导学生制定SMART学习目标和长期规划。"
    ),
}

# Persona injection template placeholder
PERSONA_INJECTION_TEMPLATE = (
    "\n\n--- 人设信息 ---\n"
    "名字: {name}\n"
    "性格特点: {personality}\n"
    "说话风格: {speaking_style}\n"
    "口头禅: {catchphrase}\n"
    "--- 人设信息结束 ---\n"
    "请按照上述人设风格进行对话。"
)


class PromptManager:
    """Build system prompts with agent-specific and persona layers."""

    def build_system_prompt(
        self,
        agent_type: AgentType,
        persona: dict | None = None,
    ) -> str:
        """Compose full system prompt.

        Args:
            agent_type: Which agent is handling the conversation.
            persona: Optional persona dict with keys: name, personality, speaking_style, catchphrase.

        Returns:
            Complete system prompt string.
        """
        parts = [BASE_SYSTEM_PROMPT]

        agent_prompt = AGENT_PROMPTS.get(agent_type)
        if agent_prompt:
            parts.append(agent_prompt)

        if persona:
            parts.append(
                PERSONA_INJECTION_TEMPLATE.format(
                    name=persona.get("name", "学伴"),
                    personality=persona.get("personality", "友善、耐心"),
                    speaking_style=persona.get("speaking_style", "自然亲切"),
                    catchphrase=persona.get("catchphrase", ""),
                )
            )

        return "\n\n".join(parts)

    def build_messages(
        self,
        agent_type: AgentType,
        history: list[dict[str, str]],
        user_input: str,
        persona: dict | None = None,
    ) -> list[dict[str, str]]:
        """Build the full message list for LLM call.

        Args:
            agent_type: Which agent.
            history: Previous messages as [{"role": "user|assistant", "content": "..."}].
            user_input: Current user message.
            persona: Optional persona info.

        Returns:
            Messages list ready for LLM API.
        """
        system_prompt = self.build_system_prompt(agent_type, persona)
        messages: list[dict[str, str]] = [{"role": "system", "content": system_prompt}]
        messages.extend(history)
        messages.append({"role": "user", "content": user_input})
        return messages
