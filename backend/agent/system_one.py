import os
os.environ.update(HF_HUB_OFFLINE='1', TRANSFORMERS_OFFLINE='1')
from concurrent.futures import ThreadPoolExecutor
import laya
import time

import config
import database as db

_loader = ThreadPoolExecutor(max_workers=1)
_model_future = _loader.submit(
    laya.load,
    str(config.LAYA_DIR),
    device="cpu",
)

""" Conversation Routing """
def route_to_conversation(message: str) -> int:
    model = _model_future.result()

    criteria = db.conversations.fetch_conversation_previews()
    criteria["-1"] = "Create a new conversation"

    questions = {
        "route_conversation": {
            "type": "choice",
            "instructions": "Decide whether this user's query should be appended to a past conversation with an AI model or if a new conversation should be created for this query. Default to creating a new conversation unless there's a strong fit",
            "criteria": criteria
        }
    }

    # Laya response
    start = time.perf_counter()
    response = model.system_one(message, questions)
    elapsed = (time.perf_counter() - start) * 1000

    choice = response['answers']['route_conversation']['choice']

    print(f"Laya chose {choice} in {elapsed : .2f} ms")

    return int(choice)

def decide_resoning_effort(message: str) -> str:
    pass