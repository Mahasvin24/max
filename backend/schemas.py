from pydantic import BaseModel

class Conversation(BaseModel):
    conversation_id: int
    title: str
    created_at: str
    updated_at: str

class ConversationList(BaseModel):
    conversations: list[Conversation]
    count: int

class Message(BaseModel):
    conversation: Conversation
    content: str

class MessageResponse(BaseModel):
    conversation_id: int
    id: int
    role: str
    content: str
    created_at: str