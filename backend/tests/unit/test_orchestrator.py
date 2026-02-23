"""Tests for DAG orchestrator."""

import pytest

from app.agents.base_agent import AgentContext, AgentResponse, BaseAgent
from app.hub.agent_registry import AgentRegistry
from app.hub.orchestrator import Orchestrator
from app.models.conversation import AgentType


class EchoAgent(BaseAgent):
    def __init__(self, agent_type: AgentType):
        self._type = agent_type

    async def process(self, context: AgentContext) -> AgentResponse:
        return AgentResponse(
            content=f"[{self._type.value}] {context.user_input}",
            agent_type=self._type,
        )

    def get_capabilities(self) -> list[str]:
        return [f"{self._type.value}_support"]

    def get_agent_type(self) -> AgentType:
        return self._type


@pytest.fixture
def registry_with_agents():
    registry = AgentRegistry()
    for t in AgentType:
        registry.register(EchoAgent(t))
    return registry


class TestOrchestrator:
    @pytest.mark.asyncio
    async def test_route_academic(self, registry_with_agents):
        orch = Orchestrator(registry_with_agents)
        ctx = AgentContext(
            user_id="user1",
            conversation_id="conv1",
            agent_type=AgentType.ACADEMIC,
            user_input="这道函数题怎么解？",
        )
        result = await orch.process(ctx)
        assert "academic" in result.aggregated_content.lower()
        assert result.intent.confidence >= 0.7

    @pytest.mark.asyncio
    async def test_route_emotional(self, registry_with_agents):
        orch = Orchestrator(registry_with_agents)
        ctx = AgentContext(
            user_id="user1",
            conversation_id="conv1",
            agent_type=AgentType.EMOTIONAL,
            user_input="我今天心情不好",
        )
        result = await orch.process(ctx)
        assert "emotional" in result.aggregated_content.lower()

    @pytest.mark.asyncio
    async def test_fallback_to_conversation_agent(self, registry_with_agents):
        orch = Orchestrator(registry_with_agents)
        ctx = AgentContext(
            user_id="user1",
            conversation_id="conv1",
            agent_type=AgentType.ACADEMIC,
            user_input="你好",  # unknown intent
        )
        result = await orch.process(ctx)
        # Falls back to conversation's agent_type (ACADEMIC)
        assert "academic" in result.aggregated_content.lower()

    @pytest.mark.asyncio
    async def test_no_agent_available(self):
        empty_registry = AgentRegistry()
        orch = Orchestrator(empty_registry)
        ctx = AgentContext(
            user_id="user1",
            conversation_id="conv1",
            agent_type=AgentType.ACADEMIC,
            user_input="这道题怎么解？",
        )
        result = await orch.process(ctx)
        assert "没有可用的智能体" in result.aggregated_content
