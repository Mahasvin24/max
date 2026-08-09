# Backlog

## Backend
- [ ] `config.py`: prompt file paths (`prompts/SYSTEM_PROMPT.md`, `prompts/TITLE_GEN_PROMPT.md`) are relative to CWD, breaks if uvicorn isn't launched from `backend/`
- [ ] `chat.py`: `get_messages_for_conversation` has no `response_model`, unlike the other routes
