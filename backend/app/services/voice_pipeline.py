"""Voice dialogue pipeline — orchestrates ASR → Emotion → LLM → TTS.

Provides end-to-end voice processing for the companion platform:
  1. Receive audio (base64 or URL) → ASR recognition
  2. Detect emotion from recognized text
  3. Route through chat service (intent → agent → RAG → LLM)
  4. Synthesize TTS with emotion-aware voice parameters
  5. Return audio + metadata (emotion, text, etc.)
"""

import uuid

import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.conversation import ContentType
from app.services.asr_client import ASRClient
from app.services.chat_service import ChatService
from app.services.emotion_detector import EmotionDetector, EmotionResult
from app.services.emotion_expression_mapper import EmotionExpressionMapper
from app.services.tts_client import TTSClient

logger = structlog.get_logger()


class VoicePipelineResult:
    """Result of a full voice dialogue round-trip."""

    def __init__(
        self,
        recognized_text: str,
        response_text: str,
        audio_data: bytes | None,
        emotion: EmotionResult | None,
        voice_params: dict | None = None,
        animation_params: dict | None = None,
        intent: str | None = None,
    ):
        self.recognized_text = recognized_text
        self.response_text = response_text
        self.audio_data = audio_data
        self.emotion = emotion
        self.voice_params = voice_params or {}
        self.animation_params = animation_params or {}
        self.intent = intent


class VoicePipeline:
    """End-to-end voice dialogue orchestrator.

    Flow: Audio → ASR → Emotion Detection → Chat (LLM) → Emotion-aware TTS → Audio
    """

    def __init__(self, db: AsyncSession) -> None:
        self._asr = ASRClient()
        self._tts = TTSClient()
        self._detector = EmotionDetector()
        self._mapper = EmotionExpressionMapper()
        self._chat = ChatService(db)

    async def process_voice(
        self,
        conv_id: uuid.UUID,
        user_id: uuid.UUID,
        audio_base64: str | None = None,
        audio_url: str | None = None,
        speaker: str = "default",
    ) -> VoicePipelineResult:
        """Process a full voice dialogue round-trip.

        Args:
            conv_id: Conversation ID.
            user_id: User ID.
            audio_base64: Base64-encoded audio input.
            audio_url: Audio URL (MinIO presigned).
            speaker: TTS speaker preset.

        Returns:
            VoicePipelineResult with recognized text, response, audio, emotion, etc.
        """
        # Step 1: ASR — Speech to Text
        if audio_base64:
            asr_result = await self._asr.recognize_base64(audio_base64)
        elif audio_url:
            asr_result = await self._asr.recognize_url(audio_url)
        else:
            return VoicePipelineResult(
                recognized_text="",
                response_text="没有收到语音输入，请再试一次。",
                audio_data=None,
                emotion=None,
            )

        recognized_text = asr_result.text
        if not recognized_text.strip():
            return VoicePipelineResult(
                recognized_text="",
                response_text="我没有听清楚，可以再说一遍吗？",
                audio_data=None,
                emotion=None,
            )

        logger.info("voice.asr_done", text_length=len(recognized_text))

        # Step 2: Emotion Detection from recognized text
        emotion = self._detector.detect_from_text(recognized_text)
        logger.info(
            "voice.emotion_detected",
            label=emotion.label.value,
            valence=emotion.valence,
            confidence=emotion.confidence,
        )

        # Step 3: Chat processing (intent → agent → RAG → LLM)
        chat_result = await self._chat.process_message(
            conv_id, user_id, recognized_text, ContentType.VOICE,
        )
        response_text = chat_result.get("content", chat_result.get("message", ""))
        intent = chat_result.get("intent")

        # Step 4: Get emotion-aware voice & animation parameters
        voice_params = self._mapper.get_voice_params(emotion)
        animation_params = self._mapper.get_animation_params(emotion)

        # Step 5: TTS with emotion-aware parameters
        tts_speed = voice_params.get("speed", 1.0)
        try:
            tts_result = await self._tts.synthesize(
                text=response_text,
                speaker=speaker,
                speed=tts_speed,
            )
            audio_data = tts_result.audio_data
        except Exception:
            logger.exception("voice.tts_failed")
            audio_data = None

        logger.info(
            "voice.pipeline_complete",
            has_audio=audio_data is not None,
            emotion=emotion.label.value,
        )

        return VoicePipelineResult(
            recognized_text=recognized_text,
            response_text=response_text,
            audio_data=audio_data,
            emotion=emotion,
            voice_params=voice_params,
            animation_params=animation_params,
            intent=intent,
        )

    async def synthesize_with_emotion(
        self,
        text: str,
        emotion: EmotionResult | None = None,
        speaker: str = "default",
    ) -> tuple[bytes | None, dict]:
        """Synthesize TTS with optional emotion-aware parameters.

        Used for text-only responses that also need voice output.
        """
        if emotion:
            voice_params = self._mapper.get_voice_params(emotion)
        else:
            voice_params = {"speed": 1.0, "pitch": "normal", "energy": "medium"}

        try:
            tts_result = await self._tts.synthesize(
                text=text,
                speaker=speaker,
                speed=voice_params.get("speed", 1.0),
            )
            return tts_result.audio_data, voice_params
        except Exception:
            logger.exception("voice.tts_synthesis_failed")
            return None, voice_params
