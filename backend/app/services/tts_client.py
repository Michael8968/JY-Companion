"""CosyVoice TTS (Text-to-Speech) client for voice synthesis."""

import structlog

from app.config.settings import get_settings

logger = structlog.get_logger()


class TTSResult:
    """Result from TTS synthesis."""

    def __init__(self, audio_data: bytes, sample_rate: int = 22050, audio_format: str = "wav"):
        self.audio_data = audio_data
        self.sample_rate = sample_rate
        self.audio_format = audio_format


class TTSClient:
    """Client for CosyVoice TTS service.

    CosyVoice supports:
    - Zero-shot voice cloning
    - Cross-lingual synthesis
    - Multiple speaker presets
    """

    def __init__(self, base_url: str | None = None) -> None:
        settings = get_settings()
        self._base_url = (base_url or getattr(settings, "tts_service_url", "http://localhost:8090")).rstrip("/")

    async def synthesize(
        self,
        text: str,
        speaker: str = "default",
        speed: float = 1.0,
    ) -> TTSResult:
        """Synthesize speech from text.

        Args:
            text: Text to synthesize.
            speaker: Speaker preset name.
            speed: Speech speed multiplier (0.5-2.0).
        """
        import httpx

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{self._base_url}/api/v1/tts",
                json={
                    "text": text,
                    "speaker": speaker,
                    "speed": speed,
                },
            )
            response.raise_for_status()
            audio_data = response.content

        logger.info(
            "tts.synthesized",
            text_length=len(text),
            speaker=speaker,
            audio_bytes=len(audio_data),
        )
        return TTSResult(audio_data=audio_data)

    async def get_speakers(self) -> list[str]:
        """List available speaker presets."""
        import httpx

        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(f"{self._base_url}/api/v1/speakers")
            response.raise_for_status()
            return response.json().get("speakers", [])
