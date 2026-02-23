import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.user import UserRole


class UserCreate(BaseModel):
    username: str = Field(min_length=2, max_length=50)
    password: str = Field(min_length=6, max_length=128)
    display_name: str = Field(min_length=1, max_length=100)
    role: UserRole = UserRole.STUDENT
    email: str | None = None
    phone: str | None = None
    grade: str | None = None
    class_name: str | None = None
    student_id: str | None = None


class UserResponse(BaseModel):
    id: uuid.UUID
    username: str
    display_name: str
    role: UserRole
    email: str | None = None
    avatar_url: str | None = None
    grade: str | None = None
    class_name: str | None = None
    student_id: str | None = None
    last_login_at: datetime | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class UserUpdate(BaseModel):
    display_name: str | None = None
    email: str | None = None
    phone: str | None = None
    avatar_url: str | None = None
    grade: str | None = None
    class_name: str | None = None


class UserProfileResponse(BaseModel):
    learning_style: dict | None = None
    ability_scores: dict | None = None
    interest_tags: dict | None = None
    emotion_baseline: dict | None = None

    model_config = {"from_attributes": True}
