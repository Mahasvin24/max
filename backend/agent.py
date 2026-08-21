import ollama
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

def quick_message(messages: list[Message], sys_prompt: str | None = None):
    # Add system prompt if specified
    if sys_prompt:
        messages[0]["content"] = sys_prompt + "\n" + messages[0]["content"]

    return ollama.chat(model=config.MODEL, messages=messages)

def thinking_message(messages: list[Message], sys_prompt: str | None = None):
    ...