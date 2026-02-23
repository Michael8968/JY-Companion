"""Persona memory graph — cross-session consistency and commitment tracking.

Maintains a per-user, per-persona memory store for:
- Commitments (e.g., "I'll remind you to review tomorrow")
- User preferences discovered during conversations
- Important facts about the user
- Emotional context history
"""

import uuid

import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.persona import PersonaMemoryEntry

logger = structlog.get_logger()

# Memory types
MEMORY_TYPES = {
    "commitment": "承诺",      # Promises made by the persona
    "preference": "偏好",      # User preferences discovered
    "fact": "事实",            # Facts about the user
    "relationship": "关系",    # Social relationships mentioned
    "emotional_context": "情感", # Emotional patterns
}


class PersonaMemoryGraph:
    """Cross-session memory graph for persona consistency."""

    def __init__(self, db: AsyncSession) -> None:
        self._db = db

    async def add_memory(
        self,
        persona_id: uuid.UUID,
        user_id: uuid.UUID,
        memory_type: str,
        content: str,
        importance: int = 5,
        context: dict | None = None,
    ) -> PersonaMemoryEntry:
        """Add a memory entry to the graph."""
        entry = PersonaMemoryEntry(
            persona_id=persona_id,
            user_id=user_id,
            memory_type=memory_type,
            content=content,
            importance=importance,
            context=context,
        )
        self._db.add(entry)
        await self._db.flush()

        logger.info(
            "memory_graph.added",
            persona_id=str(persona_id),
            user_id=str(user_id),
            type=memory_type,
            importance=importance,
        )
        return entry

    async def get_memories(
        self,
        persona_id: uuid.UUID,
        user_id: uuid.UUID,
        memory_type: str | None = None,
        limit: int = 20,
    ) -> list[PersonaMemoryEntry]:
        """Get memories for a persona-user pair."""
        stmt = select(PersonaMemoryEntry).where(
            PersonaMemoryEntry.persona_id == persona_id,
            PersonaMemoryEntry.user_id == user_id,
        )
        if memory_type:
            stmt = stmt.where(PersonaMemoryEntry.memory_type == memory_type)

        stmt = stmt.order_by(
            PersonaMemoryEntry.importance.desc(),
            PersonaMemoryEntry.created_at.desc(),
        ).limit(limit)

        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    async def get_unfulfilled_commitments(
        self,
        persona_id: uuid.UUID,
        user_id: uuid.UUID,
    ) -> list[PersonaMemoryEntry]:
        """Get unfulfilled commitments for proactive follow-up."""
        stmt = select(PersonaMemoryEntry).where(
            PersonaMemoryEntry.persona_id == persona_id,
            PersonaMemoryEntry.user_id == user_id,
            PersonaMemoryEntry.memory_type == "commitment",
            PersonaMemoryEntry.is_fulfilled.is_(False),
        ).order_by(PersonaMemoryEntry.created_at.desc())

        result = await self._db.execute(stmt)
        return list(result.scalars().all())

    async def fulfill_commitment(
        self,
        memory_id: uuid.UUID,
    ) -> PersonaMemoryEntry | None:
        """Mark a commitment as fulfilled."""
        stmt = select(PersonaMemoryEntry).where(PersonaMemoryEntry.id == memory_id)
        result = await self._db.execute(stmt)
        entry = result.scalar_one_or_none()

        if not entry:
            return None

        entry.is_fulfilled = True
        await self._db.flush()
        return entry

    def build_memory_context(
        self,
        memories: list[PersonaMemoryEntry],
        max_tokens: int = 500,
    ) -> str:
        """Build a memory context string for LLM prompt injection.

        Prioritizes by importance, truncates to fit token budget.
        """
        if not memories:
            return ""

        lines = ["\n--- 记忆上下文 ---"]
        char_count = 0

        for mem in memories:
            type_label = MEMORY_TYPES.get(mem.memory_type, mem.memory_type)
            line = f"[{type_label}] {mem.content}"
            if mem.memory_type == "commitment" and not mem.is_fulfilled:
                line += " (待履行)"

            if char_count + len(line) > max_tokens * 2:  # rough char-to-token
                break

            lines.append(line)
            char_count += len(line)

        lines.append("--- 记忆上下文结束 ---")
        return "\n".join(lines)
