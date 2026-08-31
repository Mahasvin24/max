from fastapi import APIRouter, HTTPException

import agent
import config
import database as db
from schemas import Conversation, ConversationList, Message, MessageResponse

router = APIRouter()

""" List of all conversation ids """
@router.get("/conversations", response_model=ConversationList)
def fetch_conversation_history():
    conversations = db.get_all_conversations()
    return {
        "conversations": conversations,
        "count": len(conversations)
    }

""" Delete a conversation """
@router.delete("/conversations")
def delete_conversation(conversation_id: int):
    db.delete_conversation(conversation_id)
    return {"status": "ok"}

""" Get sequences of messages for a conversation """
@router.get("/messages")
def get_messages_for_conversation(conversation_id: int):
    return db.get_messages_for_id(conversation_id)

""" Send a message and get agent response. """
@router.post("/messages", response_model=MessageResponse)
def message_agent(message: Message):
    # Create new conversation conversation_id == -1
    is_new = message.conversation.conversation_id == -1
    if is_new:
        convo = db.create_conversation(message.content)
        message.conversation = Conversation(**convo)

    conv_id = message.conversation.conversation_id

    # Invalid conversation id case
    if not db.converation_exists(conv_id):
        raise HTTPException(status_code=404, detail=f"Conversation {conv_id} not found.")

    # add user message to table
    db.insert_message(conv_id, "user", message.content)

    # agent response
    messages = db.get_messages_for_id(conv_id)
    response = agent.quick_message(messages=messages)
    content = response.choices[0].message.content

    # add agent message to table
    obj = db.insert_message(conv_id, "assistant", content)

    # create title for new conversations
    if is_new:
        messages = db.get_messages_for_id(conv_id)
        res = agent.create_title(messages=messages)
        title = res.choices[0].message.content
        db.update_conversation_title(conv_id, title)
        print(f"New title {title}")

    return obj