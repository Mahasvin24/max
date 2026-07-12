from pydantic import BaseModel

class Message(BaseModel):
    conversation_id: int
    content: str

class MessageResponse(BaseModel):
    conversation_id: int
    id: int
    role: str
    content: str
    created_at: str