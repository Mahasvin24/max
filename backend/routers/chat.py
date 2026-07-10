from fastapi import APIRouter

router = APIRouter()

# Example usage
# @router.post("/chat")
# def send_message(...):

@router.get("/create-conversation-id")
def create_conversation_id():
    pass

