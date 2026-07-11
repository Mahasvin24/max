import ollama
from fastapi import APIRouter
from database import create

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

@router.get("/create-conversation-id")
def create_conversation_id():
    return 

