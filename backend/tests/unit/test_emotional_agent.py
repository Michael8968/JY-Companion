"""Tests for emotional agent."""


from app.agents.emotional_agent import EMPATHY_SYSTEM_PROMPT, EmotionalAgent
from app.models.conversation import AgentType
from app.services.crisis_alert import TIER_1_CRITICAL, TIER_2_HIGH, TIER_3_MEDIUM
from app.services.emotion_detector import EmotionDetector


class TestEmotionalAgentInit:
    def test_agent_type(self) -> None:
        agent = EmotionalAgent()
        assert agent.get_agent_type() == AgentType.EMOTIONAL

    def test_capabilities(self) -> None:
        agent = EmotionalAgent()
        caps = agent.get_capabilities()
        assert "empathetic_dialogue" in caps
        assert "crisis_detection" in caps
        assert "emotion_detection" in caps
        assert "intervention_recommendation" in caps

    def test_health_check(self) -> None:
        agent = EmotionalAgent()
        import asyncio
        result = asyncio.get_event_loop().run_until_complete(agent.health_check())
        assert result is True


class TestEmotionDetectorIntegration:
    """Test emotion detection integrated into agent flow."""

    def test_detector_available(self) -> None:
        agent = EmotionalAgent()
        assert agent._detector is not None

    def test_detect_negative_emotion(self) -> None:
        detector = EmotionDetector()
        result = detector.detect_from_text("我好难过啊")
        assert result.valence < 0

    def test_detect_positive_emotion(self) -> None:
        detector = EmotionDetector()
        result = detector.detect_from_text("今天好开心")
        assert result.valence > 0


class TestEmpathyPrompt:
    def test_empathy_prompt_exists(self) -> None:
        assert len(EMPATHY_SYSTEM_PROMPT) > 100

    def test_empathy_prompt_has_guidelines(self) -> None:
        assert "共情" in EMPATHY_SYSTEM_PROMPT or "不评判" in EMPATHY_SYSTEM_PROMPT

    def test_empathy_prompt_has_open_questions(self) -> None:
        assert "开放式" in EMPATHY_SYSTEM_PROMPT


class TestCrisisKeywordCoverage:
    """Verify keyword library coverage."""

    def test_tier1_not_empty(self) -> None:
        assert len(TIER_1_CRITICAL) >= 10

    def test_tier2_not_empty(self) -> None:
        assert len(TIER_2_HIGH) >= 8

    def test_tier3_not_empty(self) -> None:
        assert len(TIER_3_MEDIUM) >= 5
