from pydantic import BaseModel
from datetime import datetime

class DocumentOut(BaseModel):
    id: int
    title: str
    file_type: str | None
    created_at: datetime

    model_config = {"from_attributes": True}

class ChatRequest(BaseModel):
    question: str
    doc_id : int | None = None

class ChatResponse(BaseModel):
    answer: str
    sources: list[str] = []

class ChatMessageOut(BaseModel):
    id: int
    question: str
    answer: str
    document_id: int | None
    created_at: datetime

    model_config = {"from_attributes": True}