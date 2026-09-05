from groq import Groq
from typing import TypedDict
from dotenv import load_dotenv

import config

load_dotenv() # groq key

class Message(TypedDict):
    role: str
    content: str

client = Groq()

MAX_OUTPUT_TOKENS = 8000

""" Streams an agent's response"""
def message(messages: list):
    # System prompt
    messages = [Message(role=m["role"], content=m["content"]) for m in messages]
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)
    messages = [sys_msg] + [messages]

    for chunk in client.chat.completions.create(
        model=config.MODEL,
        messages=messages,
        temperature=0,
        max_completion_tokens=MAX_OUTPUT_TOKENS,
        stream=True
    ):
        piece = chunk.choices[0].delta.content
        if piece:
            yield piece


""" Create titles for conversations. """
def create_title(messages: list[Message]) -> str:
    # Setup w/ system prompt
    messages = [Message(role=m["role"], content=m["content"]) for m in messages]
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)
    messages = [sys_msg] + [messages]

    # API
    response = client.chat.completions.create(
        model=config.MODEL,
        messages=messages,
        temperature=0,
        max_completion_tokens=MAX_OUTPUT_TOKENS
    )

    return response.choices[0].message.content
