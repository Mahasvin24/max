import os
os.environ.update(HF_HUB_OFFLINE='1', TRANSFORMERS_OFFLINE='1')
import laya

import config
import database as db

# load Laya into memory
model = laya.load(str(config.LAYA_DIR), device='mps')

def decide_resoning_effort(message: str) -> str:
    pass

""" Conversation Routing """
def router_to_conversation(message: str) -> int:
    pass


""" Helper """
def _fetch_conversation_options():
    pass