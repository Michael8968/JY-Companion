"""LLM API client wrapping vLLM-compatible OpenAI endpoints."""

from collections.abc import AsyncGenerator

import httpx
import orjson
import structlog

from app.config.settings import get_settings

settings = get_settings()
logger = structlog.get_logger()


class LLMClient:
    """Client for vLLM inference service (OpenAI-compatible API)."""

    def __init__(self, base_url: str | None = None):
        self.base_url = (base_url or settings.llm_service_url).rstrip("/")

    async def generate(
        self,
        messages: list[dict[str, str]],
        *,
        model: str = "InnoSpark-1.0",
        temperature: float = 0.7,
        max_tokens: int = 2048,
        top_p: float = 0.9,
    ) -> dict:
        """Non-streaming completion."""
        payload = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "top_p": top_p,
            "stream": False,
        }
        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(f"{self.base_url}/v1/chat/completions", json=payload)
            resp.raise_for_status()
            result = resp.json()
        choice = result["choices"][0]
        return {
            "content": choice["message"]["content"],
            "usage": result.get("usage", {}),
            "finish_reason": choice.get("finish_reason"),
        }

    async def generate_stream(
        self,
        messages: list[dict[str, str]],
        *,
        model: str = "InnoSpark-1.0",
        temperature: float = 0.7,
        max_tokens: int = 2048,
        top_p: float = 0.9,
    ) -> AsyncGenerator[str, None]:
        """Streaming completion — yields text chunks."""
        payload = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "top_p": top_p,
            "stream": True,
        }
        async with (
            httpx.AsyncClient(timeout=120.0) as client,
            client.stream("POST", f"{self.base_url}/v1/chat/completions", json=payload) as resp,
        ):
            resp.raise_for_status()
            async for line in resp.aiter_lines():
                if not line.startswith("data: "):
                    continue
                data = line[6:]
                if data.strip() == "[DONE]":
                    break
                chunk = orjson.loads(data)
                delta = chunk["choices"][0].get("delta", {})
                text = delta.get("content")
                if text:
                    yield text

    async def health_check(self) -> bool:
        """Check if vLLM service is reachable."""
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(f"{self.base_url}/health")
                return resp.status_code == 200
        except httpx.HTTPError:
            return False
