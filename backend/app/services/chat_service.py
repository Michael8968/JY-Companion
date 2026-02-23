"""ChatService — context management, history loading, streaming generation."""

import uuid
from datetime import UTC, datetime

import structlog
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.conversation import AgentType, ContentType, Conversation, Message, MessageRole
from app.services.content_safety import ContentSafetyFilter, ContentSafetyLevel
from app.services.llm_client import LLMClient
from app.services.prompt_manager import PromptManager

logger = structlog.get_logger()

# Max history messages sent to LLM as context
MAX_CONTEXT_MESSAGES = 20


class ChatService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.llm = LLMClient()
        self.prompt_manager = PromptManager()
        self.safety_filter = ContentSafetyFilter()

    # ---- Conversation CRUD ----

    async def create_conversation(
        self,
        user_id: uuid.UUID,
        agent_type: AgentType,
        persona_id: uuid.UUID | None = None,
        title: str | None = None,
    ) -> Conversation:
        conv = Conversation(
            user_id=user_id,
            agent_type=agent_type,
            persona_id=persona_id,
            title=title,
        )
        self.db.add(conv)
        await self.db.flush()
        await logger.ainfo("conversation.created", conv_id=str(conv.id), agent=agent_type)
        return conv

    async def get_conversation(self, conv_id: uuid.UUID, user_id: uuid.UUID) -> Conversation | None:
        result = await self.db.execute(
            select(Conversation).where(Conversation.id == conv_id, Conversation.user_id == user_id)
        )
        return result.scalar_one_or_none()

    async def list_conversations(
        self, user_id: uuid.UUID, *, page: int = 1, size: int = 20
    ) -> tuple[list[Conversation], int]:
        count_q = select(func.count()).select_from(Conversation).where(Conversation.user_id == user_id)
        total = (await self.db.execute(count_q)).scalar() or 0

        q = (
            select(Conversation)
            .where(Conversation.user_id == user_id)
            .order_by(Conversation.updated_at.desc())
            .offset((page - 1) * size)
            .limit(size)
        )
        rows = (await self.db.execute(q)).scalars().all()
        return list(rows), total

    async def delete_conversation(self, conv_id: uuid.UUID, user_id: uuid.UUID) -> bool:
        conv = await self.get_conversation(conv_id, user_id)
        if not conv:
            return False
        await self.db.delete(conv)
        await self.db.flush()
        return True

    # ---- Message history ----

    async def get_messages(
        self, conv_id: uuid.UUID, *, page: int = 1, size: int = 20
    ) -> tuple[list[Message], int]:
        count_q = select(func.count()).select_from(Message).where(Message.conversation_id == conv_id)
        total = (await self.db.execute(count_q)).scalar() or 0

        q = (
            select(Message)
            .where(Message.conversation_id == conv_id)
            .order_by(Message.created_at.desc())
            .offset((page - 1) * size)
            .limit(size)
        )
        rows = (await self.db.execute(q)).scalars().all()
        return list(rows), total

    async def _load_context_messages(self, conv_id: uuid.UUID) -> list[dict[str, str]]:
        """Load recent messages as LLM context."""
        q = (
            select(Message)
            .where(Message.conversation_id == conv_id)
            .order_by(Message.created_at.desc())
            .limit(MAX_CONTEXT_MESSAGES)
        )
        rows = (await self.db.execute(q)).scalars().all()
        # Reverse so oldest first
        rows = list(reversed(rows))
        return [{"role": msg.role.value, "content": msg.content} for msg in rows]

    # ---- Save message helpers ----

    async def _save_message(
        self,
        conv_id: uuid.UUID,
        role: MessageRole,
        content: str,
        content_type: ContentType = ContentType.TEXT,
        token_count: int | None = None,
        is_flagged: bool = False,
    ) -> Message:
        msg = Message(
            conversation_id=conv_id,
            role=role,
            content_type=content_type,
            content=content,
            token_count=token_count,
            is_flagged=is_flagged,
        )
        self.db.add(msg)

        # Update conversation stats
        result = await self.db.execute(select(Conversation).where(Conversation.id == conv_id))
        conv = result.scalar_one_or_none()
        if conv:
            conv.message_count += 1
            conv.last_message_at = datetime.now(UTC)

        await self.db.flush()
        return msg

    # ---- Core chat flow ----

    async def process_message(
        self,
        conv_id: uuid.UUID,
        user_id: uuid.UUID,
        content: str,
        content_type: ContentType = ContentType.TEXT,
    ) -> dict:
        """Non-streaming message processing. Returns full response."""
        conv = await self.get_conversation(conv_id, user_id)
        if not conv:
            return {"error": "Conversation not found"}

        # 1. Content safety pre-check (fast path, <100ms)
        safety_result = self.safety_filter.check(content)
        if safety_result.is_crisis:
            await self._save_message(conv_id, MessageRole.USER, content, content_type, is_flagged=True)
            return {
                "type": "crisis_alert",
                "message": "我注意到你可能正在经历困难。请记住，你并不孤单。如果你需要帮助，请联系学校心理咨询师或拨打心理援助热线。",
            }
        if safety_result.level == ContentSafetyLevel.BLOCKED:
            return {"type": "blocked", "message": "抱歉，你的消息包含不适当的内容，请修改后重试。"}

        # 2. Save user message
        await self._save_message(conv_id, MessageRole.USER, content, content_type)

        # 3. Build LLM context
        history = await self._load_context_messages(conv_id)
        messages = self.prompt_manager.build_messages(conv.agent_type, history, content)

        # 4. LLM generation
        try:
            result = self.llm.generate(messages)
            llm_response = await result
        except Exception:
            await logger.aexception("llm.generate_failed", conv_id=str(conv_id))
            return {"type": "error", "message": "AI 服务暂时不可用，请稍后重试。"}

        assistant_content = llm_response["content"]

        # 5. Output safety check
        output_safety = self.safety_filter.check_output(assistant_content)
        if not output_safety.is_safe:
            assistant_content = "抱歉，我无法生成合适的回答，请换个话题吧。"

        # 6. Save assistant message
        usage = llm_response.get("usage", {})
        token_count = usage.get("completion_tokens")
        await self._save_message(conv_id, MessageRole.ASSISTANT, assistant_content, token_count=token_count)

        return {
            "type": "message",
            "content": assistant_content,
            "usage": usage,
        }

    async def process_message_stream(
        self,
        conv_id: uuid.UUID,
        user_id: uuid.UUID,
        content: str,
        content_type: ContentType = ContentType.TEXT,
    ):
        """Streaming message processing. Yields (event_type, data) tuples."""
        conv = await self.get_conversation(conv_id, user_id)
        if not conv:
            yield "error", {"message": "Conversation not found"}
            return

        # 1. Content safety pre-check
        safety_result = self.safety_filter.check(content)
        if safety_result.is_crisis:
            await self._save_message(conv_id, MessageRole.USER, content, content_type, is_flagged=True)
            yield "crisis_alert", {
                "message": "我注意到你可能正在经历困难。请记住，你并不孤单。如果你需要帮助，请联系学校心理咨询师或拨打心理援助热线。"
            }
            return
        if safety_result.level == ContentSafetyLevel.BLOCKED:
            yield "blocked", {"message": "抱歉，你的消息包含不适当的内容，请修改后重试。"}
            return

        # 2. Save user message
        await self._save_message(conv_id, MessageRole.USER, content, content_type)

        # 3. Build LLM context
        history = await self._load_context_messages(conv_id)
        messages = self.prompt_manager.build_messages(conv.agent_type, history, content)

        # 4. Stream LLM response
        yield "stream_start", {}

        full_response = []
        try:
            async for chunk in self.llm.generate_stream(messages):
                full_response.append(chunk)
                yield "stream_chunk", {"content": chunk}
        except Exception:
            await logger.aexception("llm.stream_failed", conv_id=str(conv_id))
            yield "error", {"message": "AI 服务暂时不可用，请稍后重试。"}
            return

        assistant_content = "".join(full_response)

        # 5. Output safety check
        output_safety = self.safety_filter.check_output(assistant_content)
        if not output_safety.is_safe:
            assistant_content = "抱歉，我无法生成合适的回答，请换个话题吧。"

        # 6. Save assistant message
        await self._save_message(conv_id, MessageRole.ASSISTANT, assistant_content)

        yield "stream_end", {"token_count": len(assistant_content)}
