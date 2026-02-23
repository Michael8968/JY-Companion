"""Persona interaction API endpoints — companion management, memory, bindings."""

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.core.exceptions import NotFoundError
from app.models.persona import UserPersonaBinding
from app.persona.memory_graph import PersonaMemoryGraph
from app.persona.persona_manager import PersonaManager
from app.schemas.persona import (
    AddMemoryRequest,
    BindPersonaRequest,
    MemoryEntryResponse,
    PersonaResponse,
    UserPersonaBindingResponse,
)

router = APIRouter(prefix="/personas", tags=["personas"])


@router.get("", response_model=list[PersonaResponse])
async def list_personas(
    db: AsyncSession = Depends(get_db_session),
) -> list[PersonaResponse]:
    """List all available personas."""
    manager = PersonaManager(db)
    personas = await manager.get_all_personas()
    return [PersonaResponse.model_validate(p) for p in personas]


@router.get("/{persona_id}", response_model=PersonaResponse)
async def get_persona(
    persona_id: uuid.UUID,
    db: AsyncSession = Depends(get_db_session),
) -> PersonaResponse:
    """Get persona details."""
    manager = PersonaManager(db)
    persona = await manager.get_persona(persona_id)
    if not persona:
        raise NotFoundError("Persona not found")
    return PersonaResponse.model_validate(persona)


@router.post("/initialize-presets", response_model=list[PersonaResponse])
async def initialize_presets(
    db: AsyncSession = Depends(get_db_session),
) -> list[PersonaResponse]:
    """Initialize preset personas (admin)."""
    manager = PersonaManager(db)
    created = await manager.initialize_presets()
    return [PersonaResponse.model_validate(p) for p in created]


# ── User Persona Bindings ──


@router.post("/me/bindings", response_model=UserPersonaBindingResponse)
async def bind_persona(
    body: BindPersonaRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> UserPersonaBindingResponse:
    """Bind a persona to the current user."""
    # Verify persona exists
    manager = PersonaManager(db)
    persona = await manager.get_persona(body.persona_id)
    if not persona:
        raise NotFoundError("Persona not found")

    # Check not already bound
    stmt = select(UserPersonaBinding).where(
        UserPersonaBinding.user_id == uuid.UUID(user_id),
        UserPersonaBinding.persona_id == body.persona_id,
    )
    result = await db.execute(stmt)
    existing = result.scalar_one_or_none()
    if existing:
        return UserPersonaBindingResponse.model_validate(existing)

    binding = UserPersonaBinding(
        user_id=uuid.UUID(user_id),
        persona_id=body.persona_id,
        nickname=body.nickname,
    )
    db.add(binding)
    await db.flush()
    return UserPersonaBindingResponse.model_validate(binding)


@router.get("/me/bindings", response_model=list[UserPersonaBindingResponse])
async def list_my_bindings(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[UserPersonaBindingResponse]:
    """List current user's persona bindings."""
    stmt = (
        select(UserPersonaBinding)
        .where(UserPersonaBinding.user_id == uuid.UUID(user_id))
        .order_by(UserPersonaBinding.is_default.desc(), UserPersonaBinding.created_at)
    )
    result = await db.execute(stmt)
    bindings = list(result.scalars().all())
    return [UserPersonaBindingResponse.model_validate(b) for b in bindings]


@router.put("/me/bindings/{binding_id}/set-default", response_model=UserPersonaBindingResponse)
async def set_default_persona(
    binding_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> UserPersonaBindingResponse:
    """Set a persona binding as the default."""
    uid = uuid.UUID(user_id)

    # Clear existing default
    stmt = select(UserPersonaBinding).where(
        UserPersonaBinding.user_id == uid,
        UserPersonaBinding.is_default.is_(True),
    )
    result = await db.execute(stmt)
    for binding in result.scalars().all():
        binding.is_default = False

    # Set new default
    stmt = select(UserPersonaBinding).where(
        UserPersonaBinding.id == binding_id,
        UserPersonaBinding.user_id == uid,
    )
    result = await db.execute(stmt)
    binding = result.scalar_one_or_none()
    if not binding:
        raise NotFoundError("Binding not found")

    binding.is_default = True
    await db.flush()
    return UserPersonaBindingResponse.model_validate(binding)


# ── Persona Memory ──


@router.get("/{persona_id}/memories", response_model=list[MemoryEntryResponse])
async def get_persona_memories(
    persona_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[MemoryEntryResponse]:
    """Get memories for a persona-user pair."""
    graph = PersonaMemoryGraph(db)
    memories = await graph.get_memories(persona_id, uuid.UUID(user_id))
    return [MemoryEntryResponse.model_validate(m) for m in memories]


@router.post("/{persona_id}/memories", response_model=MemoryEntryResponse)
async def add_persona_memory(
    persona_id: uuid.UUID,
    body: AddMemoryRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> MemoryEntryResponse:
    """Add a memory entry for a persona-user pair."""
    graph = PersonaMemoryGraph(db)
    entry = await graph.add_memory(
        persona_id=persona_id,
        user_id=uuid.UUID(user_id),
        memory_type=body.memory_type,
        content=body.content,
        importance=body.importance,
        context=body.context,
    )
    return MemoryEntryResponse.model_validate(entry)


@router.get("/{persona_id}/commitments", response_model=list[MemoryEntryResponse])
async def get_unfulfilled_commitments(
    persona_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[MemoryEntryResponse]:
    """Get unfulfilled commitments for a persona."""
    graph = PersonaMemoryGraph(db)
    commitments = await graph.get_unfulfilled_commitments(persona_id, uuid.UUID(user_id))
    return [MemoryEntryResponse.model_validate(c) for c in commitments]
