import ollama
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

def quick_message(messages: list[Message], sys_prompt: str = config.SYSTEM_PROMPT):
    # System prompt
    messages = messages[:]
    sys_msg = Message(role="system", content=sys_prompt)
    messages.insert(0, sys_msg)

    return ollama.chat(model=config.MODEL, messages=messages, think=False)

def thinking_message(messages: list[Message], sys_prompt: str | None = None):
    # System prompt
    messages = messages[:]
    sys_msg = Message(role="system", content=sys_prompt)
    messages.insert(0, sys_msg)
    
    return ollama.chat(model=config.MODEL, messages=messages, think=True)