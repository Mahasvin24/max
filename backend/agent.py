import ollama
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

def quick_message(messages: list[Message]):
    # System prompt
    messages = messages[:]
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)
    messages.insert(0, sys_msg)

    return ollama.chat(model=config.MODEL, messages=messages, think=False)

def thinking_message(messages: list[Message]):
    # System prompt
    messages = messages[:]
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)
    messages.insert(0, sys_msg)
    
    return ollama.chat(model=config.MODEL, messages=messages, think=True)

""" Create titles for conversations. """
def create_title(messages: list[Message]):
    # System rompt to create title
    messages = messages[:]
    title_prompt = Message(role="system", content=config.TITLE_GEN_PROMPT)
    messages.append(title_prompt)

    return ollama.chat(model=config.MODEL, messages=messages, think=False)