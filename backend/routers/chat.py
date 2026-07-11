import ollama
from fastapi import APIRouter
from pydantic import BaseModel

import config
from database import create_conversation, add_message, messages_for_id

router = APIRouter()

@router.post("/conversations")
def create_conversation_id():
    return create_conversation()

class Message(BaseModel):
    conversation_id: int
    content: str

class MessageResponse(BaseModel):
    conversation_id: int
    id: int
    role: str
    content: str
    created_at: str

@router.post("/messages")
def send_message(message: Message):
    # add user message to table
    add_message(message.conversation_id, "user", message.content)

    messages = messages_for_id(message.conversation_id)
    response = ollama.chat(model=config.MODEL, messages=messages)
    content = response["message"]["content"]

    add_message(message.conversation_id, "assistant", content)

    return content



