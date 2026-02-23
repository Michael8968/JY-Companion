"""Tests for crisis alert system [SAFETY-CRITICAL].

Validates:
- 100% recall for all crisis keywords (Tier 1, 2, 3)
- Correct alert level classification
- <100ms response time for keyword check
- Desensitization of trigger content
- Crisis response messages exist for all levels
"""

import time

import pytest

from app.models.emotion import AlertLevel
from app.services.crisis_alert import (
    ALL_CRISIS_KEYWORDS,
    CRISIS_RESPONSES,
    TIER_1_CRITICAL,
    TIER_2_HIGH,
    TIER_3_MEDIUM,
    _desensitize,
    check_crisis_keywords,
)

# ── 100% Recall Tests ──


class TestTier1CriticalKeywords:
    """Every Tier 1 keyword must be detected with CRITICAL level."""

    @pytest.mark.parametrize("keyword", sorted(TIER_1_CRITICAL))
    def test_tier1_detected(self, keyword: str) -> None:
        result = check_crisis_keywords(f"我今天{keyword}")
        assert result.is_crisis is True
        assert result.alert_level == AlertLevel.CRITICAL
        assert keyword in result.matched_keywords


class TestTier2HighKeywords:
    """Every Tier 2 keyword must be detected with HIGH level."""

    @pytest.mark.parametrize("keyword", sorted(TIER_2_HIGH))
    def test_tier2_detected(self, keyword: str) -> None:
        result = check_crisis_keywords(f"最近{keyword}")
        assert result.is_crisis is True
        assert result.alert_level == AlertLevel.HIGH
        assert keyword in result.matched_keywords


class TestTier3MediumKeywords:
    """Every Tier 3 keyword must be detected with MEDIUM level."""

    @pytest.mark.parametrize("keyword", sorted(TIER_3_MEDIUM))
    def test_tier3_detected(self, keyword: str) -> None:
        result = check_crisis_keywords(f"我觉得{keyword}")
        assert result.is_crisis is True
        assert result.alert_level == AlertLevel.MEDIUM
        assert keyword in result.matched_keywords


# ── Priority Tests ──


class TestAlertPriority:
    """Tier 1 takes priority over Tier 2 over Tier 3."""

    def test_tier1_overrides_tier2(self) -> None:
        text = "我不想活了，也活着没意思"
        result = check_crisis_keywords(text)
        assert result.alert_level == AlertLevel.CRITICAL

    def test_tier2_overrides_tier3(self) -> None:
        text = "活不下去，好想消失"
        result = check_crisis_keywords(text)
        assert result.alert_level == AlertLevel.HIGH


# ── Non-Crisis Tests ──


class TestNonCrisis:
    """Normal text should not trigger crisis alerts."""

    def test_empty_text(self) -> None:
        result = check_crisis_keywords("")
        assert result.is_crisis is False
        assert result.alert_level is None

    def test_normal_text(self) -> None:
        result = check_crisis_keywords("今天数学考试考得不错")
        assert result.is_crisis is False

    def test_positive_text(self) -> None:
        result = check_crisis_keywords("我今天很开心，和朋友一起玩了")
        assert result.is_crisis is False

    def test_academic_complaint(self) -> None:
        result = check_crisis_keywords("数学好难啊，怎么都学不会")
        assert result.is_crisis is False


# ── Performance Tests ──


class TestPerformance:
    """Crisis check must complete in <100ms."""

    def test_keyword_check_under_100ms(self) -> None:
        text = "我最近感觉很不好，什么都不想做"
        start = time.perf_counter_ns()
        check_crisis_keywords(text)
        elapsed_ms = (time.perf_counter_ns() - start) / 1_000_000
        assert elapsed_ms < 100, f"Crisis check took {elapsed_ms:.1f}ms (>100ms)"

    def test_long_text_under_100ms(self) -> None:
        text = "今天心情很差。" * 1000 + "我想自杀"
        start = time.perf_counter_ns()
        result = check_crisis_keywords(text)
        elapsed_ms = (time.perf_counter_ns() - start) / 1_000_000
        assert result.is_crisis is True
        assert elapsed_ms < 100, f"Crisis check took {elapsed_ms:.1f}ms (>100ms)"


# ── Desensitization Tests ──


class TestDesensitization:
    def test_short_text(self) -> None:
        result = _desensitize("短文本")
        assert "***" in result
        assert len(result) < len("短文本") + 5

    def test_long_text_masked(self) -> None:
        text = "这是一段比较长的文本内容用于测试脱敏功能是否正常"
        result = _desensitize(text)
        assert "***" in result
        assert result != text

    def test_max_len_truncation(self) -> None:
        text = "a" * 500
        result = _desensitize(text, max_len=100)
        assert len(result) <= 105  # 100/4 + 3 + 100/4


# ── Response Coverage Tests ──


class TestCrisisResponses:
    def test_all_levels_have_response(self) -> None:
        assert AlertLevel.CRITICAL in CRISIS_RESPONSES
        assert AlertLevel.HIGH in CRISIS_RESPONSES
        assert AlertLevel.MEDIUM in CRISIS_RESPONSES

    def test_critical_response_has_hotline(self) -> None:
        response = CRISIS_RESPONSES[AlertLevel.CRITICAL]
        assert "400-161-9995" in response

    def test_high_response_has_hotline(self) -> None:
        response = CRISIS_RESPONSES[AlertLevel.HIGH]
        assert "400-161-9995" in response


# ── Keyword Coverage Test ──


class TestKeywordLibrary:
    def test_keyword_count(self) -> None:
        assert len(ALL_CRISIS_KEYWORDS) >= 30, (
            f"Need ≥30 crisis keywords, got {len(ALL_CRISIS_KEYWORDS)}"
        )

    def test_no_overlap_tier1_tier2(self) -> None:
        overlap = TIER_1_CRITICAL & TIER_2_HIGH
        assert len(overlap) == 0, f"Tier 1/2 overlap: {overlap}"

    def test_no_overlap_tier2_tier3(self) -> None:
        overlap = TIER_2_HIGH & TIER_3_MEDIUM
        assert len(overlap) == 0, f"Tier 2/3 overlap: {overlap}"
