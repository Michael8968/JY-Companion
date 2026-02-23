"""Creative writing API endpoints."""

from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user_id
from app.schemas.creative import (
    BrainstormRequest,
    BrainstormResponse,
    EvaluateRequest,
    EvaluateResponse,
    GenerateRequest,
    GenerateResponse,
    OptimizeRequest,
    OptimizeResponse,
)
from app.services.creative_service import CreativeService

router = APIRouter(prefix="/creative", tags=["creative"])


@router.post("/generate", response_model=GenerateResponse)
async def generate_creative(
    body: GenerateRequest,
    user_id: str = Depends(get_current_user_id),
) -> GenerateResponse:
    """Generate creative writing (story outline + opening paragraph)."""
    service = CreativeService()
    result = await service.generate_story(body.topic, style=body.style)
    return GenerateResponse(**result)


@router.post("/optimize", response_model=OptimizeResponse)
async def optimize_writing(
    body: OptimizeRequest,
    user_id: str = Depends(get_current_user_id),
) -> OptimizeResponse:
    """Optimize a writing draft with suggestions."""
    service = CreativeService()
    result = await service.optimize_writing(body.text)
    return OptimizeResponse(**result)


@router.post("/evaluate", response_model=EvaluateResponse)
async def evaluate_work(
    body: EvaluateRequest,
    user_id: str = Depends(get_current_user_id),
) -> EvaluateResponse:
    """Evaluate a creative work across 5 dimensions."""
    service = CreativeService()
    result = await service.evaluate_work(body.text, genre=body.genre)
    return EvaluateResponse(**result)


@router.post("/brainstorm", response_model=BrainstormResponse)
async def brainstorm_inspiration(
    body: BrainstormRequest,
    user_id: str = Depends(get_current_user_id),
) -> BrainstormResponse:
    """Help overcome creative blocks with brainstorming."""
    service = CreativeService()
    result = await service.brainstorm_inspiration(body.context, stuck_point=body.stuck_point)
    return BrainstormResponse(**result)
