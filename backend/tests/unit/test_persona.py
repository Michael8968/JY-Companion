"""Tests for persona interaction layer — manager, style controller, memory graph."""

import types

from app.persona.memory_graph import MEMORY_TYPES
from app.persona.persona_manager import (
    PERSONA_DIMENSIONS,
    PRESET_PERSONAS,
)
from app.persona.style_controller import (
    EMOTION_STYLE_MODIFIERS,
    StyleController,
)


class TestPersonaDimensions:
    """Verify ≥20 configurable persona dimensions."""

    def test_minimum_20_dimensions(self) -> None:
        assert len(PERSONA_DIMENSIONS) >= 20, (
            f"Need ≥20 persona dimensions, got {len(PERSONA_DIMENSIONS)}"
        )

    def test_all_dimensions_are_strings(self) -> None:
        for dim in PERSONA_DIMENSIONS:
            assert isinstance(dim, str)
            assert len(dim) > 0

    def test_key_dimensions_present(self) -> None:
        required = {
            "name", "display_name", "speaking_style", "tone",
            "catchphrase", "personality_traits", "knowledge_domains",
        }
        for dim in required:
            assert dim in PERSONA_DIMENSIONS, f"Missing dimension: {dim}"


class TestPresetPersonas:
    """Verify preset companion personas."""

    def test_minimum_2_presets(self) -> None:
        assert len(PRESET_PERSONAS) >= 2

    def test_all_presets_have_name(self) -> None:
        for p in PRESET_PERSONAS:
            assert "name" in p
            assert "display_name" in p
            assert len(p["name"]) > 0

    def test_all_presets_have_personality_traits(self) -> None:
        for p in PRESET_PERSONAS:
            traits = p.get("personality_traits", {})
            assert "openness" in traits
            assert "conscientiousness" in traits
            assert "extraversion" in traits
            assert "agreeableness" in traits
            assert "neuroticism" in traits

    def test_all_presets_have_catchphrase(self) -> None:
        for p in PRESET_PERSONAS:
            assert "catchphrase" in p
            assert len(p["catchphrase"]) > 0

    def test_all_presets_marked_as_preset(self) -> None:
        for p in PRESET_PERSONAS:
            assert p.get("is_preset") is True

    def test_presets_have_different_domains(self) -> None:
        all_domains = [set(p.get("preferred_agent_types", [])) for p in PRESET_PERSONAS]
        # At least some diversity in domains
        assert len(set().union(*all_domains)) >= 3

    def test_xueba_is_academic_focused(self) -> None:
        xueba = next(p for p in PRESET_PERSONAS if p["name"] == "xiaoyuan_xueba")
        assert "academic" in xueba["preferred_agent_types"]

    def test_mengchong_is_emotional_focused(self) -> None:
        mengchong = next(p for p in PRESET_PERSONAS if p["name"] == "xiaoyuan_mengchong")
        assert "emotional" in mengchong["preferred_agent_types"]

    def test_chuangke_is_creative_focused(self) -> None:
        chuangke = next(p for p in PRESET_PERSONAS if p["name"] == "xiaoyuan_chuangke")
        assert "creative" in chuangke["preferred_agent_types"]


class TestStyleController:
    """Verify style controller functionality."""

    def test_emotion_modifiers_coverage(self) -> None:
        assert len(EMOTION_STYLE_MODIFIERS) >= 5
        assert "happy" in EMOTION_STYLE_MODIFIERS
        assert "sad" in EMOTION_STYLE_MODIFIERS
        assert "anxious" in EMOTION_STYLE_MODIFIERS

    def test_build_style_prompt_basic(self) -> None:
        controller = StyleController()
        # Create a mock-like Persona with required attributes
        persona = _make_test_persona()
        prompt = controller.build_style_prompt(persona)
        assert "小元学霸" in prompt
        assert "风格控制" in prompt

    def test_build_style_prompt_with_emotion(self) -> None:
        controller = StyleController()
        persona = _make_test_persona()
        prompt = controller.build_style_prompt(persona, emotion_context="sad")
        assert "温柔体贴" in prompt or "安慰" in prompt

    def test_personality_summary(self) -> None:
        controller = StyleController()
        persona = _make_test_persona()
        summary = controller.get_personality_summary(persona)
        assert "小元学霸" in summary

    def test_should_switch_persona(self) -> None:
        controller = StyleController()
        persona = _make_test_persona()
        # Academic persona should switch when emotional intent detected
        assert controller.should_switch_persona(persona, "emotional") is True
        assert controller.should_switch_persona(persona, "academic") is False


class TestMemoryTypes:
    def test_all_types_defined(self) -> None:
        assert "commitment" in MEMORY_TYPES
        assert "preference" in MEMORY_TYPES
        assert "fact" in MEMORY_TYPES
        assert "relationship" in MEMORY_TYPES
        assert "emotional_context" in MEMORY_TYPES


class TestMemoryGraphBuildContext:
    def test_empty_memories(self) -> None:
        # build_memory_context is a pure function, test without DB
        from app.persona.memory_graph import PersonaMemoryGraph as Graph
        instance = Graph.__new__(Graph)
        context = instance.build_memory_context([])
        assert context == ""


def _make_test_persona() -> types.SimpleNamespace:
    """Create a test persona without DB (avoids SQLAlchemy instrumentation)."""
    return types.SimpleNamespace(
        display_name="小元学霸",
        description="学业辅导伙伴",
        speaking_style="清晰有条理",
        tone="warm",
        catchphrase="我们一起看看~",
        vocabulary_level="academic",
        emoji_usage="moderate",
        humor_level="medium",
        formality="semi-formal",
        empathy_level="medium",
        response_length="detailed",
        encouragement_style="数据型鼓励",
        teaching_approach="引导式教学",
        personality_traits={
            "openness": 0.8, "conscientiousness": 0.9,
            "extraversion": 0.6, "agreeableness": 0.8, "neuroticism": 0.2,
        },
        preferred_agent_types=["academic", "classroom"],
    )
