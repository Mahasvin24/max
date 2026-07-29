import ollama
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

def quick_message(messages: list[Message], sys_prompt: str = None):
    # Add system prompt if specified
    if sys_prompt:
        prompt = ""
        with open(sys_prompt, "r") as f:
            prompt = f.read()
        messages.insert(0, Message(role="system", content=prompt))

    return ollama.chat(model=config.MODEL, messages=messages)

