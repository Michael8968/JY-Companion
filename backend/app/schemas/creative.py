"""Schemas for creative writing API."""

from pydantic import BaseModel


class GenerateRequest(BaseModel):
    topic: str
    style: str | None = None


class GenerateResponse(BaseModel):
    content: str
    topic: str
    style: str | None = None


class OptimizeRequest(BaseModel):
    text: str


class OptimizeResponse(BaseModel):
    suggestions: str
    original_length: int


class EvaluateRequest(BaseModel):
    text: str
    genre: str | None = None


class EvaluateResponse(BaseModel):
    evaluation: str
    genre: str | None = None


class BrainstormRequest(BaseModel):
    context: str
    stuck_point: str | None = None


class BrainstormResponse(BaseModel):
    inspiration: str
