import ollama
from fastapi import APIRouter
from database import create_conversation, add_message, messages_for_id
from pydantic import BaseModel

router = APIRouter()

# Router Example Usage
#
# @router.post("/chat")
# def send_message(...):

# Ollama example usage
#
# response = ollama.chat(
#     model="llama3",
#     messages=[
#         {"role": "user", "content": "Hello"},
#     ],
# )
# print(response["message"]["content"])

@router.post("/conversations")
def create_conversation_id():
    return create_conversation()

class Message(BaseModel):
    conversation_id: int
    role: str
    content: str

@router.post("/messages")
def create_message(message: Message):
    # add user message to table
    add_message(message.conversation_id, message.role, message.content)

    # series of all messages
    messages = messages_for_id(message.conversation_id)

