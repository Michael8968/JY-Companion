"""Base agent interface — all intelligent agents inherit from this."""

import abc
from dataclasses import dataclass, field

from app.models.conversation import AgentType


@dataclass
class AgentContext:
    """Context passed to agent for processing."""

    user_id: str
    conversation_id: str
    agent_type: AgentType
    user_input: str
    history: list[dict[str, str]] = field(default_factory=list)
    context_snapshot: dict | None = None
    persona: dict | None = None
    rag_context: str | None = None


@dataclass
class AgentResponse:
    """Standardized agent response."""

    content: str
    agent_type: AgentType
    intent_label: str | None = None
    intent_confidence: float | None = None
    emotion_label: str | None = None
    emotion_score: float | None = None
    metadata: dict = field(default_factory=dict)


class BaseAgent(abc.ABC):
    """Abstract base for all intelligent agents.

    All agents must implement:
    - process(): Handle a user request and return a response.
    - health_check(): Verify the agent is operational.
    - get_capabilities(): Declare what this agent can do.
    """

    @abc.abstractmethod
    async def process(self, context: AgentContext) -> AgentResponse:
        """Process user input and return a response."""

    async def health_check(self) -> bool:
        """Check if the agent is healthy. Default: True."""
        return True

    @abc.abstractmethod
    def get_capabilities(self) -> list[str]:
        """Return a list of capability strings this agent handles."""

    @abc.abstractmethod
    def get_agent_type(self) -> AgentType:
        """Return the agent type this agent handles."""
