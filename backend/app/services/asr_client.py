"""ASR service client — wraps FunASR (Paraformer-large) microservice."""

import httpx
import structlog

from app.config.settings import get_settings

settings = get_settings()
logger = structlog.get_logger()


class ASRResult:
    def __init__(self, text: str, segments: list[dict] | None = None):
        self.text = text
        self.segments = segments or []


class ASRClient:
    """Client for FunASR speech recognition microservice.

    Expected API:
        POST /asr/recognize
        {"audio_url": "minio://bucket/path.wav"} or {"audio_base64": "..."}
        → {"text": "...", "segments": [{"start": 0.0, "end": 2.5, "text": "...", "confidence": 0.96}]}
    """

    def __init__(self, base_url: str | None = None):
        self.base_url = (base_url or "http://localhost:8867").rstrip("/")

    async def recognize_url(self, audio_url: str) -> ASRResult:
        """Recognize speech from an audio URL (e.g., MinIO presigned URL)."""
        async with httpx.AsyncClient(timeout=300.0) as client:
            resp = await client.post(
                f"{self.base_url}/asr/recognize",
                json={"audio_url": audio_url},
            )
            resp.raise_for_status()
            data = resp.json()
        return ASRResult(text=data.get("text", ""), segments=data.get("segments", []))

    async def recognize_base64(self, audio_base64: str) -> ASRResult:
        """Recognize speech from base64-encoded audio."""
        async with httpx.AsyncClient(timeout=300.0) as client:
            resp = await client.post(
                f"{self.base_url}/asr/recognize",
                json={"audio_base64": audio_base64},
            )
            resp.raise_for_status()
            data = resp.json()
        return ASRResult(text=data.get("text", ""), segments=data.get("segments", []))

    async def health_check(self) -> bool:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(f"{self.base_url}/health")
                return resp.status_code == 200
        except httpx.HTTPError:
            return False
