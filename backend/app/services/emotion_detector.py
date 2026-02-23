"""Multi-modal emotion detector — text, voice, visual fusion."""

import structlog

from app.models.emotion import EmotionLabel, EmotionSource

logger = structlog.get_logger()

# Text-based emotion keyword rules (base version)
_EMOTION_KEYWORDS: dict[EmotionLabel, list[str]] = {
    EmotionLabel.HAPPY: ["开心", "高兴", "快乐", "太棒了", "哈哈", "激动", "兴奋", "满意", "幸福", "喜悦"],
    EmotionLabel.ANXIOUS: ["焦虑", "紧张", "担心", "害怕", "不安", "恐慌", "慌", "忐忑", "压力大"],
    EmotionLabel.DEPRESSED: ["抑郁", "消沉", "绝望", "无助", "空虚", "麻木", "没有动力"],
    EmotionLabel.SAD: ["难过", "伤心", "悲伤", "哭", "流泪", "痛苦", "失落", "遗憾", "心碎"],
    EmotionLabel.ANGRY: ["生气", "愤怒", "烦躁", "恼火", "气死", "讨厌", "烦", "怒"],
    EmotionLabel.FEARFUL: ["害怕", "恐惧", "惊恐", "吓", "可怕", "畏惧"],
    EmotionLabel.CALM: ["平静", "放松", "淡定", "安心", "舒适", "宁静"],
}

# Valence mapping: positive emotion → positive valence
_VALENCE_MAP: dict[EmotionLabel, float] = {
    EmotionLabel.HAPPY: 0.8,
    EmotionLabel.CALM: 0.3,
    EmotionLabel.SAD: -0.6,
    EmotionLabel.ANXIOUS: -0.5,
    EmotionLabel.DEPRESSED: -0.8,
    EmotionLabel.ANGRY: -0.6,
    EmotionLabel.FEARFUL: -0.7,
}

# Arousal mapping
_AROUSAL_MAP: dict[EmotionLabel, float] = {
    EmotionLabel.HAPPY: 0.7,
    EmotionLabel.CALM: 0.2,
    EmotionLabel.SAD: 0.3,
    EmotionLabel.ANXIOUS: 0.8,
    EmotionLabel.DEPRESSED: 0.2,
    EmotionLabel.ANGRY: 0.9,
    EmotionLabel.FEARFUL: 0.8,
}


class EmotionResult:
    def __init__(
        self,
        label: EmotionLabel,
        valence: float,
        arousal: float,
        confidence: float,
        source: EmotionSource,
        scores: dict[str, float] | None = None,
    ):
        self.label = label
        self.valence = valence
        self.arousal = arousal
        self.confidence = confidence
        self.source = source
        self.scores = scores or {}


class EmotionDetector:
    """Multi-modal emotion detection.

    Current: keyword-based text analysis.
    Future: ML model for text + voice prosody + facial expression fusion.
    """

    def detect_from_text(self, text: str) -> EmotionResult:
        """Detect emotion from text using keyword matching."""
        if not text:
            return EmotionResult(
                label=EmotionLabel.CALM, valence=0.0, arousal=0.1,
                confidence=0.3, source=EmotionSource.TEXT,
            )

        scores: dict[str, float] = {}
        for label, keywords in _EMOTION_KEYWORDS.items():
            score = sum(1.0 for kw in keywords if kw in text)
            if score > 0:
                scores[label.value] = score

        if not scores:
            return EmotionResult(
                label=EmotionLabel.CALM, valence=0.0, arousal=0.2,
                confidence=0.4, source=EmotionSource.TEXT, scores=scores,
            )

        best_label_str = max(scores, key=scores.get)
        best_label = EmotionLabel(best_label_str)
        max_score = scores[best_label_str]
        total_score = sum(scores.values())
        confidence = min(max_score / max(total_score, 1.0) * 0.9, 0.95)

        return EmotionResult(
            label=best_label,
            valence=_VALENCE_MAP.get(best_label, 0.0),
            arousal=_AROUSAL_MAP.get(best_label, 0.5),
            confidence=confidence,
            source=EmotionSource.TEXT,
            scores=scores,
        )

    def fuse(self, *results: EmotionResult) -> EmotionResult:
        """Fuse multiple emotion detection results (text + voice + visual).

        Uses weighted average based on confidence scores.
        """
        if not results:
            return EmotionResult(
                label=EmotionLabel.CALM, valence=0.0, arousal=0.2,
                confidence=0.0, source=EmotionSource.FUSED,
            )

        if len(results) == 1:
            return results[0]

        total_weight = sum(r.confidence for r in results)
        if total_weight == 0:
            return results[0]

        fused_valence = sum(r.valence * r.confidence for r in results) / total_weight
        fused_arousal = sum(r.arousal * r.confidence for r in results) / total_weight
        fused_confidence = min(total_weight / len(results), 0.95)

        # Determine label from fused valence/arousal
        best_label = EmotionLabel.CALM
        best_dist = float("inf")
        for label in EmotionLabel:
            v = _VALENCE_MAP.get(label, 0.0)
            a = _AROUSAL_MAP.get(label, 0.5)
            dist = (fused_valence - v) ** 2 + (fused_arousal - a) ** 2
            if dist < best_dist:
                best_dist = dist
                best_label = label

        return EmotionResult(
            label=best_label,
            valence=fused_valence,
            arousal=fused_arousal,
            confidence=fused_confidence,
            source=EmotionSource.FUSED,
        )
