from fastapi import FastAPI
from app.db.database import Base, engine
from app.models import user, document

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="TFC API",
    version="0.1.0"
)

@app.get("/")
def root():
    return {"status": "ok", "message": "API funcionando"}