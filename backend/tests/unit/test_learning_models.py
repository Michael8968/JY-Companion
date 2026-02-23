"""Tests for learning record models and enums."""

from app.models.learning import Difficulty, ErrorType, MasteryStatus, Subject


class TestLearningEnums:
    def test_subjects(self):
        assert Subject.MATH == "math"
        assert Subject.PHYSICS == "physics"
        assert Subject.CHEMISTRY == "chemistry"
        assert Subject.CHINESE == "chinese"
        assert Subject.ENGLISH == "english"

    def test_error_types(self):
        assert ErrorType.CONCEPT_MISUNDERSTANDING == "concept_misunderstanding"
        assert ErrorType.WRONG_APPROACH == "wrong_approach"
        assert ErrorType.MISREAD_QUESTION == "misread_question"
        assert ErrorType.CALCULATION_ERROR == "calculation_error"

    def test_mastery_status(self):
        assert MasteryStatus.WEAK == "weak"
        assert MasteryStatus.IMPROVING == "improving"
        assert MasteryStatus.MASTERED == "mastered"

    def test_difficulty(self):
        assert Difficulty.EASY == "easy"
        assert Difficulty.MEDIUM == "medium"
        assert Difficulty.HARD == "hard"

    def test_all_subjects_count(self):
        assert len(list(Subject)) == 9  # 9 subjects
