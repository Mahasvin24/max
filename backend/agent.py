from groq import Groq
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

client = Groq()

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
    
    return client.chat.completions.create(model=config.MODEL, messages=messages, reasoning_effort="none")

""" Create titles for conversations. """
def create_title(messages: list[Message]):
    # System rompt to create title
    messages = messages[:]
    title_prompt = Message(role="system", content=config.TITLE_GEN_PROMPT)
    messages.append(title_prompt)

    return client.chat.completions.create(model=config.MODEL, messages=messages, reasoning_effort="default")