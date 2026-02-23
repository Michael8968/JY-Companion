"""Tests for intent classifier."""

from app.hub.intent_classifier import IntentClassifier
from app.models.conversation import AgentType


class TestIntentClassifier:
    def setup_method(self):
        self.classifier = IntentClassifier()

    def test_academic_math(self):
        result = self.classifier.classify("这道二次函数求最大值怎么做？")
        assert result.agent_type == AgentType.ACADEMIC
        assert result.confidence >= 0.7
        assert "academic" in result.intent_label

    def test_academic_physics(self):
        result = self.classifier.classify("牛顿第二定律的加速度怎么算？")
        assert result.agent_type == AgentType.ACADEMIC
        assert result.confidence >= 0.7

    def test_academic_chemistry(self):
        result = self.classifier.classify("氧化还原反应怎么配平？")
        assert result.agent_type == AgentType.ACADEMIC

    def test_academic_generic(self):
        result = self.classifier.classify("这道题怎么解？帮我算一下")
        assert result.agent_type == AgentType.ACADEMIC

    def test_emotional_support(self):
        result = self.classifier.classify("我今天心情不好，考试考砸了很难过")
        assert result.agent_type == AgentType.EMOTIONAL
        assert result.confidence >= 0.7

    def test_classroom_review(self):
        result = self.classifier.classify("帮我整理一下今天课堂的知识点笔记")
        assert result.agent_type == AgentType.CLASSROOM

    def test_health(self):
        result = self.classifier.classify("我已经坐了很久了，眼睛好疲劳")
        assert result.agent_type == AgentType.HEALTH

    def test_creative(self):
        result = self.classifier.classify("帮我写一首关于春天的诗")
        assert result.agent_type == AgentType.CREATIVE

    def test_career(self):
        result = self.classifier.classify("高考填志愿选什么专业好？")
        assert result.agent_type == AgentType.CAREER

    def test_unknown_intent(self):
        result = self.classifier.classify("你好")
        assert result.confidence < 0.7
        assert result.needs_clarification

    def test_empty_input(self):
        result = self.classifier.classify("")
        assert result.intent_label == "unknown"
        assert result.confidence == 0.0

    def test_multiple_keyword_boost(self):
        result = self.classifier.classify("这道方程题怎么解？用不等式求最大值")
        assert result.agent_type == AgentType.ACADEMIC
        assert result.confidence > 0.85  # boosted by multiple matches
