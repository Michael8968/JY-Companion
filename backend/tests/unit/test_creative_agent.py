"""Tests for creative writing agent and service."""

from app.agents.creative_agent import CREATIVE_SYSTEM_PROMPT, CreativeAgent
from app.models.conversation import AgentType
from app.services.creative_service import (
    INSPIRATION_PROMPT,
    STORY_GENERATION_PROMPT,
    WORK_EVALUATE_PROMPT,
    WRITING_OPTIMIZE_PROMPT,
    CreativeService,
)


class TestCreativeAgent:
    def test_agent_type(self) -> None:
        agent = CreativeAgent()
        assert agent.get_agent_type() == AgentType.CREATIVE

    def test_capabilities(self) -> None:
        agent = agent = CreativeAgent()
        caps = agent.get_capabilities()
        assert "creative_writing" in caps
        assert "story_generation" in caps
        assert "writing_optimization" in caps
        assert "work_evaluation" in caps
        assert "inspiration_brainstorm" in caps

    def test_creative_prompt_exists(self) -> None:
        assert len(CREATIVE_SYSTEM_PROMPT) > 50


class TestPromptTemplates:
    def test_story_generation_prompt(self) -> None:
        assert "故事大纲" in STORY_GENERATION_PROMPT
        assert "角色设定" in STORY_GENERATION_PROMPT

    def test_optimize_prompt(self) -> None:
        assert "修辞" in WRITING_OPTIMIZE_PROMPT
        assert "结构" in WRITING_OPTIMIZE_PROMPT

    def test_evaluate_prompt_has_dimensions(self) -> None:
        assert "叙事完整性" in WORK_EVALUATE_PROMPT
        assert "语言表达" in WORK_EVALUATE_PROMPT
        assert "情感深度" in WORK_EVALUATE_PROMPT
        assert "结构逻辑" in WORK_EVALUATE_PROMPT
        assert "创意独特性" in WORK_EVALUATE_PROMPT

    def test_inspiration_prompt(self) -> None:
        assert "3-5" in INSPIRATION_PROMPT or "灵感" in INSPIRATION_PROMPT


class TestCreativeService:
    def test_service_init(self) -> None:
        service = CreativeService()
        assert service._llm is not None
