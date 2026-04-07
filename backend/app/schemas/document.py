from pydantic import BaseModel
from datetime import datetime

class DocumentOut(BaseModel):
    id: int
    title: str
    file_type: str | None
    created_at: datetime

    model_config = {"from_attributes": True}