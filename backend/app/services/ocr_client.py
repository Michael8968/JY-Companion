"""OCR service client — wraps PaddleOCR microservice for text extraction."""

import httpx
import structlog

from app.config.settings import get_settings

settings = get_settings()
logger = structlog.get_logger()


class OCRClient:
    """Client for PaddleOCR microservice.

    Expected API:
        POST /ocr/recognize
        {"image": "<base64-encoded-image>"}
        → {"texts": [{"text": "...", "confidence": 0.98, "bbox": [...]}], "full_text": "..."}
    """

    def __init__(self, base_url: str | None = None):
        self.base_url = (base_url or "http://localhost:8866").rstrip("/")

    async def recognize(self, image_base64: str) -> dict:
        """Extract text from a base64-encoded image.

        Returns dict with keys: texts (list of detected text blocks), full_text (concatenated).
        """
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                f"{self.base_url}/ocr/recognize",
                json={"image": image_base64},
            )
            resp.raise_for_status()
            return resp.json()

    async def recognize_to_text(self, image_base64: str) -> str:
        """Extract and return concatenated text from image."""
        result = await self.recognize(image_base64)
        return result.get("full_text", "")

    async def health_check(self) -> bool:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(f"{self.base_url}/health")
                return resp.status_code == 200
        except httpx.HTTPError:
            return False
