import ollama
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

messages = []

user_message = ""

