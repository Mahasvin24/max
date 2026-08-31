import ollama
from typing import TypedDict

import config

class Message(TypedDict):
    role: str
    content: str

messages = []

testing_messages = [
    Message(role="user", content="hey"),
    Message(role="user", content="I bombed an interview today. feeling pretty bad about it"),
    Message(role="user", content="my dog died this morning"),
    Message(role="user", content="I said I'd go to the gym 3x a week and I've gone once in two weeks"),
    Message(role="user", content="can you remind me to call the dentist tomorrow at 9"),
    Message(role="user", content="can you explain in detail how OAuth2 authorization code flow works"),
    Message(role="user", content="is it worth buying nvidia stock right now"),
    Message(role="user", content="who won the 2026 super bowl"),
    Message(role="user", content="tabs are objectively worse than spaces and anyone who disagrees is wrong"),
    Message(role="user", content="I'm so behind. thinking I'll just skip sleep and grind through the night")
]

# Fill these in with what a good reply looks like (same index as above).
expected_responses = [
    "hey, what's up?",  # 0. greeting
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

user_message = ""

