"""Voice dialogue API endpoints — speech interaction and TTS synthesis."""

import base64
import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.schemas.voice import (
    TTSSynthesizeRequest,
    TTSSynthesizeResponse,
    VoiceDialogueRequest,
    VoiceDialogueResponse,
)
from app.services.emotion_detector import EmotionDetector, EmotionResult
from app.services.emotion_expression_mapper import EmotionExpressionMapper
from app.services.voice_pipeline import VoicePipeline

router = APIRouter(prefix="/voice", tags=["voice"])


@router.post("/dialogue", response_model=VoiceDialogueResponse)
async def voice_dialogue(
    body: VoiceDialogueRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> VoiceDialogueResponse:
    """Full voice dialogue: audio in → text + audio out with emotion."""
    pipeline = VoicePipeline(db)
    result = await pipeline.process_voice(
        conv_id=body.conversation_id,
        user_id=uuid.UUID(user_id),
        audio_base64=body.audio_base64,
        audio_url=body.audio_url,
        speaker=body.speaker,
    )

    audio_b64 = None
    if result.audio_data:
        audio_b64 = base64.b64encode(result.audio_data).decode("ascii")

    return VoiceDialogueResponse(
        recognized_text=result.recognized_text,
        response_text=result.response_text,
        has_audio=result.audio_data is not None,
        audio_base64=audio_b64,
        emotion_label=result.emotion.label.value if result.emotion else None,
        emotion_valence=result.emotion.valence if result.emotion else None,
        emotion_arousal=result.emotion.arousal if result.emotion else None,
        emotion_confidence=result.emotion.confidence if result.emotion else None,
        voice_params=result.voice_params,
        animation_params=result.animation_params,
        intent=result.intent,
    )


@router.post("/synthesize", response_model=TTSSynthesizeResponse)
async def synthesize_speech(
    body: TTSSynthesizeRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> TTSSynthesizeResponse:
    """Synthesize TTS with optional emotion-aware voice parameters."""
    pipeline = VoicePipeline(db)

    emotion: EmotionResult | None = None
    if body.emotion_label:
        detector = EmotionDetector()
        emotion = detector.detect_from_text(body.emotion_label)

    audio_data, voice_params = await pipeline.synthesize_with_emotion(
        text=body.text,
        emotion=emotion,
        speaker=body.speaker,
    )

    audio_b64 = None
    if audio_data:
        audio_b64 = base64.b64encode(audio_data).decode("ascii")

    return TTSSynthesizeResponse(
        has_audio=audio_data is not None,
        audio_base64=audio_b64,
        voice_params=voice_params,
    )


@router.get("/expression-params")
async def get_expression_params(
    text: str,
) -> dict:
    """Get emotion expression parameters for given text (for frontend animation)."""
    detector = EmotionDetector()
    mapper = EmotionExpressionMapper()
    emotion = detector.detect_from_text(text)
    return mapper.get_all_params(emotion)
