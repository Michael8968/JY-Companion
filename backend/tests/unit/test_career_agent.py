"""Tests for career planning agent and service."""

from app.agents.career_agent import CAREER_SYSTEM_PROMPT, CareerAgent
from app.models.career import GoalPriority, GoalStatus
from app.models.conversation import AgentType
from app.services.career_service import (
    GOAL_DECOMPOSE_PROMPT,
    LEARNING_PATH_PROMPT,
    PROGRESS_REPORT_PROMPT,
)


class TestCareerAgent:
    def test_agent_type(self) -> None:
        agent = CareerAgent()
        assert agent.get_agent_type() == AgentType.CAREER

    def test_capabilities(self) -> None:
        agent = CareerAgent()
        caps = agent.get_capabilities()
        assert "smart_goal_management" in caps
        assert "learning_path_recommendation" in caps
        assert "progress_tracking" in caps
        assert "weekly_report" in caps

    def test_career_prompt_exists(self) -> None:
        assert len(CAREER_SYSTEM_PROMPT) > 50
        assert "SMART" in CAREER_SYSTEM_PROMPT


class TestGoalEnums:
    def test_goal_statuses(self) -> None:
        assert GoalStatus.ACTIVE == "active"
        assert GoalStatus.COMPLETED == "completed"
        assert GoalStatus.PAUSED == "paused"
        assert GoalStatus.ABANDONED == "abandoned"

    def test_goal_priorities(self) -> None:
        assert GoalPriority.HIGH == "high"
        assert GoalPriority.MEDIUM == "medium"
        assert GoalPriority.LOW == "low"


class TestCareerPromptTemplates:
    def test_goal_decompose_prompt(self) -> None:
        assert "SMART" in GOAL_DECOMPOSE_PROMPT
        assert "月度计划" in GOAL_DECOMPOSE_PROMPT

    def test_learning_path_prompt(self) -> None:
        assert "书籍" in LEARNING_PATH_PROMPT or "课程" in LEARNING_PATH_PROMPT

    def test_progress_report_prompt(self) -> None:
        assert "偏差分析" in PROGRESS_REPORT_PROMPT or "完成率" in PROGRESS_REPORT_PROMPT


class TestTTSClient:
    def test_tts_client_init(self) -> None:
        from app.services.tts_client import TTSClient
        client = TTSClient(base_url="http://localhost:8090")
        assert client._base_url == "http://localhost:8090"

    def test_tts_result(self) -> None:
        from app.services.tts_client import TTSResult
        result = TTSResult(audio_data=b"test", sample_rate=22050)
        assert result.audio_data == b"test"
        assert result.sample_rate == 22050
        assert result.audio_format == "wav"
