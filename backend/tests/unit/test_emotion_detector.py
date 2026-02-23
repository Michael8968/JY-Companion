"""Tests for emotion detection system."""

import pytest

from app.models.emotion import EmotionLabel, EmotionSource
from app.services.emotion_detector import EmotionDetector, EmotionResult


@pytest.fixture
def detector() -> EmotionDetector:
    return EmotionDetector()


class TestDetectFromText:
    def test_happy_keywords(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("今天好开心，太棒了！")
        assert result.label == EmotionLabel.HAPPY
        assert result.valence > 0
        assert result.source == EmotionSource.TEXT

    def test_anxious_keywords(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("考试好紧张，很担心成绩")
        assert result.label == EmotionLabel.ANXIOUS
        assert result.valence < 0

    def test_sad_keywords(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("我好难过，心碎了")
        assert result.label == EmotionLabel.SAD
        assert result.valence < 0

    def test_angry_keywords(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("真的很烦躁，气死我了")
        assert result.label == EmotionLabel.ANGRY
        assert result.arousal > 0.5

    def test_depressed_keywords(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("感觉好绝望，什么都没有动力")
        assert result.label == EmotionLabel.DEPRESSED
        assert result.valence < -0.5

    def test_fearful_keywords(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("我害怕，感觉恐惧")
        assert result.label == EmotionLabel.FEARFUL

    def test_calm_keywords(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("我现在很平静，感觉很放松")
        assert result.label == EmotionLabel.CALM
        assert result.valence >= 0

    def test_empty_text(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("")
        assert result.label == EmotionLabel.CALM
        assert result.confidence <= 0.5

    def test_no_keywords(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("今天的数学课讲了导数")
        assert result.label == EmotionLabel.CALM
        assert result.confidence <= 0.5

    def test_confidence_bounded(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("好开心好开心好开心")
        assert 0 <= result.confidence <= 0.95

    def test_scores_populated(self, detector: EmotionDetector) -> None:
        result = detector.detect_from_text("我既紧张又难过")
        assert len(result.scores) >= 2


class TestFusion:
    def test_single_result(self, detector: EmotionDetector) -> None:
        r = EmotionResult(
            label=EmotionLabel.HAPPY, valence=0.8, arousal=0.7,
            confidence=0.9, source=EmotionSource.TEXT,
        )
        fused = detector.fuse(r)
        assert fused is r  # Single result returned as-is

    def test_no_results(self, detector: EmotionDetector) -> None:
        fused = detector.fuse()
        assert fused.label == EmotionLabel.CALM
        assert fused.source == EmotionSource.FUSED

    def test_two_results_weighted(self, detector: EmotionDetector) -> None:
        r1 = EmotionResult(
            label=EmotionLabel.HAPPY, valence=0.8, arousal=0.7,
            confidence=0.9, source=EmotionSource.TEXT,
        )
        r2 = EmotionResult(
            label=EmotionLabel.SAD, valence=-0.6, arousal=0.3,
            confidence=0.3, source=EmotionSource.VOICE,
        )
        fused = detector.fuse(r1, r2)
        assert fused.source == EmotionSource.FUSED
        # Higher confidence text should dominate
        assert fused.valence > 0

    def test_equal_confidence_averaging(self, detector: EmotionDetector) -> None:
        r1 = EmotionResult(
            label=EmotionLabel.ANXIOUS, valence=-0.5, arousal=0.8,
            confidence=0.5, source=EmotionSource.TEXT,
        )
        r2 = EmotionResult(
            label=EmotionLabel.ANGRY, valence=-0.6, arousal=0.9,
            confidence=0.5, source=EmotionSource.VOICE,
        )
        fused = detector.fuse(r1, r2)
        assert fused.valence == pytest.approx(-0.55, abs=0.01)
        assert fused.arousal == pytest.approx(0.85, abs=0.01)
