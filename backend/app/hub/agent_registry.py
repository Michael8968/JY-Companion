"""Agent registry — register, discover, and route to intelligent agents."""

import structlog

from app.agents.base_agent import BaseAgent
from app.models.conversation import AgentType

logger = structlog.get_logger()


class AgentRegistry:
    """Central registry for all intelligent agents.

    Agents register themselves with their type and capabilities.
    The router uses this to dispatch requests to the right agent.
    """

    def __init__(self) -> None:
        self._agents: dict[AgentType, BaseAgent] = {}

    def register(self, agent: BaseAgent) -> None:
        agent_type = agent.get_agent_type()
        self._agents[agent_type] = agent
        logger.info(
            "agent.registered",
            agent_type=agent_type.value,
            capabilities=agent.get_capabilities(),
        )

    def get_agent(self, agent_type: AgentType) -> BaseAgent | None:
        return self._agents.get(agent_type)

    def get_all_agents(self) -> dict[AgentType, BaseAgent]:
        return dict(self._agents)

    def get_available_types(self) -> list[AgentType]:
        return list(self._agents.keys())

    async def health_check_all(self) -> dict[str, bool]:
        results = {}
        for agent_type, agent in self._agents.items():
            try:
                results[agent_type.value] = await agent.health_check()
            except Exception:
                results[agent_type.value] = False
        return results


# Global singleton
_registry = AgentRegistry()


def get_agent_registry() -> AgentRegistry:
    return _registry
