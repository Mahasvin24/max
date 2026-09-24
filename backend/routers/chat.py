from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
import time

import agent
import database as db
from schemas import Conversation, ConversationList, Message, MessageResponse

router = APIRouter()

""" List of all conversation ids """
@router.get("/conversations", response_model=ConversationList)
def fetch_conversation_history():
    conversations = db.conversations.list_all()
    return {
        "conversations": conversations,
        "count": len(conversations)
    }

""" Delete a conversation """
@router.delete("/conversations")
def delete_conversation(conversation_id: int):
    db.conversations.delete(conversation_id)
    return {"status": "ok"}

""" Get sequences of messages for a conversation """
@router.get("/messages")
def get_messages_for_conversation(conversation_id: int):
    return db.messages.list_for_conversation(conversation_id)

""" Send a message and get agent response. """
@router.post("/messages")
def message_agent(message: Message):
    # Create new conversation conversation_id == -1
    conv_id = message.conversation.conversation_id
    is_new = conv_id == -1

    # Route conversations
    if is_new:
        conv_id = agent.system_one.route_to_conversation(message.content)
        is_new = conv_id == -1

    # Create new ID for truly new conversations
    if conv_id == -1:
        convo = db.conversations.create(message.content)
        message.conversation = Conversation(**convo)
        conv_id = message.conversation.conversation_id

    # Invalid conversation id case
    if not db.conversations.exists(conv_id):
        raise HTTPException(status_code=404, detail=f"Conversation {conv_id} not found.")

    # add user message to table
    db.messages.create(conv_id, "user", message.content)

    # agent response
    messages = db.messages.list_for_conversation(conv_id)

    def stream(messages):
        pieces = []
        for chunk in agent.llm.message(messages=messages):
            # stream
            piece = chunk.choices[0].delta.content
            if piece:
                pieces.append(piece)
                yield sse_format(piece)

        # add agent message to table
        content = "".join(pieces)
        obj = db.messages.create(conv_id, "assistant", content)

        # create title for new conversations
        if is_new:
            messages = db.messages.list_for_conversation(conv_id)
            title = agent.llm.create_title(messages=messages)
            db.conversations.update_title(conv_id, title)
            print(f"New title: {title}") # DEBUG

        # final return with metadata
        yield sse_format(data=MessageResponse(**obj).model_dump_json(), event="done")

    return StreamingResponse(stream(messages), media_type="text/event-stream")

"""
-----  Helper(s)  -----
"""

def sse_format(data: str = "", event: str | None = None):
    lines = data.split("\n")
    res = "".join(f"data: {line}\n" for line in lines) + "\n"
    if event:
        res = f"event: {event}\n" + res
    time.sleep(0.015)
    return res
