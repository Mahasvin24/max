# Known Bugs

Found by exercising every endpoint against a scratch copy of the backend
(fresh `data.db`, Ollama running `qwen3:8b`) on 2026-08-28. Listed worst first.

Everything on the happy path works: creating a conversation, sending messages,
reading them back, deleting a conversation, and the cascade that removes its
messages. The bugs below are the edges around that path.

---

## 1) Sending a message to a conversation that does not exist returns 500

In `routers/chat.py`, `message_agent` inserts the user's message into the
`messages` table before checking that the conversation actually exists. Because
the connection sets `PRAGMA foreign_keys = ON`, SQLite rejects the insert with a
`FOREIGN KEY constraint failed` error, which escapes as an unhandled 500.

What's wrong with that: the client gets a generic "Internal Server Error" and
cannot tell "this conversation is gone" apart from "the backend is broken".
A 404 would say exactly what happened.

This is reachable from the app, not just from a test script. Before the frontend
fix, deleting the conversation you were currently viewing left its id sitting in
the view model, so the next message you typed was sent to a conversation that no
longer existed.

---

## 2) `updated_at` is never actually updated

`insert_message` in `database.py` runs this after inserting a message:

```sql
UPDATE conversations SET updated_at = ? WHERE id = ?
```

but passes the values as `(conversation_id, time)` — the two arguments are the
wrong way round. So it tries to set `updated_at` to a conversation id, on the row
whose id equals a timestamp string. No row has an id like that, so the statement
quietly matches zero rows and changes nothing. No error is raised, because
updating zero rows is perfectly legal SQL.

The result is that `updated_at` is frozen at whatever `create_conversation` wrote
and never moves again. Confirmed by sending two full exchanges and then reading
the conversation back: `created_at` and `updated_at` were still byte-identical.

The visible consequence is in `get_all_conversations`, which does
`ORDER BY updated_at DESC` to show recently used conversations first. Since
`updated_at` always equals `created_at`, that list is really sorted by creation
time, so a months-old conversation you used five minutes ago stays at the bottom.

---

## 3) Generated conversation titles contain the model's leaked reasoning

Titles coming out of the title generation step look like this — these are real
values read back from the database:

```
" The answer is 4.\n</think>\n\nMath Question Answer"
" That's it. No more.\n</think>\n\n2+2 equals 4"
```

The reasoning text and a stray `</think>` tag end up in the title. This happens
every time, not occasionally.

The cause is which messages get sent. For the title, `message_agent` passes the
full conversation history, which at that point **ends with the assistant's
reply**. Qwen3's chat template treats a trailing assistant message as something
to continue writing rather than something to respond to, so the model picks up
mid-thought. Ollama's parser never sees an opening `<think>` tag, so it does not
split the reasoning out into the separate `thinking` field — it leaves
`message.thinking` as `None` and dumps the reasoning, the closing `</think>`, and
the actual title together into `content`. The code then stores all of that as the
title.

Sending the same prompt with a history that ends on the **user** message produces
clean output every time, with the reasoning correctly separated:

```
'Math Question 2+2'   thinking: 'Okay, the user wants a short title for…'
'2+2 Question'        thinking: 'Okay, the user wants a short title for…'
```

`TITLE_GEN_PROMPT.md` already says "the message below" in the singular, so
generating the title from just the first user message matches what the prompt
asks for anyway.

This one is now user-visible: the app displays `title` in the conversation list
instead of the conversation id, so whatever the model produces goes on screen.

---

## 4) `quick_message` modifies the list it is given

`agent.quick_message` prepends the system prompt with
`messages.insert(0, sys_msg)`. That mutates the caller's list in place rather
than working on a copy, so the caller's variable silently gains a system message
it never asked for.

Nothing is broken today, because `routers/chat.py` reads a fresh list from the
database before each call. But it is a trap waiting for the first piece of code
that reuses a message list — for example calling the agent twice with the same
list, which would quietly stack two system prompts. Building a new list instead
of inserting into the caller's is the safer shape.

---

## Smaller notes

- `GET /conversations` returns **messages**, not conversations, and has no
  `response_model`, so it is neither documented nor validated by FastAPI.
  A name like `/conversations/{id}/messages` would say what it does.
- `create_conversation` is annotated `-> int` but returns a dict.
- Deleting a conversation id that does not exist returns `{"status": "ok"}`.
  Harmless, but a 404 would be more honest.
- The docstrings in `routers/chat.py` sit above the decorator, so they are just
  floating strings. Moving them inside the function bodies makes FastAPI show
  them in `/docs`.
