import os
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.user import User
from app.models.document import Document
from app.models.chat import ChatMessage
from app.schemas.document import DocumentOut, ChatRequest, ChatResponse, ChatMessageOut
from app.api.deps import get_current_user
from app.services import rag

router = APIRouter(prefix="/documents", tags=["documents"])

UPLOAD_DIR = "./uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload", response_model=DocumentOut, status_code=201)
async def upload_document(
    file:UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    extension = file.filename.split(".")[-1].lower()
    if extension not in ["pdf", "docx", "txt"]:
        raise HTTPException(status_code=400, detail="Solo se admiten PDF, DOCX y TXT")

    file_path = f"{UPLOAD_DIR}/{current_user.id}_{file.filename}"
    with open (file_path, "wb") as f:
        f.write(await file.read())

    doc = Document(
        user_id = current_user.id,
        title = file.filename.rsplit(".", 1)[0],
        file_path = file_path,
        file_type = extension
    )
    db.add(doc)
    db.commit() 
    db.refresh(doc)

    text = rag.extract_text(file_path, extension)
    rag.index_document(current_user.id, doc.id, text, doc.title)

    return doc

@router.get("/", response_model=list[DocumentOut])
def list_documents(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(Document).filter(Document.user_id == current_user.id).all()


@router.delete("/{doc_id}", status_code=204)
def delete_document(
    doc_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    doc = db.query(Document).filter(
        Document.id == doc_id,
        Document.user_id == current_user.id
    ).first
    if not doc:
        raise HTTPException(status_code=404, detail="Documento no encontrado")
    db.delete(doc)
    db.commit()

@router.post("/chat", response_model=ChatResponse)
def chat(
    request: ChatRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    context, sources = rag.search_documents(current_user.id, request.question, request.doc_id)
    answer = rag.ask(context, request.question)
 

    message = ChatMessage(
        user_id = current_user.id,
        document_id = request.doc_id,
        question = request.question,
        answer=answer
    )
    db.add(message)
    db.commit()

    return ChatResponse(answer=answer, sources=sources)

@router.get("/chat/history", response_model=list[ChatMessageOut])
def get_chat_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(ChatMessage).filter(
        ChatMessage.user_id == current_user.id
    ).order_by(ChatMessage.created_at).all()

