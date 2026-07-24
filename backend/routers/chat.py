import ollama
from fastapi import APIRouter

import config
import database as db
from schemas import Conversation, ConversationList, Message, MessageResponse

router = APIRouter()

""" List of all conversation ids """
@router.get("/all-conversations", response_model=ConversationList)
def fetch_conversation_history():
    conversations = db.get_all_conversations()
    return {
        "conversations": conversations,
        "count": len(conversations)
    }

""" Create a new conversation """
@router.post("/conversations", response_model=Conversation)
def create_conversation():
    return db.create_conversation()

""" Delete a conversation """
@router.delete("/conversations")
def delete_conversation(conversation_id: int):
    db.delete_conversation(conversation_id)
    return {"status": "ok"}

""" Get sequences of messages for a conversation """
@router.get("/conversations")
def get_messages_for_conversation(conversation_id: int):
    return db.get_messages_for_id(conversation_id)

""" Send a message and get agent response. """
@router.post("/messages", response_model=MessageResponse)
def message_agent(message: Message):
    # add user message to table
    db.insert_message(message.conversation_id, "user", message.content)

    messages = db.get_messages_for_id(message.conversation_id)
    response = ollama.chat(model=config.MODEL, messages=messages)
    content = response["message"]["content"]

    obj = db.insert_message(message.conversation_id, "assistant", content)

    return obj