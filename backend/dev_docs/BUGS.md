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

Last verified: 2026-08-28 — 404 handling and the message-list copy confirmed
against a live server.

---

## No open bugs

Everything found so far has been fixed and verified.

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
