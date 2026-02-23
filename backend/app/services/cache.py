"""Redis-based caching service for performance optimization.

Provides:
  - Key-value cache with TTL for frequently accessed data
  - Conversation context caching (reduce DB reads)
  - RAG result caching (avoid redundant vector searches)
  - Rate limiting counters
"""

import hashlib
import json

import structlog

from app.config.settings import get_settings

logger = structlog.get_logger()

# Default TTL values (seconds)
TTL_SHORT = 60  # 1 minute — rate counters, temp data
TTL_MEDIUM = 300  # 5 minutes — conversation context, user sessions
TTL_LONG = 3600  # 1 hour — RAG results, persona data
TTL_VERY_LONG = 86400  # 24 hours — static resources, knowledge base


class CacheService:
    """Redis cache abstraction for the companion platform.

    Provides typed get/set with automatic JSON serialization,
    namespace isolation, and TTL management.
    """

    def __init__(self) -> None:
        self._redis = None
        self._prefix = "jy:"

    async def _get_redis(self):
        """Lazy-init Redis connection."""
        if self._redis is None:
            import redis.asyncio as aioredis
            settings = get_settings()
            self._redis = aioredis.from_url(
                settings.redis_url,
                decode_responses=True,
                max_connections=20,
            )
        return self._redis

    def _key(self, namespace: str, key: str) -> str:
        """Build namespaced cache key."""
        return f"{self._prefix}{namespace}:{key}"

    async def get(self, namespace: str, key: str) -> dict | list | str | None:
        """Get cached value (auto-deserialized from JSON)."""
        r = await self._get_redis()
        raw = await r.get(self._key(namespace, key))
        if raw is None:
            return None
        try:
            return json.loads(raw)
        except (json.JSONDecodeError, TypeError):
            return raw

    async def set(
        self,
        namespace: str,
        key: str,
        value: dict | list | str,
        ttl: int = TTL_MEDIUM,
    ) -> None:
        """Set cached value with TTL (auto-serialized to JSON)."""
        r = await self._get_redis()
        serialized = json.dumps(value, ensure_ascii=False) if not isinstance(value, str) else value
        await r.set(self._key(namespace, key), serialized, ex=ttl)

    async def delete(self, namespace: str, key: str) -> None:
        """Delete a cached key."""
        r = await self._get_redis()
        await r.delete(self._key(namespace, key))

    async def exists(self, namespace: str, key: str) -> bool:
        """Check if key exists in cache."""
        r = await self._get_redis()
        return bool(await r.exists(self._key(namespace, key)))

    # ── Convenience methods for common patterns ──

    async def get_conversation_context(self, conv_id: str) -> list[dict] | None:
        """Get cached conversation context messages."""
        return await self.get("conv_ctx", conv_id)

    async def set_conversation_context(
        self, conv_id: str, messages: list[dict], ttl: int = TTL_MEDIUM,
    ) -> None:
        """Cache conversation context messages."""
        await self.set("conv_ctx", conv_id, messages, ttl)

    async def get_rag_result(self, query: str) -> str | None:
        """Get cached RAG retrieval result."""
        key = hashlib.md5(query.encode()).hexdigest()  # noqa: S324
        return await self.get("rag", key)

    async def set_rag_result(self, query: str, result: str, ttl: int = TTL_LONG) -> None:
        """Cache RAG retrieval result."""
        key = hashlib.md5(query.encode()).hexdigest()  # noqa: S324
        await self.set("rag", key, result, ttl)

    async def get_persona(self, persona_id: str) -> dict | None:
        """Get cached persona data."""
        return await self.get("persona", persona_id)

    async def set_persona(self, persona_id: str, data: dict, ttl: int = TTL_LONG) -> None:
        """Cache persona data."""
        await self.set("persona", persona_id, data, ttl)

    async def increment_counter(self, namespace: str, key: str, ttl: int = TTL_SHORT) -> int:
        """Increment and return a counter (for rate limiting)."""
        r = await self._get_redis()
        full_key = self._key(namespace, key)
        pipe = r.pipeline()
        pipe.incr(full_key)
        pipe.expire(full_key, ttl)
        results = await pipe.execute()
        return results[0]

    async def health_check(self) -> bool:
        """Check Redis connectivity."""
        try:
            r = await self._get_redis()
            return await r.ping()
        except Exception:
            return False
