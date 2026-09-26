from dotenv import load_dotenv
from groq import Groq
from groq.types.chat import ChatCompletionChunk
from dataclasses import dataclass
from collections.abc import Iterator


import config
from .schemas import Message

load_dotenv() # groq key

client = Groq()

MAX_OUTPUT_TOKENS = 1000

@dataclass
class AgentStream:
    chunks: Iterator[ChatCompletionChunk]
    rate_limits: dict[str, str | None]

""" Streams an agent's response (returns generator) """
def message(messages: list):
    # Setup w/ system prompt
    messages = [Message(role=m["role"], content=m["content"]) for m in messages]
    sys_msg = Message(role="system", content=config.SYSTEM_PROMPT)
    messages = [sys_msg] + messages

    # return generator
    with client.chat.completions.create(
        model=config.MODEL,
        messages=messages,
        temperature=0,
        max_completion_tokens=MAX_OUTPUT_TOKENS,
        stream=True
    ) as response:
        yield AgentStream(chunks=response, rate_limits=)

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
