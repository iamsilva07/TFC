from fastapi import FastAPI
from app.db.database import Base, engine
from app.models import user, document
from app.api.routes import auth, documents
 

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="TFC API",
    version="0.1.0"
)

app.include_router(auth.router, prefix="/api/v1")
app.include_router(documents.router, prefix="/api/v1")

@app.get("/")
def root():
    return {"status": "ok", "message": "API funcionando"}