"""Content safety filter — keyword-based pre-check + pattern classifier.

Enhanced in Sprint 11 for ≥99% violation interception rate.
Multi-layer approach:
  Layer 1: Keyword exact match (fast path, <5ms)
  Layer 2: Pattern/regex match for evasion detection (<20ms)
  Layer 3: Contextual rules for implicit violations (<50ms)
"""

import re

import structlog

logger = structlog.get_logger()

# ── Layer 1: Exact keyword matching ────────────────────────────

# High-risk keywords for crisis detection
CRISIS_KEYWORDS: set[str] = {
    "自杀", "自残", "不想活", "去死", "跳楼", "割腕", "结束生命",
    "活着没意思", "没有希望", "想死",
}

# Prohibited content keywords (expanded for ≥99% recall)
PROHIBITED_KEYWORDS: set[str] = {
    # Pornography
    "色情", "裸体", "性行为", "约炮", "一夜情", "成人网站", "黄色",
    # Gambling
    "赌博", "赌场", "博彩", "下注", "赔率", "庄家",
    # Drugs
    "毒品", "吸毒", "大麻", "冰毒", "K粉", "摇头丸",
    # Violence
    "暴力恐怖", "恐怖袭击", "制造炸弹", "杀人方法",
    # Weapons
    "枪支", "买枪", "弹药", "管制刀具",
    # Fraud
    "代写作业", "考试作弊", "买答案", "替考",
}

# Sensitive topic keywords — trigger soft redirect
SENSITIVE_KEYWORDS: set[str] = {
    "政治敏感", "宗教极端", "邪教",
    "翻墙", "VPN", "科学上网",
}

# ── Layer 2: Pattern-based evasion detection ───────────────────

EVASION_PATTERNS: list[tuple[str, re.Pattern, str]] = [
    # Homophone evasion: 自sha, 自s, zi杀
    ("crisis", re.compile(r"自[sS][hH]?[aA]?|[zZ][iI]杀"), "Homophone evasion for crisis keyword"),
    # Spaced evasion: 自 杀, 去 死
    ("crisis", re.compile(r"自\s+杀|去\s+死|跳\s+楼|想\s+死"), "Spaced evasion for crisis keyword"),
    # Symbol substitution: 自*杀, 去@死
    ("crisis", re.compile(r"自[.*@#!]+杀|去[.*@#!]+死"), "Symbol-substituted crisis keyword"),
    # Prohibited homophone evasion
    ("prohibited", re.compile(r"[sS][eè][qQ]?[iíì]?[nN]?[gG]?|黄[sS]"), "Pornography evasion"),
    ("prohibited", re.compile(r"[dD][uǔ][bB][oó]|赌[bB]"), "Gambling evasion"),
    # Academic fraud patterns
    ("prohibited", re.compile(r"帮我(写|做)(作业|论文|试卷)"), "Academic fraud request"),
    ("prohibited", re.compile(r"(答案|题目).*发(给|我|过来)"), "Answer solicitation"),
]

# ── Layer 3: Contextual rules ──────────────────────────────────

CONTEXT_RULES: list[dict] = [
    {
        "id": "personal_info_solicitation",
        "pattern": re.compile(r"(你的|告诉我)(手机号|身份证|家庭住址|银行卡|密码)"),
        "level": "blocked",
        "reason": "Personal information solicitation detected",
    },
    {
        "id": "meeting_request",
        "pattern": re.compile(r"(线下|私下|单独)(见面|约|出来)"),
        "level": "sensitive",
        "reason": "Offline meeting request detected",
    },
    {
        "id": "age_inappropriate",
        "pattern": re.compile(r"(喝酒|抽烟|纹身).*(一起|教我|怎么)"),
        "level": "sensitive",
        "reason": "Age-inappropriate activity discussion",
    },
]

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
    """Multi-layer content safety filter (≥99% violation interception).

    Layer 1: Keyword exact match (fast, <5ms)
    Layer 2: Pattern/regex evasion detection (<20ms)
    Layer 3: Contextual rules (<50ms)
    """

    def check(self, text: str) -> ContentSafetyResult:
        """Synchronous multi-layer check — pre-LLM fast path (<100ms)."""
        if not text:
            return ContentSafetyResult(ContentSafetyLevel.SAFE)

        # Layer 1: Exact keyword matching
        # 1a. Crisis detection (highest priority)
        crisis_matches = _CRISIS_PATTERN.findall(text)
        if crisis_matches:
            logger.warning("content_safety.crisis_detected", keywords=crisis_matches, layer=1)
            return ContentSafetyResult(
                level=ContentSafetyLevel.CRISIS,
                matched_keywords=crisis_matches,
                reason="Crisis-related content detected",
            )

        # 1b. Prohibited content
        prohibited_matches = _PROHIBITED_PATTERN.findall(text)
        if prohibited_matches:
            logger.warning("content_safety.prohibited", keywords=prohibited_matches, layer=1)
            return ContentSafetyResult(
                level=ContentSafetyLevel.BLOCKED,
                matched_keywords=prohibited_matches,
                reason="Prohibited content detected",
            )

        # Layer 2: Pattern-based evasion detection
        for category, pattern, reason in EVASION_PATTERNS:
            matches = pattern.findall(text)
            if matches:
                level = ContentSafetyLevel.CRISIS if category == "crisis" else ContentSafetyLevel.BLOCKED
                logger.warning(
                    "content_safety.evasion_detected",
                    category=category, reason=reason, layer=2,
                )
                return ContentSafetyResult(
                    level=level,
                    matched_keywords=matches,
                    reason=reason,
                )

        # Layer 3: Contextual rules
        for rule in CONTEXT_RULES:
            matches = rule["pattern"].findall(text)
            if matches:
                level = ContentSafetyLevel.BLOCKED if rule["level"] == "blocked" else ContentSafetyLevel.SENSITIVE
                logger.info(
                    "content_safety.context_rule",
                    rule_id=rule["id"], reason=rule["reason"], layer=3,
                )
                return ContentSafetyResult(
                    level=level,
                    matched_keywords=[m if isinstance(m, str) else "".join(m) for m in matches],
                    reason=rule["reason"],
                )

        # Layer 1 (continued): Sensitive topics (lowest priority)
        sensitive_matches = _SENSITIVE_PATTERN.findall(text)
        if sensitive_matches:
            logger.info("content_safety.sensitive", keywords=sensitive_matches, layer=1)
            return ContentSafetyResult(
                level=ContentSafetyLevel.SENSITIVE,
                matched_keywords=sensitive_matches,
                reason="Sensitive topic detected",
            )

        return ContentSafetyResult(ContentSafetyLevel.SAFE)

    def check_output(self, text: str) -> ContentSafetyResult:
        """Check LLM output — same multi-layer rules apply."""
        return self.check(text)
