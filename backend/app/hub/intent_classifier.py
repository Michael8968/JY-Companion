"""Intent classifier — maps user input to agent types.

Current implementation: keyword-based rules.
Future: fine-tuned NLU model with ≥90% accuracy.
"""

import re

import structlog

from app.models.conversation import AgentType

logger = structlog.get_logger()

# Intent label → AgentType mapping
INTENT_AGENT_MAP: dict[str, AgentType] = {
    "academic_question": AgentType.ACADEMIC,
    "academic_math": AgentType.ACADEMIC,
    "academic_physics": AgentType.ACADEMIC,
    "academic_chemistry": AgentType.ACADEMIC,
    "academic_chinese": AgentType.ACADEMIC,
    "academic_english": AgentType.ACADEMIC,
    "classroom_review": AgentType.CLASSROOM,
    "emotional_support": AgentType.EMOTIONAL,
    "health_reminder": AgentType.HEALTH,
    "creative_writing": AgentType.CREATIVE,
    "career_planning": AgentType.CAREER,
}

# Keyword rules: (pattern, intent_label, base_confidence)
_RULES: list[tuple[re.Pattern[str], str, float]] = [
    # Academic — math
    (re.compile(r"(方程|函数|几何|证明|公式|数列|概率|统计|微积分|向量|矩阵|不等式|最[大小]值)"), "academic_math", 0.85),
    # Academic — physics
    (re.compile(r"(力学|电磁|光学|热力学|牛顿|动量|能量守恒|电路|磁场|加速度)"), "academic_physics", 0.85),
    # Academic — chemistry
    (re.compile(r"(化学|反应|元素|分子|摩尔|氧化还原|酸碱|有机|无机|化合物)"), "academic_chemistry", 0.85),
    # Academic — chinese
    (re.compile(r"(作文|议论文|古诗|文言文|阅读理解|修辞|成语|诗词|散文|小说)"), "academic_chinese", 0.85),
    # Academic — english
    (re.compile(r"(英语|English|语法|单词|翻译|完形填空|阅读|作文|听力|口语)"), "academic_english", 0.85),
    # Academic — generic
    (re.compile(r"(怎么[做解算]|这道题|求[解证]|帮我[解算]|题目|解题|答案)"), "academic_question", 0.80),
    # Classroom review
    (re.compile(r"(课堂|笔记|复盘|录音|上课|老师讲|知识点整理|学案|摘要)"), "classroom_review", 0.82),
    # Emotional support
    (re.compile(r"(心情|难过|焦虑|压力|烦躁|紧张|孤独|害怕|担心|不开心|郁闷|伤心|崩溃|烦恼)"), "emotional_support", 0.82),
    # Health
    (re.compile(r"(休息|眼睛|坐姿|运动|锻炼|久坐|疲劳|睡眠|视力|健康)"), "health_reminder", 0.80),
    # Creative
    (re.compile(r"(创作|写.{0,10}诗|写.{0,6}故事|写.{0,6}小说|灵感|想象力|创意|写作|文学|编故事|散文创作)"), "creative_writing", 0.82),
    # Career
    (re.compile(r"(志愿|专业|大学|职业|规划|目标|高考|未来|就业|生涯)"), "career_planning", 0.82),
]


class IntentResult:
    def __init__(self, intent_label: str, confidence: float, agent_type: AgentType | None):
        self.intent_label = intent_label
        self.confidence = confidence
        self.agent_type = agent_type

    @property
    def needs_clarification(self) -> bool:
        return self.confidence < 0.7


class IntentClassifier:
    """Rule-based intent classifier.

    Returns intent label, confidence, and the target agent type.
    When confidence < 0.7, the caller should ask the user to clarify.
    """

    def classify(self, text: str) -> IntentResult:
        if not text.strip():
            return IntentResult("unknown", 0.0, None)

        best_label = "unknown"
        best_confidence = 0.0

        for pattern, label, base_confidence in _RULES:
            matches = pattern.findall(text)
            if matches:
                # More keyword hits → higher confidence (capped at 0.95)
                confidence = min(base_confidence + 0.03 * (len(matches) - 1), 0.95)
                if confidence > best_confidence:
                    best_confidence = confidence
                    best_label = label

        agent_type = INTENT_AGENT_MAP.get(best_label)

        logger.info(
            "intent.classified",
            label=best_label,
            confidence=round(best_confidence, 2),
            agent=agent_type.value if agent_type else None,
        )
        return IntentResult(best_label, best_confidence, agent_type)
