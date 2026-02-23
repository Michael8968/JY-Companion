"""Tests for academic agent and CoT prompt templates."""

from app.agents.academic_agent import AcademicAgent, _detect_subject
from app.models.conversation import AgentType
from app.services.prompt_templates.academic import (
    HINT_BRIEF,
    HINT_DETAILED,
    HINT_STANDARD,
    build_cot_messages,
    build_error_diagnosis_messages,
)


class TestSubjectDetection:
    def test_detect_math(self):
        assert _detect_subject("这道方程怎么解？") == "math"

    def test_detect_physics(self):
        assert _detect_subject("牛顿第二定律的加速度") == "physics"

    def test_detect_chemistry(self):
        assert _detect_subject("氧化还原反应怎么配平") == "chemistry"

    def test_detect_chinese(self):
        assert _detect_subject("帮我分析这首古诗的修辞") == "chinese"

    def test_detect_english(self):
        assert _detect_subject("这道英语语法题怎么做") == "english"

    def test_default_to_math(self):
        assert _detect_subject("你好") == "math"


class TestCotMessages:
    def test_basic_structure(self):
        messages = build_cot_messages("math", "求x²-4x+3的最小值", [])
        assert messages[0]["role"] == "system"
        assert messages[-1]["role"] == "user"
        assert "最小值" in messages[-1]["content"]

    def test_with_history(self):
        history = [{"role": "user", "content": "你好"}, {"role": "assistant", "content": "你好！"}]
        messages = build_cot_messages("math", "继续", history)
        assert len(messages) == 4  # system + 2 history + user

    def test_with_rag_context(self):
        messages = build_cot_messages("math", "求最值", [], rag_context="配方法知识点...")
        assert "参考资料" in messages[-1]["content"]

    def test_hint_levels(self):
        for level in [HINT_BRIEF, HINT_STANDARD, HINT_DETAILED]:
            messages = build_cot_messages("math", "test", [], hint_level=level)
            assert messages[0]["role"] == "system"

    def test_subject_prompt_included(self):
        messages = build_cot_messages("physics", "力的合成", [])
        assert "物理" in messages[0]["content"]


class TestErrorDiagnosisMessages:
    def test_basic_structure(self):
        messages = build_error_diagnosis_messages("math", "2+2=?", "5")
        assert messages[0]["role"] == "system"
        assert "错误类型" in messages[0]["content"]
        assert "5" in messages[-1]["content"]

    def test_with_history(self):
        history = [{"role": "user", "content": "之前的对话"}]
        messages = build_error_diagnosis_messages("math", "2+2=?", "5", history=history)
        assert len(messages) == 3  # system + history + user


class TestAcademicAgent:
    def test_capabilities(self):
        agent = AcademicAgent()
        caps = agent.get_capabilities()
        assert "academic_math_question" in caps
        assert "error_diagnosis" in caps
        assert "exercise_recommendation" in caps

    def test_agent_type(self):
        agent = AcademicAgent()
        assert agent.get_agent_type() == AgentType.ACADEMIC
