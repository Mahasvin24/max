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


def _call_agent(messages: list[Message], reasoning_effort: str) -> str:
    payload = [Message(role=m["role"], content=m["content"]) for m in messages]

    response = client.chat.completions.create(
        model=config.MODEL,
        messages=payload,
        reasoning_effort=reasoning_effort,
        # Without this, Groq assumes the model's default ceiling (~1068 tokens) as
        # the request's expected output, which alone exceeds the free tier's
        # 1000 output-tokens-per-minute limit and 429s. Replies run 10-20 tokens;
        # the longest legitimate answer (a full explanation) is around 170.
        max_completion_tokens=MAX_OUTPUT_TOKENS,
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
