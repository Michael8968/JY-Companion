"""Tests for intervention strategy library."""


from app.models.emotion import EmotionLabel
from app.services.intervention_strategies import (
    STRATEGIES,
    get_strategies_by_category,
    get_strategies_for_emotion,
)


class TestStrategyLibrary:
    def test_minimum_50_strategies(self) -> None:
        assert len(STRATEGIES) >= 50, f"Need ≥50, got {len(STRATEGIES)}"

    def test_unique_ids(self) -> None:
        ids = [s.id for s in STRATEGIES]
        assert len(ids) == len(set(ids)), "Duplicate strategy IDs found"

    def test_all_have_instructions(self) -> None:
        for s in STRATEGIES:
            assert s.instructions, f"Strategy {s.id} missing instructions"
            assert s.description, f"Strategy {s.id} missing description"

    def test_all_have_target_emotions(self) -> None:
        for s in STRATEGIES:
            assert len(s.target_emotions) > 0, f"Strategy {s.id} has no target emotions"

    def test_all_durations_positive(self) -> None:
        for s in STRATEGIES:
            assert s.duration_minutes > 0, f"Strategy {s.id} has invalid duration"


class TestGetStrategiesForEmotion:
    def test_anxious_has_strategies(self) -> None:
        strategies = get_strategies_for_emotion(EmotionLabel.ANXIOUS)
        assert len(strategies) > 0
        for s in strategies:
            assert EmotionLabel.ANXIOUS in s.target_emotions

    def test_depressed_has_strategies(self) -> None:
        strategies = get_strategies_for_emotion(EmotionLabel.DEPRESSED)
        assert len(strategies) > 0

    def test_sad_has_strategies(self) -> None:
        strategies = get_strategies_for_emotion(EmotionLabel.SAD)
        assert len(strategies) > 0

    def test_angry_has_strategies(self) -> None:
        strategies = get_strategies_for_emotion(EmotionLabel.ANGRY)
        assert len(strategies) > 0

    def test_fearful_has_strategies(self) -> None:
        strategies = get_strategies_for_emotion(EmotionLabel.FEARFUL)
        assert len(strategies) > 0

    def test_max_results_limit(self) -> None:
        strategies = get_strategies_for_emotion(EmotionLabel.ANXIOUS, max_results=3)
        assert len(strategies) <= 3

    def test_happy_may_have_no_strategies(self) -> None:
        strategies = get_strategies_for_emotion(EmotionLabel.HAPPY)
        # Happy doesn't typically need interventions
        assert isinstance(strategies, list)


class TestGetStrategiesByCategory:
    def test_breathing_category(self) -> None:
        strategies = get_strategies_by_category("breathing")
        assert len(strategies) >= 5
        for s in strategies:
            assert s.category == "breathing"

    def test_mindfulness_category(self) -> None:
        strategies = get_strategies_by_category("mindfulness")
        assert len(strategies) >= 5

    def test_cognitive_category(self) -> None:
        strategies = get_strategies_by_category("cognitive")
        assert len(strategies) >= 5

    def test_behavioral_category(self) -> None:
        strategies = get_strategies_by_category("behavioral")
        assert len(strategies) >= 5

    def test_unknown_category_empty(self) -> None:
        strategies = get_strategies_by_category("nonexistent")
        assert strategies == []
