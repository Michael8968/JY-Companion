import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.conversation import AgentType, ContentType, MessageRole


class CreateConversationRequest(BaseModel):
    agent_type: AgentType
    persona_id: uuid.UUID | None = None
    title: str | None = None


class ConversationResponse(BaseModel):
    id: uuid.UUID
    agent_type: AgentType
    persona_id: uuid.UUID | None = None
    title: str | None = None
    status: str
    message_count: int
    last_message_at: datetime | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class MessageResponse(BaseModel):
    id: uuid.UUID
    role: MessageRole
    content_type: ContentType
    content: str
    emotion_label: str | None = None
    intent_label: str | None = None
    token_count: int | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class MessageListResponse(BaseModel):
    messages: list[MessageResponse]
    total: int
    page: int
    size: int


# WebSocket message schemas
class WSIncomingMessage(BaseModel):
    type: str = "message"
    conversation_id: uuid.UUID
    content: str
    content_type: ContentType = ContentType.TEXT
    attachments: list[str] | None = None


class WSOutgoingMessage(BaseModel):
    type: str
    data: dict = Field(default_factory=dict)
