# Backlog

## Backend
- [ ] `config.py`: prompt file paths (`prompts/system_prompt.md`, `prompts/title_gen_prompt.md`) are relative to CWD, breaks if uvicorn isn't launched from `backend/`
- [ ] `chat.py`: `get_messages_for_conversation` has no `response_model`, unlike the other routes
- [ ] `requirements.txt`: missing `python-dotenv` (works locally because it's in the venv, but a fresh clone fails on `agent.py`)

## System prompt: safety coverage
The prompt is currently tuned for tone and brevity, not safety. It only refuses
one risky category (money). Worth adding before anyone but me uses this:

- [ ] Medical advice: no diagnosis, dosages, or "should I stop taking X"
- [ ] Legal advice: same shape as the money rule (give facts, not recommendations)
- [ ] Self-harm / crisis: this is a *productivity* agent that nudges people about
      goals and asks why they fell behind, so it will sometimes be talking to
      someone who is burnt out or spiralling. It should recognise real distress,
      stop pushing on goals, and point to a person who can help rather than
      trying to coach through it
- [ ] Overwork: partially there (it discourages all-nighters) but not stated as a
      rule, so it holds by luck rather than by instruction

Note: every clause added costs accuracy elsewhere. Testing during tuning showed
this model drops instructions as the prompt grows, and phrase-level bans can leak
verbatim into replies ("I never recommend buying or selling anything"). So add
these deliberately and re-run `prompt_tuner.py` after each one rather than
writing a large safety block in one go.

## macOS app
- [ ] System Settings > Menu Bar lists **two** "Max" entries: the retired
      `mahasvin.max-app` (off) and the live `com.mahasvin.max-app`. Cosmetic —
      macOS prunes stale entries on its own eventually. Don't "fix" it by
      renaming the bundle ID back; that identifier is the one that was stuck and
      never rendered an icon. See `max-app/AGENT.md`.
- [ ] Changing the bundle ID gave the app a fresh sandbox container, so the
      break-reminder toggle reset to its default once. Nothing to do unless some
      future setting is worth migrating — the old container is still at
      `~/Library/Containers/mahasvin.max-app`, and can be deleted once it isn't.
- [ ] The menu bar panel's `Toggle` and `ProgressView` have no automated visual
      check: `ImageRenderer` can't rasterize AppKit-backed controls, so the
      offscreen render covers layout and type but stamps placeholders over those
      two. They were confirmed by eye. If the panel grows more controls, that
      gap grows with it.
- [ ] The menu bar panel has no way to open the main window or quit the app,
      which most menu bar apps offer. Deliberately left out — the ask was to
      restyle the existing UI, not add features. Worth a decision, not a bug.
