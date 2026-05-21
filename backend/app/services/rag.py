import os
import chromadb
from chromadb.utils.embedding_functions import DefaultEmbeddingFunction
from groq import Groq
from app.core.config import settings

client = Groq(api_key=settings.GROQ_API_KEY)

chroma_client = chromadb.PersistentClient(path="./chroma_data")
embedding_fn = DefaultEmbeddingFunction()

def extract_text(file_path: str, file_type: str) -> str:
    if file_type == "txt":
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()

    elif file_type == "pdf":
        from PyPDF2 import PdfReader
        reader = PdfReader(file_path)
        return "\n".join(page.extract_text() or "" for page in reader.pages)

    elif file_type == "docx":
        from docx import Document
        doc = Document(file_path)
        return "\n".join(p.text for p in doc.paragraphs)

    return ""

def chunk_text(text: str, chunk_size: int = 500, overlap: int = 50) -> list[str]:
    words = text.split()
    chunks = []
    i = 0
    while i < len(words):
        chunk = " ".join(words[i:i + chunk_size])
        chunks.append(chunk)
        i += chunk_size - overlap
    return [c for c in chunks if c.strip()]

def get_collection(user_id: int):
    return chroma_client.get_or_create_collection(
        name=f"user_{user_id}",
        embedding_function = embedding_fn
    )

def index_document(user_id: int, doc_id: int, text: str, title: str):
    collection = get_collection(user_id)
    try:
        collection.delete(where={"doc_id": doc_id})
    except Exception:
        pass
    chunks = chunk_text(text)
    collection.add(
        documents=chunks,
        ids=[f"doc_{doc_id}_chunk_{i}" for i in range(len(chunks))],
        metadatas=[{"doc_id": doc_id, "title": title} for _ in chunks]
    )

def search_documents(user_id: int, question: str, doc_id: int | None = None, n_results: int = 4) -> tuple [str, list[str]]:
    collection = get_collection(user_id)
    where = {"doc_id": doc_id} if doc_id else None

    results = collection.query(
        query_texts=[question],
        n_results=8,
        where=where
    )
    
    if not results["documents"] or not results["documents"][0]:
        return "No encontré información relevante en los documentos", []

    context ="\n\n".join(results["documents"][0])
    sources = list({m["title"] for m in results["metadatas"][0]})
    return context, sources

def ask(context: str, question: str) -> str:
    response = client.chat.completions.create(
        model= "llama-3.3-70b-versatile",
        messages=[
            {
            "role":"system",
            "content": "Eres un asistente que responde preguntas basándote SOLO en el contexto proporcionado. Puedes comparar información de diferentes fuentes si está disponible en el contexto. Si la respuesta no está en el contexto, dilo claramente."
            },
            {
                "role":"user",
                "content": f"Contexto:\n{context}\n\nPregunta: {question}"
            }
        ]
    )
    return response.choices[0].message.content