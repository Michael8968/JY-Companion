"""Chat API — REST endpoints for conversation management + WebSocket for real-time chat."""

import uuid

import orjson
import structlog
from fastapi import APIRouter, Depends, Query, WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user_id, get_db_session
from app.core.exceptions import NotFoundError
from app.core.security import decode_token
from app.models.conversation import ContentType
from app.schemas.chat import (
    ConversationResponse,
    CreateConversationRequest,
    MessageListResponse,
    MessageResponse,
)
from app.services.chat_service import ChatService

logger = structlog.get_logger()

router = APIRouter(prefix="/chat", tags=["chat"])


# ---- REST: Conversation management ----


@router.post("/conversations", response_model=ConversationResponse)
async def create_conversation(
    body: CreateConversationRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> ConversationResponse:
    service = ChatService(db)
    conv = await service.create_conversation(
        user_id=uuid.UUID(user_id),
        agent_type=body.agent_type,
        persona_id=body.persona_id,
        title=body.title,
    )
    return ConversationResponse.model_validate(conv)


@router.get("/conversations", response_model=list[ConversationResponse])
async def list_conversations(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> list[ConversationResponse]:
    service = ChatService(db)
    convs, _total = await service.list_conversations(uuid.UUID(user_id), page=page, size=size)
    return [ConversationResponse.model_validate(c) for c in convs]


@router.get("/conversations/{conv_id}/messages", response_model=MessageListResponse)
async def get_conversation_messages(
    conv_id: uuid.UUID,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> MessageListResponse:
    service = ChatService(db)
    conv = await service.get_conversation(conv_id, uuid.UUID(user_id))
    if not conv:
        raise NotFoundError("Conversation not found")
    messages, total = await service.get_messages(conv_id, page=page, size=size)
    return MessageListResponse(
        messages=[MessageResponse.model_validate(m) for m in messages],
        total=total,
        page=page,
        size=size,
    )


@router.delete("/conversations/{conv_id}", status_code=204)
async def delete_conversation(
    conv_id: uuid.UUID,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db_session),
) -> None:
    service = ChatService(db)
    deleted = await service.delete_conversation(conv_id, uuid.UUID(user_id))
    if not deleted:
        raise NotFoundError("Conversation not found")


# ---- WebSocket: Real-time streaming chat ----


@router.websocket("/ws")
async def websocket_chat(ws: WebSocket, token: str = Query(...), db: AsyncSession = Depends(get_db_session)):
    """WebSocket endpoint for real-time streaming chat.

    Connect: WS /api/v1/chat/ws?token={jwt}
    Send: {"type": "message", "conversation_id": "...", "content": "...", "content_type": "text"}
    Receive: {"type": "connected|stream_start|stream_chunk|stream_end|error", "data": {...}}
    """
    # Authenticate via token query param
    payload = decode_token(token)
    if payload is None:
        await ws.close(code=4001, reason="Invalid token")
        return

    user_id = payload.get("sub")
    if not user_id:
        await ws.close(code=4001, reason="Invalid token")
        return

    await ws.accept()
    await _ws_send(ws, "connected", {"user_id": user_id})
    await logger.ainfo("ws.connected", user_id=user_id)

    try:
        while True:
            raw = await ws.receive_text()
            try:
                msg = orjson.loads(raw)
            except orjson.JSONDecodeError:
                await _ws_send(ws, "error", {"message": "Invalid JSON"})
                continue

            msg_type = msg.get("type", "message")
            if msg_type == "ping":
                await _ws_send(ws, "pong", {})
                continue

            if msg_type != "message":
                await _ws_send(ws, "error", {"message": f"Unknown message type: {msg_type}"})
                continue

            conv_id_str = msg.get("conversation_id")
            content = msg.get("content", "")
            content_type_str = msg.get("content_type", "text")

            if not conv_id_str or not content:
                await _ws_send(ws, "error", {"message": "conversation_id and content are required"})
                continue

            try:
                conv_id = uuid.UUID(conv_id_str)
                content_type = ContentType(content_type_str)
            except (ValueError, KeyError):
                await _ws_send(ws, "error", {"message": "Invalid conversation_id or content_type"})
                continue

            service = ChatService(db)
            async for event_type, data in service.process_message_stream(
                conv_id, uuid.UUID(user_id), content, content_type
            ):
                await _ws_send(ws, event_type, data)

    except WebSocketDisconnect:
        await logger.ainfo("ws.disconnected", user_id=user_id)


async def _ws_send(ws: WebSocket, event_type: str, data: dict) -> None:
    await ws.send_text(orjson.dumps({"type": event_type, "data": data}).decode())
