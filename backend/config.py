# config.py 
# Global variables

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent # aka, backend folder
PROMPTS_DIR = BASE_DIR / "prompts"

DATABASE = BASE_DIR / "database" / "data.db"

# Models
MODEL = "openai/gpt-oss-120b"
LAYA_DIR = BASE_DIR / "models" / "laya"


# Prompts
with open(PROMPTS_DIR / "system_prompt.md", "r") as f:
    SYSTEM_PROMPT = f.read()
with open(PROMPTS_DIR / "title_gen_prompt.md", "r") as f:
    TITLE_GEN_PROMPT = f.read()
