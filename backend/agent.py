from groq import Groq
from typing import TypedDict
from dotenv import load_dotenv

import config

load_dotenv() # groq key

class Message(TypedDict):
    role: str
    content: str

client = Groq()


def _call_agent(messages: list[Message], reasoning_effort: str) -> str:
    payload = [Message(role=m["role"], content=m["content"]) for m in messages]

    response = client.chat.completions.create(
        model=config.MODEL,
        messages=payload,
        reasoning_effort=reasoning_effort,
    )
    return response.choices[0].message.content


def quick_message(messages: list[Message]) -> str:
    # System prompt
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)

    return _call_agent([sys_msg] + list(messages), reasoning_effort="none")

def thinking_message(messages: list[Message]) -> str:
    # System prompt
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)

    return _call_agent([sys_msg] + list(messages), reasoning_effort="default")

""" Create titles for conversations. """
def create_title(messages: list[Message]) -> str:
    # System prompts
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)
    title_prompt = Message(role="system", content=config.TITLE_GEN_PROMPT)

    return _call_agent([sys_msg] + [title_prompt] + list(messages), reasoning_effort="none")
