import pytest
import asyncio
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from app.main import app
from app.db.database import get_db
from app.db.models import DeviceQuota, Job
import urllib.parse
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.db.database import Base

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(autouse=True)
def mock_classifier():
    with patch('app.main.load_classifier') as mock:
        yield mock

def test_unsupported_platform():
    with TestClient(app) as client:
        response = client.post("/process", json={"url": "https://tiktok.com/@user/video/123", "deviceId": "test1"})
        assert response.status_code == 400
        assert response.json() == {"error": "unsupportedPlatform"}

def test_quota_exceeded():
    db = TestingSessionLocal()
    from app.services.quota import get_today_date_str
    today = get_today_date_str()
    q = DeviceQuota(device_id="test2", used_today=3, last_reset_date=today)
    db.add(q)
    db.commit()
    db.close()

    with TestClient(app) as client:
        response = client.post("/process", json={"url": "https://instagram.com/reel/123/", "deviceId": "test2"})
        assert response.status_code == 429
        assert response.json() == {"error": "quotaExceeded"}

def test_quota_resets_at_midnight_ist():
    """
    Confirms that a device whose last_reset_date is yesterday IST gets
    its usedToday counter reset to 0 on the first request today, and
    the new request is allowed (not quota-exceeded).
    """
    from datetime import datetime, timedelta
    import zoneinfo
    from app.services.quota import check_and_increment_quota, get_today_date_str

    IST = zoneinfo.ZoneInfo("Asia/Kolkata")
    yesterday_str = (datetime.now(IST) - timedelta(days=1)).strftime("%Y-%m-%d")
    today_str = get_today_date_str()

    # Seed the DB: device used all 3 quota slots — but yesterday
    db = TestingSessionLocal()
    q = DeviceQuota(device_id="reset_device", used_today=3, last_reset_date=yesterday_str)
    db.add(q)
    db.commit()
    db.close()

    # Call check_and_increment_quota — this should detect the date mismatch,
    # reset used_today to 0, then increment to 1 and return True (allowed).
    db = TestingSessionLocal()
    allowed = check_and_increment_quota(db, "reset_device", "instagram.com")
    db.close()

    assert allowed is True, "Expected quota to be granted after midnight IST reset"

    # Verify the DB record was updated: date is today and used_today is 1
    db = TestingSessionLocal()
    record = db.query(DeviceQuota).filter(DeviceQuota.device_id == "reset_device").first()
    assert record.last_reset_date == today_str, f"Expected {today_str}, got {record.last_reset_date}"
    assert record.used_today == 1, f"Expected used_today=1 after reset, got {record.used_today}"
    db.close()

from app.services.extract import extract_content

@patch('app.services.extract.yt_dlp.YoutubeDL')
def test_video_too_long(mock_ytdl):
    mock_instance = MagicMock()
    mock_ytdl.return_value.__enter__.return_value = mock_instance
    mock_instance.extract_info.return_value = {"duration": 200, "title": "Long Video"}
    
    with pytest.raises(Exception, match="videoTooLong"):
        extract_content("https://youtube.com/watch?v=123", "https://youtube.com/watch?v=123")

@patch('app.services.extract.praw.Reddit')
@patch('app.config.REDDIT_CLIENT_ID', 'test')
@patch('app.config.REDDIT_CLIENT_SECRET', 'test')
def test_reddit_transcription_failed(mock_reddit):
    # Mock submission
    mock_instance = MagicMock()
    mock_reddit.return_value = mock_instance
    mock_submission = MagicMock()
    mock_submission.title = "Image Post"
    mock_submission.selftext = "short text"
    mock_instance.submission.return_value = mock_submission
    
    with pytest.raises(Exception, match="transcriptionFailed"):
        extract_content("https://reddit.com/comments/123/", "https://reddit.com/comments/123/")

@patch('app.services.extract.praw.Reddit')
@patch('app.config.REDDIT_CLIENT_ID', 'test')
@patch('app.config.REDDIT_CLIENT_SECRET', 'test')
def test_reddit_video_private(mock_reddit):
    # Mock prawcore.exceptions.ResponseException for 403
    import prawcore
    mock_instance = MagicMock()
    mock_reddit.return_value = mock_instance
    
    mock_response = MagicMock()
    mock_response.status_code = 403
    
    mock_instance.submission.side_effect = prawcore.exceptions.ResponseException(mock_response)
    
    with pytest.raises(Exception, match="videoPrivate"):
        extract_content("https://reddit.com/comments/123/", "https://reddit.com/comments/123/")

@patch('app.services.extract.yt_dlp.YoutubeDL')
def test_unknown_error(mock_ytdl):
    mock_instance = MagicMock()
    mock_ytdl.return_value.__enter__.return_value = mock_instance
    mock_instance.extract_info.side_effect = RuntimeError("Something completely unexpected")
    
    with pytest.raises(Exception, match="unknown"):
        extract_content("https://youtube.com/watch?v=123", "https://youtube.com/watch?v=123")

from app.services.pipeline import run_pipeline

@patch('app.services.pipeline.SessionLocal')
@patch('app.services.pipeline.extract_content')
def test_pipeline_unknown_error_saves_status(mock_extract, mock_session_local):
    """run_pipeline is async; drive it with asyncio.run()."""
    mock_extract.side_effect = Exception("Some weird error")
    mock_session_local.return_value = TestingSessionLocal()

    db = TestingSessionLocal()
    job = Job(job_id="job_unknown", status="pending")
    db.add(job)
    db.commit()
    db.close()

    # run_pipeline is now an async coroutine — use asyncio.run() to drive it
    asyncio.run(run_pipeline("job_unknown", "https://youtube.com/watch?v=123"))

    db = TestingSessionLocal()
    job = db.query(Job).filter(Job.job_id == "job_unknown").first()
    assert job.status == "failed"
    assert job.error == "unknown"
    db.close()

@patch('app.services.pipeline.SessionLocal')
@patch('app.services.pipeline.extract_content')
@patch('app.services.translate.GoogleTranslator.translate')
@patch('app.services.pipeline.generate_nlp_outputs')
@patch('app.services.pipeline.classify_text')
def test_pipeline_translation_failed(mock_classify, mock_nlp, mock_translate, mock_extract, mock_session_local):
    """
    Confirms that if deep-translator raises an exception, the pipeline
    does not fail. It completes with the original text and sets translationFailed=True.
    """
    mock_extract.return_value = ("Title", "Hindi text", "hi")
    mock_translate.side_effect = Exception("Google Translate API Error")
    mock_nlp.return_value = {"overview": "O", "checklist": [], "roadmap": [], "flashcards": []}
    mock_classify.return_value = "uncategorized"
    
    mock_session_local.return_value = TestingSessionLocal()
    
    db = TestingSessionLocal()
    job = Job(job_id="job_translation_fail", status="pending")
    db.add(job)
    db.commit()
    db.close()

    asyncio.run(run_pipeline("job_translation_fail", "https://youtube.com/watch?v=123"))

    db = TestingSessionLocal()
    job = db.query(Job).filter(Job.job_id == "job_translation_fail").first()
    
    # It should succeed, not fail
    assert job.status == "done"
    
    # Check JSON result
    import json
    result = json.loads(job.result)
    assert result["translationFailed"] is True
    assert result["originalLanguage"] == "hi"
    
    db.close()
