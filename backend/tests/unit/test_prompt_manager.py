"""Tests for prompt template manager."""

from app.models.conversation import AgentType
from app.services.prompt_manager import AGENT_PROMPTS, BASE_SYSTEM_PROMPT, PromptManager


class TestPromptManager:
    def setup_method(self):
        self.pm = PromptManager()

    def test_build_system_prompt_academic(self):
        prompt = self.pm.build_system_prompt(AgentType.ACADEMIC)
        assert BASE_SYSTEM_PROMPT in prompt
        assert AGENT_PROMPTS[AgentType.ACADEMIC] in prompt

    def test_build_system_prompt_all_agents(self):
        for agent_type in AgentType:
            prompt = self.pm.build_system_prompt(agent_type)
            assert BASE_SYSTEM_PROMPT in prompt
            assert AGENT_PROMPTS[agent_type] in prompt

    def test_build_system_prompt_with_persona(self):
        persona = {
            "name": "小明",
            "personality": "活泼开朗",
            "speaking_style": "幽默风趣",
            "catchphrase": "加油！",
        }
        prompt = self.pm.build_system_prompt(AgentType.ACADEMIC, persona=persona)
        assert "小明" in prompt
        assert "活泼开朗" in prompt
        assert "幽默风趣" in prompt
        assert "加油！" in prompt

    def test_build_messages_structure(self):
        history = [
            {"role": "user", "content": "你好"},
            {"role": "assistant", "content": "你好！有什么我可以帮你的？"},
        ]
        messages = self.pm.build_messages(AgentType.ACADEMIC, history, "这道题怎么解")

        assert messages[0]["role"] == "system"
        assert messages[1] == {"role": "user", "content": "你好"}
        assert messages[2] == {"role": "assistant", "content": "你好！有什么我可以帮你的？"}
        assert messages[3] == {"role": "user", "content": "这道题怎么解"}

    def test_build_messages_empty_history(self):
        messages = self.pm.build_messages(AgentType.EMOTIONAL, [], "我今天心情不好")
        assert len(messages) == 2
        assert messages[0]["role"] == "system"
        assert messages[1] == {"role": "user", "content": "我今天心情不好"}

    def test_build_messages_with_persona(self):
        persona = {"name": "学伴", "personality": "温暖"}
        messages = self.pm.build_messages(AgentType.EMOTIONAL, [], "你好", persona=persona)
        assert "学伴" in messages[0]["content"]
