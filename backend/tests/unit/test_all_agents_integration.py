"""Integration tests for all 6 intelligent agents.

Verifies all agents are properly structured, can be instantiated,
and conform to the BaseAgent interface.
"""

import asyncio

from app.agents.academic_agent import AcademicAgent
from app.agents.base_agent import BaseAgent
from app.agents.career_agent import CareerAgent
from app.agents.classroom_agent import ClassroomAgent
from app.agents.creative_agent import CreativeAgent
from app.agents.emotional_agent import EmotionalAgent
from app.agents.health_agent import HealthAgent
from app.models.conversation import AgentType

ALL_AGENTS = [
    (AcademicAgent, AgentType.ACADEMIC),
    (ClassroomAgent, AgentType.CLASSROOM),
    (EmotionalAgent, AgentType.EMOTIONAL),
    (HealthAgent, AgentType.HEALTH),
    (CreativeAgent, AgentType.CREATIVE),
    (CareerAgent, AgentType.CAREER),
]


class TestAllAgentsConformance:
    """Verify all 6 agents conform to BaseAgent interface."""

    def test_six_agents_exist(self) -> None:
        assert len(ALL_AGENTS) == 6

    def test_all_inherit_base_agent(self) -> None:
        for agent_cls, _ in ALL_AGENTS:
            assert issubclass(agent_cls, BaseAgent), f"{agent_cls.__name__} must inherit BaseAgent"

    def test_all_instantiable(self) -> None:
        for agent_cls, _ in ALL_AGENTS:
            agent = agent_cls()
            assert agent is not None

    def test_all_have_correct_type(self) -> None:
        for agent_cls, expected_type in ALL_AGENTS:
            agent = agent_cls()
            assert agent.get_agent_type() == expected_type, (
                f"{agent_cls.__name__}.get_agent_type() returned {agent.get_agent_type()}, "
                f"expected {expected_type}"
            )

    def test_all_have_capabilities(self) -> None:
        for agent_cls, _ in ALL_AGENTS:
            agent = agent_cls()
            caps = agent.get_capabilities()
            assert isinstance(caps, list)
            assert len(caps) >= 2, f"{agent_cls.__name__} needs ≥2 capabilities"

    def test_all_have_process_method(self) -> None:
        for agent_cls, _ in ALL_AGENTS:
            assert hasattr(agent_cls, "process")
            assert asyncio.iscoroutinefunction(agent_cls.process)

    def test_all_pass_health_check(self) -> None:
        loop = asyncio.get_event_loop()
        for agent_cls, _ in ALL_AGENTS:
            agent = agent_cls()
            result = loop.run_until_complete(agent.health_check())
            assert result is True, f"{agent_cls.__name__} health check failed"

    def test_agent_type_enum_coverage(self) -> None:
        """Every AgentType should have a corresponding agent."""
        implemented_types = {t for _, t in ALL_AGENTS}
        for agent_type in AgentType:
            assert agent_type in implemented_types, (
                f"AgentType.{agent_type.name} has no agent implementation"
            )

    def test_no_duplicate_types(self) -> None:
        types = [t for _, t in ALL_AGENTS]
        assert len(types) == len(set(types)), "Duplicate agent types found"

    def test_all_capabilities_unique_within_agent(self) -> None:
        for agent_cls, _ in ALL_AGENTS:
            agent = agent_cls()
            caps = agent.get_capabilities()
            assert len(caps) == len(set(caps)), (
                f"{agent_cls.__name__} has duplicate capabilities"
            )
