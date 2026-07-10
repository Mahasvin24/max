from fastapi import FastAPI
from routers import chat

app = FastAPI()

@app.get("/health")
def health_check():
    return {"status": "ok"}

app.include_router(chat.router)

