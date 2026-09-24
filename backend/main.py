from fastapi import FastAPI
from routers import chat
import database

# Setup
database.tables.create_tables()

app = FastAPI()

@app.get("/health")
def health_check():
    return {"status": "ok"}

app.include_router(chat.router)

