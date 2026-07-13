import ollama
from fastapi import APIRouter

import config
from database import create_conversation, get_all_conversations, add_message, messages_for_id
from schemas import Conversation, ConversationList, Message, MessageResponse

router = APIRouter()

""" List of all conversation ids """
@router.get("/all-conversations", response_model=ConversationList)
def get_conversations():
    conversations = get_all_conversations()
    return {
        "conversations": conversations,
        "count": len(conversations)
    }

""" Create a new conversation """
@router.post("/conversations", response_model=Conversation)
def create_conversation_id():
    return create_conversation()

""" Get sequences of messages for a conversation """
@router.get("/conversations")
def get_full_conversation(conversation_id: int):
    return messages_for_id(conversation_id)

""" Send a message and get agent response. """
@router.post("/messages", response_model=MessageResponse)
def send_message(message: Message):
    # add user message to table
    add_message(message.conversation_id, "user", message.content)

    messages = messages_for_id(message.conversation_id)
    response = ollama.chat(model=config.MODEL, messages=messages)
    content = response["message"]["content"]

    obj = add_message(message.conversation_id, "assistant", content)

    return obj



