# Known Bugs

A running list of backend bugs, kept by Claude.

**How this file works**

- When a backend bug turns up — while reviewing, while testing the frontend
  against a live server, or in passing — it gets written up here rather than
  fixed. Backend code is Mahasvin's to write.
- Each entry explains what is wrong and why, in plain language, with whatever
  evidence was gathered (endpoint output, timings, repro steps).
- Mahasvin fixes it, then asks for a check. Verification means running the
  code, not just reading the diff.
- Once a fix is confirmed working, the entry is deleted from this file. Only
  open bugs live here.

Because entries are deleted and the rest renumbered, **the numbers are not
stable identifiers** — don't reference "bug 3" in a commit message or an issue.
Quote the title instead.

Testing is done against a scratch copy of the backend with its own fresh
`data.db`, never against `backend/data.db`, so nothing here touches real data.

Last verified: 2026-08-28, all four entries checked against a live server.

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

Still reproducible:

```
POST /messages  {"conversation": {"conversation_id": 424242, ...}}  ->  500
```

---

## 2) `quick_message` modifies the list it is given

`agent.quick_message` prepends the system prompt with
`messages.insert(0, sys_msg)`. That mutates the caller's list in place rather
than working on a copy, so the caller's variable silently gains a system message
it never asked for.

`thinking_message` has been fixed — it copies with `messages = messages[:]`
before inserting. `quick_message`, which is the one actually being called by
`routers/chat.py`, still mutates. Confirmed by passing in a one-message list and
reading it back afterwards:

```
caller list: 1 msg before -> 2 after; roles now ['system', 'user']
```

Nothing is broken today, because `routers/chat.py` reads a fresh list from the
database before each call. But it is a trap waiting for the first piece of code
that reuses a message list — for example calling the agent twice with the same
list, which would quietly stack two system prompts.

Worth noting the two functions now differ only in the `think` value they pass.
One function with a `think: bool = False` parameter would say it once, and there
would be only one place for this bug to live.

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
