# Backlog

## Backend
- [ ] `config.py`: prompt file paths (`prompts/SYSTEM_PROMPT.md`, `prompts/TITLE_GEN_PROMPT.md`) are relative to CWD, breaks if uvicorn isn't launched from `backend/`
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
