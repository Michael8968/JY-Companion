"""Creative writing service — text generation, writing optimization, work evaluation."""

import structlog

from app.services.llm_client import LLMClient

logger = structlog.get_logger()

# Prompt templates for creative tasks
STORY_GENERATION_PROMPT = (
    "你是一位创意写作导师。请根据用户的主题要求，生成以下内容：\n"
    "1. 故事大纲（200字以内）\n"
    "2. 主要角色设定（2-3个角色）\n"
    "3. 精彩的开头段落（300字以内）\n\n"
    "要求：适合高中生的阅读水平，语言生动有趣，富有想象力。"
)

WRITING_OPTIMIZE_PROMPT = (
    "你是一位专业的写作辅导老师。请对以下文稿提供优化建议：\n"
    "1. 修辞推荐：指出可以改进的修辞手法\n"
    "2. 结构优化：分析文章结构，提出改进方案\n"
    "3. 语言润色：标注可以更精炼的表达\n"
    "4. 亮点肯定：指出文中的精彩之处\n\n"
    "请给出具体、可操作的建议，语气鼓励而非批评。"
)

WORK_EVALUATE_PROMPT = (
    "你是一位文学作品评鉴专家。请从以下五个维度评价这篇作品：\n"
    "1. 叙事完整性（1-10分）：故事是否有完整的起承转合\n"
    "2. 语言表达（1-10分）：用词是否准确、优美\n"
    "3. 情感深度（1-10分）：是否能引起读者共鸣\n"
    "4. 结构逻辑（1-10分）：段落安排是否合理\n"
    "5. 创意独特性（1-10分）：是否有新颖的视角和想法\n\n"
    "对每个维度给出分数和具体评语，最后给出总评和改进方向。"
)

INSPIRATION_PROMPT = (
    "学生说自己遇到了创作瓶颈。请通过以下方式帮助激发灵感：\n"
    "1. 提出 3-5 个不同方向的创作建议\n"
    "2. 使用提问引导法激发思考\n"
    "3. 提供一张'随机灵感卡'（包含一个有趣的场景/角色/冲突）\n\n"
    "保持轻松有趣的氛围，让学生感到创作是一件快乐的事。"
)


class CreativeService:
    """Service for creative writing assistance."""

    def __init__(self) -> None:
        self._llm = LLMClient()

    async def generate_story(self, topic: str, style: str | None = None) -> dict:
        """Generate a story outline, characters, and opening paragraph."""
        prompt = STORY_GENERATION_PROMPT
        if style:
            prompt += f"\n风格要求：{style}"

        messages = [
            {"role": "system", "content": prompt},
            {"role": "user", "content": f"创作主题：{topic}"},
        ]

        try:
            result = await self._llm.generate(messages)
            return {"content": result["content"], "topic": topic, "style": style}
        except Exception:
            await logger.aexception("creative.generate_failed")
            return {"content": "创意生成服务暂时不可用，请稍后重试。", "topic": topic}

    async def optimize_writing(self, text: str) -> dict:
        """Provide writing optimization suggestions."""
        messages = [
            {"role": "system", "content": WRITING_OPTIMIZE_PROMPT},
            {"role": "user", "content": f"请优化以下文稿：\n\n{text}"},
        ]

        try:
            result = await self._llm.generate(messages)
            return {"suggestions": result["content"], "original_length": len(text)}
        except Exception:
            await logger.aexception("creative.optimize_failed")
            return {"suggestions": "写作优化服务暂时不可用。", "original_length": len(text)}

    async def evaluate_work(self, text: str, genre: str | None = None) -> dict:
        """Evaluate a creative work across multiple dimensions."""
        prompt = WORK_EVALUATE_PROMPT
        if genre:
            prompt += f"\n作品体裁：{genre}"

        messages = [
            {"role": "system", "content": prompt},
            {"role": "user", "content": f"请评价以下作品：\n\n{text}"},
        ]

        try:
            result = await self._llm.generate(messages)
            return {"evaluation": result["content"], "genre": genre}
        except Exception:
            await logger.aexception("creative.evaluate_failed")
            return {"evaluation": "作品评价服务暂时不可用。"}

    async def brainstorm_inspiration(
        self, context: str, stuck_point: str | None = None,
    ) -> dict:
        """Help overcome creative blocks with brainstorming."""
        prompt = INSPIRATION_PROMPT
        user_msg = f"创作背景：{context}"
        if stuck_point:
            user_msg += f"\n卡住的地方：{stuck_point}"

        messages = [
            {"role": "system", "content": prompt},
            {"role": "user", "content": user_msg},
        ]

        try:
            result = await self._llm.generate(messages)
            return {"inspiration": result["content"]}
        except Exception:
            await logger.aexception("creative.brainstorm_failed")
            return {"inspiration": "灵感激发服务暂时不可用。"}
