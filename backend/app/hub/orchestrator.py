"""DAG task orchestrator — decomposes complex requests into sub-tasks.

Basic version: single-agent routing.
Future: multi-agent DAG with parallel/serial execution, ≤5 depth.
"""

import asyncio
from dataclasses import dataclass, field

import structlog

from app.agents.base_agent import AgentContext, AgentResponse
from app.hub.agent_registry import AgentRegistry
from app.hub.intent_classifier import IntentClassifier, IntentResult
from app.models.conversation import AgentType

logger = structlog.get_logger()

TASK_TIMEOUT_SECONDS = 10


@dataclass
class SubTask:
    """A single unit of work in the DAG."""

    task_id: str
    agent_type: AgentType
    input_text: str
    depends_on: list[str] = field(default_factory=list)


@dataclass
class OrchestrationResult:
    """Result of orchestrating one or more sub-tasks."""

    responses: list[AgentResponse]
    intent: IntentResult
    aggregated_content: str


class Orchestrator:
    """Route user input through intent classification → agent execution.

    Current: single-task routing.
    Future: DAG decomposition for complex multi-agent tasks.
    """

    def __init__(self, registry: AgentRegistry) -> None:
        self.registry = registry
        self.intent_classifier = IntentClassifier()

    async def process(self, context: AgentContext) -> OrchestrationResult:
        """Main entry point: classify intent → route → execute → return."""

        # 1. Classify intent
        intent = self.intent_classifier.classify(context.user_input)

        # 2. Determine target agent
        target_type = intent.agent_type or context.agent_type

        agent = self.registry.get_agent(target_type)
        if not agent:
            # Fallback: use conversation's default agent type
            agent = self.registry.get_agent(context.agent_type)

        if not agent:
            return OrchestrationResult(
                responses=[],
                intent=intent,
                aggregated_content="抱歉，当前没有可用的智能体来处理你的请求。",
            )

        # 3. Execute agent (with timeout)
        enriched_context = AgentContext(
            user_id=context.user_id,
            conversation_id=context.conversation_id,
            agent_type=target_type,
            user_input=context.user_input,
            history=context.history,
            context_snapshot=context.context_snapshot,
            persona=context.persona,
            rag_context=context.rag_context,
        )

        try:
            response = await asyncio.wait_for(
                agent.process(enriched_context),
                timeout=TASK_TIMEOUT_SECONDS,
            )
        except TimeoutError:
            logger.warning("orchestrator.timeout", agent=target_type.value)
            return OrchestrationResult(
                responses=[],
                intent=intent,
                aggregated_content="处理超时，请稍后再试或简化你的问题。",
            )

        return OrchestrationResult(
            responses=[response],
            intent=intent,
            aggregated_content=response.content,
        )

    async def process_multi(self, tasks: list[SubTask], base_context: AgentContext) -> OrchestrationResult:
        """Execute multiple sub-tasks respecting DAG dependencies.

        Basic implementation: group by dependency level, execute each level in parallel.
        """
        intent = self.intent_classifier.classify(base_context.user_input)
        responses: list[AgentResponse] = []
        results_map: dict[str, AgentResponse] = {}

        # Build dependency levels
        remaining = {t.task_id: t for t in tasks}
        completed: set[str] = set()

        while remaining:
            # Find tasks whose dependencies are all met
            ready = [t for t in remaining.values() if all(d in completed for d in t.depends_on)]
            if not ready:
                logger.error("orchestrator.dag_deadlock", remaining=list(remaining.keys()))
                break

            # Execute ready tasks in parallel
            async def _run(task: SubTask) -> tuple[str, AgentResponse | None]:
                agent = self.registry.get_agent(task.agent_type)
                if not agent:
                    return task.task_id, None
                ctx = AgentContext(
                    user_id=base_context.user_id,
                    conversation_id=base_context.conversation_id,
                    agent_type=task.agent_type,
                    user_input=task.input_text,
                    history=base_context.history,
                    context_snapshot=base_context.context_snapshot,
                    persona=base_context.persona,
                )
                try:
                    resp = await asyncio.wait_for(agent.process(ctx), timeout=TASK_TIMEOUT_SECONDS)
                    return task.task_id, resp
                except TimeoutError:
                    logger.warning("orchestrator.subtask_timeout", task_id=task.task_id)
                    return task.task_id, None

            batch_results = await asyncio.gather(*[_run(t) for t in ready])

            for task_id, resp in batch_results:
                completed.add(task_id)
                del remaining[task_id]
                if resp:
                    responses.append(resp)
                    results_map[task_id] = resp

        aggregated = "\n\n".join(r.content for r in responses) if responses else "未能完成任务，请重试。"

        return OrchestrationResult(
            responses=responses,
            intent=intent,
            aggregated_content=aggregated,
        )
