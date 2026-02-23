"""Vector embedding service — wraps a remote embedding API (BGE-large-zh)."""

import httpx
import structlog

from app.config.settings import get_settings

settings = get_settings()
logger = structlog.get_logger()


class EmbeddingService:
    """Client for the embedding microservice.

    Expected API (OpenAI-compatible):
        POST /v1/embeddings
        {"model": "bge-large-zh", "input": ["text1", "text2"]}
        → {"data": [{"embedding": [0.1, ...], "index": 0}, ...]}
    """

    def __init__(self, base_url: str | None = None):
        self.base_url = (base_url or settings.rag_service_url).rstrip("/")

    async def embed(self, texts: list[str], model: str = "bge-large-zh") -> list[list[float]]:
        """Get embeddings for a list of texts."""
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                f"{self.base_url}/v1/embeddings",
                json={"model": model, "input": texts},
            )
            resp.raise_for_status()
            result = resp.json()
        return [item["embedding"] for item in sorted(result["data"], key=lambda x: x["index"])]

    async def embed_single(self, text: str, model: str = "bge-large-zh") -> list[float]:
        """Get embedding for a single text."""
        embeddings = await self.embed([text], model)
        return embeddings[0]

    async def health_check(self) -> bool:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(f"{self.base_url}/health")
                return resp.status_code == 200
        except httpx.HTTPError:
            return False
