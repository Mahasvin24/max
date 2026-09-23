import os
import json
os.environ.update(HF_HUB_OFFLINE='1', TRANSFORMERS_OFFLINE='1')
import torch
import laya

import config

agent = laya.load(str(config.LAYA_DIR), device='mps')

questions = {
    'conversation_routing': {
        'type': 'choice',
        'instructions': 'Decide whether this user query fits best inside one of their past conversations, or if a new conversation should be created for it. Choose a new conversation unless there is strong overlap with a previous conversation',
        'criteria': {
            'chat_101': 'Troubleshooting Python scripts and API token errors',
            'chat_102': 'Beginner skateboard setups and hardware costs',
            'chat_103': 'Local Indian restaurant recommendations and takeout menus',
            'new_conversation': 'A completely new topic that does not match any of the previous conversations.'
        }
    }
}

# 1. Run the System One pass
result = agent.system_one('what should I do, I scraped my knee', questions)

# 2. Extract the predicted answer and its calibrated confidence score
routing_data = result['answers']['conversation_routing']
chosen_action = routing_data['answer']
# Laya returns probabilities for each choice option
confidence_score = routing_data['probabilities'][chosen_action]

# 3. Apply your confidence gate
CONFIDENCE_THRESHOLD = 0.85

print(f"Laya selected: {chosen_action} with {confidence_score:.4f} confidence and an overall confidence of {routing_data['confidence']}")

if chosen_action == 'new_conversation' or confidence_score < CONFIDENCE_THRESHOLD:
    print("\n[ROUTE ACTION]: Initializing a NEW conversation thread.")
    # If it matched an old chat but with low confidence (< 0.85), 
    # we treat it as an ambiguous/new topic and force a split.
else:
    print(f"\n[ROUTE ACTION]: Appending message to existing thread: {chosen_action}")
