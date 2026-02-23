"""Content safety filter — keyword-based pre-check + basic classifier."""

import re

import structlog

logger = structlog.get_logger()

# High-risk keywords for crisis detection (Sprint 7 will expand this)
CRISIS_KEYWORDS: set[str] = {
    "自杀", "自残", "不想活", "去死", "跳楼", "割腕", "结束生命",
    "活着没意思", "没有希望", "想死",
}

# Prohibited content keywords
PROHIBITED_KEYWORDS: set[str] = {
    "色情", "赌博", "毒品", "暴力恐怖", "枪支",
}

# Sensitive topic keywords — trigger soft redirect
SENSITIVE_KEYWORDS: set[str] = {
    "政治敏感", "宗教极端", "邪教",
}

# Compile patterns for efficient matching
_CRISIS_PATTERN = re.compile("|".join(re.escape(k) for k in CRISIS_KEYWORDS))
_PROHIBITED_PATTERN = re.compile("|".join(re.escape(k) for k in PROHIBITED_KEYWORDS))
_SENSITIVE_PATTERN = re.compile("|".join(re.escape(k) for k in SENSITIVE_KEYWORDS))


class ContentSafetyLevel:
    SAFE = "safe"
    SENSITIVE = "sensitive"
    BLOCKED = "blocked"
    CRISIS = "crisis"


class ContentSafetyResult:
    def __init__(self, level: str, matched_keywords: list[str] | None = None, reason: str = ""):
        self.level = level
        self.matched_keywords = matched_keywords or []
        self.reason = reason

    @property
    def is_safe(self) -> bool:
        return self.level == ContentSafetyLevel.SAFE

    @property
    def is_crisis(self) -> bool:
        return self.level == ContentSafetyLevel.CRISIS


class ContentSafetyFilter:
    """Rule-based content safety filter.

    This is the base version using keyword matching.
    Sprint 7 will add ML-based classifiers and crisis alert integration.
    """

    def check(self, text: str) -> ContentSafetyResult:
        """Synchronous check — suitable for pre-LLM fast path (<100ms)."""
        if not text:
            return ContentSafetyResult(ContentSafetyLevel.SAFE)

        # 1. Crisis detection (highest priority)
        crisis_matches = _CRISIS_PATTERN.findall(text)
        if crisis_matches:
            logger.warning("content_safety.crisis_detected", keywords=crisis_matches)
            return ContentSafetyResult(
                level=ContentSafetyLevel.CRISIS,
                matched_keywords=crisis_matches,
                reason="Crisis-related content detected",
            )

        # 2. Prohibited content
        prohibited_matches = _PROHIBITED_PATTERN.findall(text)
        if prohibited_matches:
            logger.warning("content_safety.prohibited", keywords=prohibited_matches)
            return ContentSafetyResult(
                level=ContentSafetyLevel.BLOCKED,
                matched_keywords=prohibited_matches,
                reason="Prohibited content detected",
            )

        # 3. Sensitive topics
        sensitive_matches = _SENSITIVE_PATTERN.findall(text)
        if sensitive_matches:
            logger.info("content_safety.sensitive", keywords=sensitive_matches)
            return ContentSafetyResult(
                level=ContentSafetyLevel.SENSITIVE,
                matched_keywords=sensitive_matches,
                reason="Sensitive topic detected",
            )

        return ContentSafetyResult(ContentSafetyLevel.SAFE)

    def check_output(self, text: str) -> ContentSafetyResult:
        """Check LLM output — same rules apply."""
        return self.check(text)
