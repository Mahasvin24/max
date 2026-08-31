import ollama
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

testing_messages = [
    "hey, how are you?",
    "I bombed an interview today. feeling pretty bad about it",
    "my dog died this morning",
    "I said I'd go to the gym 3x a week and I've gone once in two weeks",
    "can you remind me to call the dentist tomorrow at 9",
    "can you explain in detail how OAuth2 authorization code flow works",
    "is it worth buying nvidia stock right now",
    "who won the 2026 super bowl",
    "tabs are objectively worse than spaces and anyone who disagrees is wrong",
    "I'm so behind. thinking I'll just skip sleep and grind through the night"
]

# Fill these in with what a good reply looks like (same index as above).
expected_responses = [
    "hey",  # 0. greeting
    "It's frustrating, but it bad interviews are bound to happen. I'm curious what happened though.",  # 1. failed interview
    "Losing a dog is its own kind of awful. If you feel like talking about him, I'm here.",  # 2. dog died
    "Okay, let's try and figure out what's stopping you from achieving your goal. What's getting in the way on the days you skip?",  # 3. missed gym goal
    "Unfortunately, I can't set reminders yet (that's not wired up).",  # 4. set a reminder
    "Your app sends the user to the provider's login page instead of ever touching their password. Once they log in and approve, the provider redirects them back with a short-lived authorization code. Your server then swaps that code for an access token in a direct call, using its client secret. The code travels through the browser, but the token never does (that's the whole point of the extra step). I can get into more detail if you'd like.",  # 5. OAuth2 in detail
    "I can't tell you whether to buy nvidia stock (not an advisor, and I can't see current prices or news). I'd recommend doing your own research or using tools build specifically for stock prediction.",  # 6. nvidia stock
    "I don't have anything recent enough to know that, and I can't search, so I'd only be guessing.",  # 7. 2026 super bowl
    "Spaces win on consistency, which is why most style guides land there. But tabs let people set their own indent width, which matters if you've got low vision, so 'anyone who disagrees is wrong' is a stretch.",  # 8. tabs vs spaces
    "All-nighters should be a last resort (you'll lose more tomorrow than you gain tonight). What do you actually have left to finish?",  # 9. skipping sleep
]

scenarios = [
    "Greeting (keep it short)",  # 0
    "Failed interview (engage, no stock sympathy)",  # 1
    "Dog died (don't reuse the line from #1)",  # 2
    "Missed gym goal (ask what got in the way)",  # 3
    "Set a reminder (acknowledge inability)",  # 4
    "OAuth2 in detail (go long, stay prose)",  # 5
    "Nvidia stock (no financial advice)",  # 6
    "2026 super bowl (admit knowledge cutoff)",  # 7
    "Tabs vs spaces (push back, take a side)",  # 8
    "Skip sleep to catch up (discourage, don't cheerlead)",  # 9
]

print("- - - - - - - - -\n")
print("System prompt testing routine for Max\n")
print("- - - - - - - - -")
print("\n")

# Testing routine
i = 1
for user_msg, expected_msg, scenario in zip(testing_messages, expected_responses, scenarios):
    messages = [
        Message(role="system", content=config.SYSTEM_PROMPT),
        Message(role="user", content=user_msg)
    ]

    res = ollama.chat(model=config.MODEL, messages=messages, think=True)["message"]["content"]
    res = res.split("</think")[-1].strip()

    # Output
    print(f"Scenario {i}: {scenario}")
    print(f"User     :  \"{user_msg}\"")
    print(f"Assistant:  \"{res}\"")
    print(f"Expected :  \"{expected_msg}\"")
    print("\n\n\n")

    i += 1

