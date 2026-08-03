import pytest
from app.services.canonicalize import canonicalize_url

def test_youtube_standard():
    assert canonicalize_url("https://youtube.com/watch?v=123&t=10s") == "https://youtube.com/watch?v=123"

def test_youtube_www():
    assert canonicalize_url("https://www.youtube.com/watch?v=123") == "https://youtube.com/watch?v=123"

def test_youtube_mobile():
    assert canonicalize_url("https://m.youtube.com/watch?v=123") == "https://youtube.com/watch?v=123"

def test_youtube_shortlink():
    assert canonicalize_url("https://youtu.be/123?si=xyz") == "https://youtube.com/watch?v=123"

def test_youtube_shorts():
    assert canonicalize_url("https://youtube.com/shorts/123?feature=share") == "https://youtube.com/watch?v=123"

def test_youtube_live():
    assert canonicalize_url("https://youtube.com/live/123") == "https://youtube.com/watch?v=123"

def test_instagram_post():
    assert canonicalize_url("https://instagram.com/p/123/") == "https://instagram.com/p/123/"

def test_instagram_reels_converts_to_reel():
    assert canonicalize_url("https://www.instagram.com/reels/123/?igsh=xyz") == "https://instagram.com/reel/123/"

def test_linkedin_post():
    assert canonicalize_url("https://www.linkedin.com/posts/123/") == "https://linkedin.com/posts/123"

def test_linkedin_feed():
    assert canonicalize_url("https://linkedin.com/feed/update/urn:li:activity:123") == "https://linkedin.com/feed/update/urn:li:activity:123"

def test_reddit_full():
    assert canonicalize_url("https://www.reddit.com/r/programming/comments/123/title/?utm_source=share") == "https://reddit.com/comments/123/"

def test_reddit_short():
    assert canonicalize_url("https://redd.it/123") == "https://reddit.com/comments/123/"


def test_facebook_watch():
    assert canonicalize_url("https://www.facebook.com/watch/?v=123") == "https://facebook.com/watch/?v=123"

def test_facebook_video_php():
    assert canonicalize_url("https://www.facebook.com/video.php?v=123") == "https://facebook.com/watch/?v=123"

def test_facebook_videos_path():
    assert canonicalize_url("https://www.facebook.com/username/videos/123/?mibextid=xyz") == "https://facebook.com/watch/?v=123"

def test_facebook_shortlink():
    assert canonicalize_url("https://fb.watch/123/?mibextid=xyz") == "https://fb.watch/123/"

def test_unsupported_platform():
    with pytest.raises(ValueError, match="unsupportedPlatform"):
        canonicalize_url("https://tiktok.com/@user/video/123")

def test_identical_urls_with_different_tracking_params():
    url1 = canonicalize_url("https://www.instagram.com/reel/123/?igsh=abc")
    url2 = canonicalize_url("https://instagram.com/reel/123/?igsh=xyz")
    assert url1 == url2
    assert url1 == "https://instagram.com/reel/123/"
