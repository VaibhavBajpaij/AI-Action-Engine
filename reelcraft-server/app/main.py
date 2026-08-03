import contextlib
import logging
import os
from fastapi import FastAPI
from app.api.routes import router
from app.db.database import Base, engine
from app.services.classifier import load_classifier
from app.services.extract import load_whisper

# Configure logging so all pipeline INFO/WARNING/ERROR messages appear in the terminal
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
    datefmt="%H:%M:%S",
)

@contextlib.asynccontextmanager
async def lifespan(app: FastAPI):
    from app.config import REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET
    
    if not REDDIT_CLIENT_ID or not REDDIT_CLIENT_SECRET:
        logging.warning("Reddit credentials missing (REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET) — all Reddit requests will fail until these are set.")

    # Setup DB
    Base.metadata.create_all(bind=engine)
    # Load ML models once at startup — never reloaded per-request
    load_classifier()
    load_whisper()
    yield
    # Cleanup

app = FastAPI(lifespan=lifespan)

app.include_router(router)
