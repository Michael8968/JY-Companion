"""Crisis alert system [SAFETY-CRITICAL].

Fast-path crisis detection: keyword pre-check (<100ms) → immediate alert.
Does NOT go through LLM inference to guarantee ≤30s response.
"""

import re
import time
import uuid

import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.emotion import AlertLevel, AlertStatus, CrisisAlert

logger = structlog.get_logger()

# Expanded high-risk keyword library for crisis detection
# Organized by severity tier
TIER_1_CRITICAL: set[str] = {
    "自杀", "自残", "割腕", "跳楼", "跳河", "上吊", "服毒", "吞药",
    "结束生命", "不想活了", "去死", "想死", "寻死",
    "杀了自己", "了结", "一了百了",
}

TIER_2_HIGH: set[str] = {
    "不想活", "活着没意思", "没有希望", "活不下去",
    "世界没有我会更好", "我是多余的", "没人在乎我",
    "再也撑不住", "崩溃了", "受不了了",
    "伤害自己", "划手臂", "用刀",
}

TIER_3_MEDIUM: set[str] = {
    "好想消失", "想逃离", "太痛苦了", "撑不住",
    "看不到未来", "一切都没意义", "厌世",
    "感觉被抛弃", "没有人理解我",
}

ALL_CRISIS_KEYWORDS = TIER_1_CRITICAL | TIER_2_HIGH | TIER_3_MEDIUM

_TIER1_PATTERN = re.compile("|".join(re.escape(k) for k in TIER_1_CRITICAL))
_TIER2_PATTERN = re.compile("|".join(re.escape(k) for k in TIER_2_HIGH))
_TIER3_PATTERN = re.compile("|".join(re.escape(k) for k in TIER_3_MEDIUM))


class CrisisCheckResult:
    def __init__(
        self,
        is_crisis: bool,
        alert_level: AlertLevel | None = None,
        matched_keywords: list[str] | None = None,
    ):
        self.is_crisis = is_crisis
        self.alert_level = alert_level
        self.matched_keywords = matched_keywords or []


def check_crisis_keywords(text: str) -> CrisisCheckResult:
    """Synchronous crisis keyword check. Must complete in <100ms.

    Returns CrisisCheckResult with alert level based on keyword tier.
    """
    if not text:
        return CrisisCheckResult(is_crisis=False)

    # Tier 1: CRITICAL — immediate danger
    tier1_matches = _TIER1_PATTERN.findall(text)
    if tier1_matches:
        return CrisisCheckResult(
            is_crisis=True,
            alert_level=AlertLevel.CRITICAL,
            matched_keywords=tier1_matches,
        )

    # Tier 2: HIGH — serious risk
    tier2_matches = _TIER2_PATTERN.findall(text)
    if tier2_matches:
        return CrisisCheckResult(
            is_crisis=True,
            alert_level=AlertLevel.HIGH,
            matched_keywords=tier2_matches,
        )

    # Tier 3: MEDIUM — elevated concern
    tier3_matches = _TIER3_PATTERN.findall(text)
    if tier3_matches:
        return CrisisCheckResult(
            is_crisis=True,
            alert_level=AlertLevel.MEDIUM,
            matched_keywords=tier3_matches,
        )

    return CrisisCheckResult(is_crisis=False)


# Safe responses per alert level
CRISIS_RESPONSES: dict[AlertLevel, str] = {
    AlertLevel.CRITICAL: (
        "我听到了你说的话，我非常担心你的安全。"
        "请记住，你并不孤单，有人在乎你。\n\n"
        "🆘 如果你正处于紧急危险中，请立即拨打：\n"
        "• 全国心理援助热线：400-161-9995\n"
        "• 北京心理危机研究与干预中心：010-82951332\n"
        "• 生命热线：400-821-1215\n\n"
        "学校心理咨询师已收到通知，会尽快联系你。"
    ),
    AlertLevel.HIGH: (
        "我感受到你现在非常不好受。你的感受是真实的，也是重要的。\n\n"
        "我希望你知道，遇到困难时寻求帮助是勇敢的表现。"
        "学校心理咨询师可以为你提供专业支持。\n\n"
        "💚 心理援助热线：400-161-9995（24小时）\n"
        "老师已收到提醒，会关注你的状况。"
    ),
    AlertLevel.MEDIUM: (
        "我注意到你可能正在经历一段困难的时期。"
        "每个人都会有低谷的时候，这并不意味着你不够好。\n\n"
        "如果你愿意，可以和我多聊聊，或者和信任的老师、家人谈谈你的感受。\n"
        "💚 学校心理咨询室随时欢迎你。"
    ),
}


async def create_crisis_alert(
    db: AsyncSession,
    user_id: uuid.UUID,
    check_result: CrisisCheckResult,
    trigger_content: str,
    conversation_id: uuid.UUID | None = None,
    start_time_ns: int | None = None,
) -> CrisisAlert:
    """Create a crisis alert record and trigger notifications.

    Args:
        db: Database session.
        user_id: User who triggered the alert.
        check_result: Result from check_crisis_keywords.
        trigger_content: Desensitized version of the triggering content.
        conversation_id: Optional conversation context.
        start_time_ns: time.time_ns() when the check started, for response_time_ms calculation.
    """
    response_time_ms = None
    if start_time_ns:
        response_time_ms = (time.time_ns() - start_time_ns) // 1_000_000

    # Desensitize trigger content — partial mask
    desensitized = _desensitize(trigger_content)

    notified_roles = ["teacher", "counselor"]
    if check_result.alert_level == AlertLevel.CRITICAL:
        notified_roles.append("parent")

    alert = CrisisAlert(
        user_id=user_id,
        conversation_id=conversation_id,
        alert_level=check_result.alert_level,
        status=AlertStatus.ACTIVE,
        trigger_type="keyword",
        trigger_content=desensitized,
        matched_keywords=check_result.matched_keywords,
        notified_roles=notified_roles,
        response_time_ms=response_time_ms,
    )
    db.add(alert)
    await db.flush()

    logger.critical(
        "crisis_alert.created",
        alert_id=str(alert.id),
        user_id=str(user_id),
        level=check_result.alert_level,
        response_time_ms=response_time_ms,
        notified=notified_roles,
    )

    # Trigger async notification (Redis Pub/Sub)
    await _publish_alert_notification(alert)

    return alert


async def _publish_alert_notification(alert: CrisisAlert) -> None:
    """Publish crisis alert via Redis Pub/Sub for real-time push.

    In production, this connects to Redis and publishes to alert channels.
    Consumers: teacher dashboard, parent app, counselor notification service.
    """
    try:
        import redis.asyncio as aioredis

        from app.config.settings import get_settings

        settings = get_settings()
        r = aioredis.from_url(settings.redis_url)

        import orjson

        payload = orjson.dumps({
            "alert_id": str(alert.id),
            "user_id": str(alert.user_id),
            "level": alert.alert_level,
            "notified_roles": alert.notified_roles,
            "trigger_type": alert.trigger_type,
        }).decode()

        await r.publish("crisis_alerts", payload)
        await r.close()
        logger.info("crisis_alert.published", alert_id=str(alert.id))
    except Exception:
        # Notification failure must NOT block the alert creation
        logger.exception("crisis_alert.publish_failed", alert_id=str(alert.id))


def _desensitize(text: str, max_len: int = 200) -> str:
    """Partial mask of sensitive content for audit logging."""
    if len(text) <= 10:
        return text[:2] + "***"
    truncated = text[:max_len]
    # Mask middle portion
    keep = len(truncated) // 4
    return truncated[:keep] + "***" + truncated[-keep:]
