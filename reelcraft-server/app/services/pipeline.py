import asyncio
from app.db.database import SessionLocal
from app.db.models import Job, CacheEntry
from app.services.extract import extract_content
from app.services.nlp import generate_nlp_outputs
from app.services.classifier import classify_text
import urllib.parse
import json
import logging
from functools import partial

logger = logging.getLogger(__name__)

async def run_pipeline(job_id: str, canonical_url: str):
    db = SessionLocal()
    try:
        parsed = urllib.parse.urlparse(canonical_url)
        host = parsed.netloc

        if host in ['youtube.com', 'youtu.be']:
            platform = 'youtube'
        elif host == 'instagram.com':
            platform = 'instagram'
        elif host == 'linkedin.com':
            platform = 'linkedin'
        elif host in ['facebook.com', 'fb.watch']:
            platform = 'facebook'
        elif host in ['reddit.com', 'redd.it']:
            platform = 'reddit'
        else:
            raise Exception("unsupportedPlatform")

        loop = asyncio.get_event_loop()

        # --- All blocking I/O and CPU work is offloaded to the thread pool ---
        # This keeps the event loop free to answer GET /result and GET /health
        # while transcription or NLP is in progress.

        # 1. Content extraction: yt-dlp download + faster-whisper transcription
        #    This is the slowest step and would block the loop for 30–180 seconds.
        title, text, original_language = await loop.run_in_executor(
            None,
            partial(extract_content, canonical_url, canonical_url)
        )

        translation_failed = False
        if original_language and not original_language.lower().startswith('en'):
            from app.services.translate import translate_to_english
            logger.info("Non-English detected (%s), translating to English", original_language)
            text, translation_failed = await loop.run_in_executor(
                None,
                partial(translate_to_english, text)
            )

        # 2. NLP generation: Sumy TextRank + TF-IDF (CPU-bound)
        nlp_outputs = await loop.run_in_executor(
            None,
            partial(generate_nlp_outputs, title, text)
        )

        # 3. Zero-shot classification: sentence-transformers cosine similarity (CPU-bound)
        category = await loop.run_in_executor(
            None,
            partial(classify_text, text)
        )

        category_confidence = 1.0 if category != "uncategorized" else 0.0

        result_data = {
            "id": job_id,
            "title": title,
            "platform": platform,
            "category": category,
            "categoryConfidence": category_confidence,
            "overview": nlp_outputs['overview'],
            "checklist": nlp_outputs['checklist'],
            "roadmap": nlp_outputs['roadmap'],
            "flashcards": nlp_outputs['flashcards'],
            "originalLanguage": original_language,
            "translationFailed": translation_failed
        }

        result_json = json.dumps(result_data)

        # DB writes are fast; do them on the event loop thread (no executor needed)
        job = db.query(Job).filter(Job.job_id == job_id).first()
        if job:
            job.status = "done"
            job.result = result_json

        cache_entry = CacheEntry(canonical_url=canonical_url, result_json=result_json)
        db.merge(cache_entry)
        db.commit()

        logger.info("Pipeline succeeded job_id=%s platform=%s category=%s", job_id, platform, category)

    except Exception as e:
        db.rollback()
        # Log raw exception type and message BEFORE any string-matching — this is always printed
        logger.error(
            "pipeline except raw_error=%s: %s job_id=%s",
            type(e).__name__, e, job_id
        )
        error_str = str(e)
        allowed_errors = [
            "videoPrivate", "videoTooLong", "transcriptionFailed",
            "unsupportedPlatform", "unknown", "authenticationFailed"
        ]
        if error_str not in allowed_errors:
            logger.exception("Full traceback for unexpected pipeline error job_id=%s", job_id)
            error_str = "unknown"
        else:
            logger.warning("Pipeline failed with known error job_id=%s error=%s", job_id, error_str)

        job = db.query(Job).filter(Job.job_id == job_id).first()
        if job:
            job.status = "failed"
            job.error = error_str
            db.commit()

    finally:
        db.close()
