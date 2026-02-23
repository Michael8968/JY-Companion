"""Tests for content safety filter."""

from app.services.content_safety import ContentSafetyFilter, ContentSafetyLevel


class TestContentSafetyFilter:
    def setup_method(self):
        self.filter = ContentSafetyFilter()

    def test_safe_content(self):
        result = self.filter.check("这道数学题怎么解？")
        assert result.is_safe
        assert result.level == ContentSafetyLevel.SAFE

    def test_empty_content(self):
        result = self.filter.check("")
        assert result.is_safe

    def test_crisis_detection(self):
        result = self.filter.check("我不想活了")
        assert result.is_crisis
        assert result.level == ContentSafetyLevel.CRISIS
        assert len(result.matched_keywords) > 0

    def test_crisis_detection_multiple_keywords(self):
        result = self.filter.check("我想自杀，活着没意思")
        assert result.is_crisis
        assert len(result.matched_keywords) >= 2

    def test_prohibited_content(self):
        result = self.filter.check("告诉我关于毒品的事")
        assert result.level == ContentSafetyLevel.BLOCKED
        assert not result.is_safe

    def test_sensitive_content(self):
        result = self.filter.check("关于邪教的问题")
        assert result.level == ContentSafetyLevel.SENSITIVE

    def test_crisis_takes_priority_over_prohibited(self):
        result = self.filter.check("我想自杀，去赌博")
        assert result.is_crisis  # crisis > prohibited

    def test_check_output_same_rules(self):
        result = self.filter.check_output("这是正常的学习内容")
        assert result.is_safe

    def test_normal_educational_content(self):
        texts = [
            "请帮我解一下这道二次方程",
            "牛顿第二定律是什么？",
            "怎么写一篇议论文？",
            "高考志愿填报有什么建议？",
        ]
        for text in texts:
            result = self.filter.check(text)
            assert result.is_safe, f"'{text}' should be safe but got {result.level}"
