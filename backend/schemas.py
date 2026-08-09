from pydantic import BaseModel
from typing import Optional

class Conversation(BaseModel):
    conversation_id: int
    title: str
    created_at: str
    updated_at: str

class ConversationList(BaseModel):
    conversations: list[Conversation]
    count: int

class Message(BaseModel):
    content: str
    conversation: Optional[Conversation] = None

class MessageResponse(BaseModel):
    conversation_id: int
    id: int
    role: str
    content: str
    created_at: str