import ollama
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

def quick_message(messages: list[Message]):
    return ollama.chat(model=config.MODEL, messages=messages)

