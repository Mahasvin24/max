import ollama
from fastapi import APIRouter

import config
from database import create_conversation, add_message, messages_for_id
from schemas import Message, MessageResponse

router = APIRouter()

@router.post("/conversations")
def create_conversation_id():
    return create_conversation()

@router.post("/messages", response_model=MessageResponse)
def send_message(message: Message):
    # add user message to table
    add_message(message.conversation_id, "user", message.content)

    messages = messages_for_id(message.conversation_id)
    response = ollama.chat(model=config.MODEL, messages=messages)
    content = response["message"]["content"]

    obj = add_message(message.conversation_id, "assistant", content)

    return obj



