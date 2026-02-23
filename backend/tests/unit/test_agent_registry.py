"""Tests for agent registry."""

import pytest

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.hub.agent_registry import AgentRegistry
from app.models.conversation import AgentType


class MockAgent(BaseAgent):
    def __init__(self, agent_type: AgentType):
        self._type = agent_type

    async def process(self, context: AgentContext) -> AgentResponse:
        return AgentResponse(content="mock response", agent_type=self._type)

    def get_capabilities(self) -> list[str]:
        return ["mock_capability"]

    def get_agent_type(self) -> AgentType:
        return self._type


class TestAgentRegistry:
    def setup_method(self):
        self.registry = AgentRegistry()

    def test_register_and_get(self):
        agent = MockAgent(AgentType.ACADEMIC)
        self.registry.register(agent)
        assert self.registry.get_agent(AgentType.ACADEMIC) is agent

    def test_get_nonexistent(self):
        assert self.registry.get_agent(AgentType.EMOTIONAL) is None

    def test_get_available_types(self):
        self.registry.register(MockAgent(AgentType.ACADEMIC))
        self.registry.register(MockAgent(AgentType.EMOTIONAL))
        types = self.registry.get_available_types()
        assert AgentType.ACADEMIC in types
        assert AgentType.EMOTIONAL in types
        assert len(types) == 2

    @pytest.mark.asyncio
    async def test_health_check_all(self):
        self.registry.register(MockAgent(AgentType.ACADEMIC))
        results = await self.registry.health_check_all()
        assert results["academic"] is True
