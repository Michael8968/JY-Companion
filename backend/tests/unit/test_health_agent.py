"""Tests for health guardian agent and service."""

from app.agents.health_agent import HEALTH_SYSTEM_PROMPT, HealthAgent
from app.models.conversation import AgentType
from app.models.health import ReminderType
from app.services.health_service import (
    EXERCISE_TEMPLATES,
    REMINDER_MESSAGES,
)


class TestHealthAgent:
    def test_agent_type(self) -> None:
        agent = HealthAgent()
        assert agent.get_agent_type() == AgentType.HEALTH

    def test_capabilities(self) -> None:
        agent = HealthAgent()
        caps = agent.get_capabilities()
        assert "screen_time_monitoring" in caps
        assert "break_reminder" in caps
        assert "exercise_plan" in caps

    def test_health_prompt_exists(self) -> None:
        assert len(HEALTH_SYSTEM_PROMPT) > 50


class TestExerciseTemplates:
    def test_stretch_exercises(self) -> None:
        exercises = EXERCISE_TEMPLATES["stretch"]
        assert len(exercises) >= 3
        for e in exercises:
            assert "name" in e
            assert "description" in e
            assert "duration_seconds" in e

    def test_strength_exercises(self) -> None:
        assert len(EXERCISE_TEMPLATES["strength"]) >= 3

    def test_coordination_exercises(self) -> None:
        assert len(EXERCISE_TEMPLATES["coordination"]) >= 2

    def test_all_types_have_templates(self) -> None:
        for plan_type in ("stretch", "strength", "coordination"):
            assert plan_type in EXERCISE_TEMPLATES


class TestReminderMessages:
    def test_all_types_have_messages(self) -> None:
        for rt in ReminderType:
            assert rt in REMINDER_MESSAGES
            assert len(REMINDER_MESSAGES[rt]) >= 1

    def test_forced_break_has_messages(self) -> None:
        msgs = REMINDER_MESSAGES[ReminderType.FORCED_BREAK]
        assert len(msgs) >= 1
        assert any("40" in m or "休息" in m for m in msgs)
