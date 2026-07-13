from pydantic import BaseModel

class Conversation(BaseModel):
    conversation_id: int
    created_at: str
    updated_at: str

class Message(BaseModel):
    conversation_id: int
    content: str

class MessageResponse(BaseModel):
    conversation_id: int
    id: int
    role: str
    content: str
    created_at: str