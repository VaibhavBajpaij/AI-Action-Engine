import os
import tempfile
import yt_dlp
from youtube_transcript_api import YouTubeTranscriptApi
from faster_whisper import WhisperModel
import praw
import requests
import json
import urllib.parse
import re
import logging
from app.config import WHISPER_MODEL

logger = logging.getLogger(__name__)

whisper_model = None

def load_whisper():
    """Load the Whisper model once at startup. Call from FastAPI lifespan."""
    global whisper_model
    # HF_HUB_OFFLINE=1 skips all network round-trips to huggingface.co once the
    # model is already in the local cache (~/.cache/huggingface/).
    offline = os.environ.get("HF_HUB_OFFLINE", "0") == "1"
    kwargs = {"device": "cpu", "compute_type": "int8"}
    if offline:
        kwargs["local_files_only"] = True
    logger.info(
        "Loading faster-whisper model=%s device=cpu compute_type=int8 offline=%s",
        WHISPER_MODEL, offline
    )
    whisper_model = WhisperModel(WHISPER_MODEL, **kwargs)
    logger.info("faster-whisper model loaded model=%s", WHISPER_MODEL)

def get_whisper():
    """Return the pre-loaded Whisper model. Raises if load_whisper() was not called."""
    if whisper_model is None:
        # Fallback: load on demand if somehow not pre-loaded (e.g. in tests)
        load_whisper()
    return whisper_model

def extract_reddit_text(url: str) -> tuple[str, str, str]:
    from app.config import REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET, REDDIT_USER_AGENT
    if not REDDIT_CLIENT_ID or not REDDIT_CLIENT_SECRET:
        logger.error("Reddit API credentials missing")
        raise Exception("authenticationFailed")

    try:
        reddit = praw.Reddit(
            client_id=REDDIT_CLIENT_ID,
            client_secret=REDDIT_CLIENT_SECRET,
            user_agent=REDDIT_USER_AGENT
        )
        submission = reddit.submission(url=url)
        # Accessing title or selftext will trigger the API request
        title = submission.title
        selftext = submission.selftext
        word_count = len(selftext.split()) if selftext else 0
        logger.info("Reddit post fetched title=%r selftext_words=%d", title, word_count)
        if not selftext or word_count < 15:
            logger.warning("Reddit post has insufficient text url=%s words=%d", url, word_count)
            raise Exception("transcriptionFailed")
        return title, selftext, "en"
    except Exception as e:
        import prawcore
        if isinstance(e, prawcore.exceptions.ResponseException):
            if e.response.status_code == 401:
                logger.error("Reddit auth failed url=%s status=401", url)
                raise Exception("authenticationFailed")
            if e.response.status_code == 403:
                logger.warning("Reddit post is private/banned url=%s status=403", url)
                raise Exception("videoPrivate")
            
        if str(e) in ["transcriptionFailed", "videoPrivate", "authenticationFailed"]:
            raise
            
        logger.exception("Unexpected error parsing Reddit via PRAW url=%s raw_error=%s: %s", url, type(e).__name__, e)
        raise Exception("unknown")


def transcribe_video(url: str) -> tuple[str, str, str]:
    ydl_opts = {
        'format': 'bestaudio/best',
        'quiet': True,
        'no_warnings': True,
        'dump_single_json': True,
        'extract_flat': False,
    }

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            logger.info("yt-dlp: fetching metadata url=%s", url)
            info = ydl.extract_info(url, download=False)

            title = info.get('title', 'Unknown')
            duration = info.get('duration', 0)
            logger.info("yt-dlp: metadata ok title=%r duration=%ss", title, duration)

            if duration > 180:
                logger.warning("Video too long url=%s duration=%ss", url, duration)
                raise Exception("videoTooLong")

            # YouTube: try caption API first (fast, no download), fall back to Whisper
            if 'youtube.com' in url or 'youtu.be' in url:
                video_id = info.get('id')
                try:
                    logger.info("youtube-transcript-api: fetching captions video_id=%s", video_id)
                    ytt = YouTubeTranscriptApi()
                    try:
                        fetched = ytt.fetch(video_id, languages=['en', 'en-US', 'en-GB'])
                        lang_used = 'en'
                    except Exception:
                        transcript_list = ytt.list(video_id)
                        transcript = next(iter(transcript_list))
                        fetched = transcript.fetch()
                        lang_used = transcript.language_code

                    text = " ".join(snippet.text for snippet in fetched)
                    word_count = len(text.split())
                    logger.info(
                        "youtube-transcript-api: got %d words lang=%s is_generated=%s video_id=%s",
                        word_count, lang_used, fetched.is_generated, video_id
                    )
                    if word_count < 15:
                        logger.warning("Captions too short, falling back to Whisper video_id=%s words=%d", video_id, word_count)
                    else:
                        return title, text, lang_used
                except Exception as e:
                    logger.warning("youtube-transcript-api failed, falling back to Whisper video_id=%s error=%s", video_id, e)

            # Download audio and run Whisper
            with tempfile.TemporaryDirectory() as tmpdir:
                audio_path = os.path.join(tmpdir, "audio.m4a")
                dl_opts = {
                    'format': 'm4a/bestaudio/best',
                    'outtmpl': audio_path,
                    'quiet': True,
                }
                logger.info("yt-dlp: downloading audio url=%s", url)
                with yt_dlp.YoutubeDL(dl_opts) as ydl_dl:
                    ydl_dl.download([url])

                if not os.path.exists(audio_path):
                    logger.error("yt-dlp: audio file missing after download url=%s expected_path=%s", url, audio_path)
                    raise Exception("unknown")

                file_size = os.path.getsize(audio_path)
                logger.info("yt-dlp: audio downloaded size=%d bytes url=%s", file_size, url)

                model = get_whisper()
                logger.info("faster-whisper: starting transcription audio_path=%s", audio_path)
                segments, whisper_info = model.transcribe(audio_path, beam_size=5)
                text = " ".join([segment.text for segment in segments])
                word_count = len(text.split())
                logger.info("faster-whisper: transcription complete words=%d url=%s lang=%s", word_count, url, whisper_info.language)

                if word_count < 15:
                    logger.warning("Whisper transcript too short url=%s words=%d", url, word_count)
                    raise Exception("transcriptionFailed")

                return title, text, whisper_info.language

    except yt_dlp.utils.DownloadError as e:
        logger.error("yt-dlp DownloadError raw_error=%s: %s url=%s", type(e).__name__, e, url)
        msg = str(e).lower()
        
        if 'linkedin.com' in url or 'facebook.com' in url or 'fb.watch' in url:
            if any(term in msg for term in ['login', 'sign in', 'authentication', 'private', 'cannot parse data']):
                raise Exception("videoPrivate")
                
        if 'private' in msg or 'deleted' in msg or 'geo' in msg or 'sign in' in msg:
            raise Exception("videoPrivate")
        raise Exception("unknown")

    except Exception as e:
        logger.error(
            "transcribe_video caught exception raw_error=%s: %s url=%s",
            type(e).__name__, e, url
        )
        if str(e) in ["videoTooLong", "transcriptionFailed", "videoPrivate"]:
            raise
        logger.exception("Full traceback for unexpected exception in transcribe_video url=%s", url)
        raise Exception("unknown")

def extract_content(url: str, canonical: str) -> tuple[str, str, str]:
    logger.info("extract_content starting canonical=%s", canonical)
    if 'reddit.com' in canonical:
        return extract_reddit_text(canonical)
    else:
        return transcribe_video(url)
