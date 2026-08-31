# Global variables

MODEL = "qwen/qwen3.8-27b"

DATABASE = "data.db"

with open("prompts/SYSTEM_PROMPT.md", "r") as f:
    SYSTEM_PROMPT = f.read()

with open("prompts/TITLE_GEN_PROMPT.md", "r") as f:
    TITLE_GEN_PROMPT = f.read()