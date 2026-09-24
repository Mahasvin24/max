import os
os.environ.update(HF_HUB_OFFLINE='1', TRANSFORMERS_OFFLINE='1')
import laya
import time # temp, testing

import config
import database as db

# load Laya into memory
model = laya.load(str(config.LAYA_DIR), device='mps')

def decide_resoning_effort(message: str) -> str:
    pass

""" Conversation Routing """
def route_to_conversation(message: str) -> int:
    criteria = db.conversations.fetch_conversation_previews()
    criteria["-1"] = "Create a new conversation"

    questions = {
        "route_conversation": {
            "type": "choice",
            "instructions": "Decide whether this user's query should be appended to a past conversation with an AI model or if a new conversation should be created for this query.",
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
