"""Academic tutoring API endpoints."""

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.models.learning import Subject
from app.schemas.academic import (
    CreateLearningRecordRequest,
    DiagnoseErrorRequest,
    ErrorBookResponse,
    ErrorRecordResponse,
    LearningRecordResponse,
    RecommendExercisesRequest,
    RecommendExercisesResponse,
)
from app.services.academic_service import AcademicService

router = APIRouter(prefix="/academic", tags=["academic"])


@router.post("/learning-records", response_model=LearningRecordResponse)
async def create_learning_record(
    body: CreateLearningRecordRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> LearningRecordResponse:
    service = AcademicService(db)
    record = await service.create_learning_record(
        user_id=uuid.UUID(user_id),
        subject=body.subject,
        question=body.question,
        answer=body.answer,
        knowledge_points=body.knowledge_points,
        difficulty=body.difficulty,
        is_correct=body.is_correct,
        conversation_id=body.conversation_id,
    )
    return LearningRecordResponse.model_validate(record)


@router.get("/learning-records", response_model=list[LearningRecordResponse])
async def list_learning_records(
    subject: Subject | None = None,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[LearningRecordResponse]:
    service = AcademicService(db)
    records, _total = await service.get_learning_records(
        uuid.UUID(user_id), subject=subject, page=page, size=size
    )
    return [LearningRecordResponse.model_validate(r) for r in records]


@router.post("/diagnose", response_model=ErrorRecordResponse)
async def diagnose_error(
    body: DiagnoseErrorRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ErrorRecordResponse:
    service = AcademicService(db)
    record = await service.diagnose_error(
        user_id=uuid.UUID(user_id),
        learning_record_id=body.learning_record_id,
        subject=body.subject,
        question=body.question,
        wrong_answer=body.wrong_answer,
    )
    return ErrorRecordResponse.model_validate(record)


@router.get("/error-book", response_model=ErrorBookResponse)
async def get_error_book(
    subject: Subject | None = None,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ErrorBookResponse:
    service = AcademicService(db)
    errors, total = await service.get_error_book(
        uuid.UUID(user_id), subject=subject, page=page, size=size
    )
    return ErrorBookResponse(
        errors=[ErrorRecordResponse.model_validate(e) for e in errors],
        total=total,
        page=page,
        size=size,
    )


@router.post("/error-book/{error_id}/review", response_model=ErrorRecordResponse)
async def review_error(
    error_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ErrorRecordResponse:
    """Mark an error as reviewed, incrementing review count and updating mastery."""
    service = AcademicService(db)
    record = await service.update_mastery(error_id, uuid.UUID(user_id))
    if not record:
        from app.core.exceptions import NotFoundError

        raise NotFoundError("Error record not found")
    return ErrorRecordResponse.model_validate(record)


@router.post("/recommend-exercises", response_model=RecommendExercisesResponse)
async def recommend_exercises(
    body: RecommendExercisesRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> RecommendExercisesResponse:
    service = AcademicService(db)
    content = await service.recommend_exercises(
        subject=body.subject,
        knowledge_points=body.knowledge_points,
        mastery_level=body.mastery_level,
    )
    return RecommendExercisesResponse(content=content)
