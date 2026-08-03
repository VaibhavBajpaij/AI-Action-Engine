import os

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./reelcraft.db")

# Whisper model size. "tiny" is fast on CPU (~15–30s) and fine for local dev.
# Set WHISPER_MODEL=base (or small/medium) in production for better accuracy.
# https://github.com/openai/whisper#available-models-and-languages
WHISPER_MODEL = os.getenv("WHISPER_MODEL", "tiny")

# API Credentials
REDDIT_CLIENT_ID = os.getenv("REDDIT_CLIENT_ID")
REDDIT_CLIENT_SECRET = os.getenv("REDDIT_CLIENT_SECRET")
REDDIT_USER_AGENT = os.getenv("REDDIT_USER_AGENT", "reelcraft/1.0")
