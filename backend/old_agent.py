from groq import Groq
from typing import TypedDict
from dotenv import load_dotenv

import config

load_dotenv() # groq key

class Message(TypedDict):
    role: str
    content: str

client = Groq()

MAX_OUTPUT_TOKENS = 1000

""" Streams an agent's response (returns generator) """
def message(messages: list):
    # Setup w/ system prompt
    messages = [Message(role=m["role"], content=m["content"]) for m in messages]
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)
    messages = [sys_msg] + messages

    # return generator
    return client.chat.completions.create(
        model=config.MODEL,
        messages=messages,
        temperature=0,
        max_completion_tokens=MAX_OUTPUT_TOKENS,
        stream=True
    )


""" Create titles for conversations. """
def create_title(messages: list[Message]) -> str:
    # Setup w/ system prompt
    messages = [Message(role=m["role"], content=m["content"]) for m in messages]
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)
    title_msg = Message(role="system", content=config.TITLE_GEN_PROMPT)
    messages = [sys_msg, title_msg] + messages

    # API
    response = client.chat.completions.create(
        model=config.MODEL,
        messages=messages,
        temperature=0,
        max_completion_tokens=MAX_OUTPUT_TOKENS
    )

    return response.choices[0].message.content
