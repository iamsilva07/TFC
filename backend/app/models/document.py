from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text, func
from app.db.database import Base

class Document(Base):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=True)
    file_type = Column(String(10), nullable=True)
    created_at = Column(DateTime, server_default=func.now())