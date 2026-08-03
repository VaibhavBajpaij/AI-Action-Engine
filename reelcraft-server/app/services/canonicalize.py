import urllib.parse
import re

def canonicalize_url(url: str) -> str:
    try:
        if not url.startswith(('http://', 'https://')):
            url = 'https://' + url
        parsed = urllib.parse.urlparse(url)
    except Exception:
        raise ValueError("unsupportedPlatform")
        
    netloc = parsed.netloc.lower()
    if netloc.startswith('www.'):
        netloc = netloc[4:]
    if netloc == 'm.youtube.com':
        netloc = 'youtube.com'
        
    path = parsed.path
    query = urllib.parse.parse_qs(parsed.query)
    
    # YouTube
    if netloc in ['youtube.com']:
        if 'v' in query:
            video_id = query['v'][0]
            return f"https://youtube.com/watch?v={video_id}"
        elif path.startswith('/shorts/'):
            video_id = path.split('/shorts/')[1].split('/')[0]
            return f"https://youtube.com/watch?v={video_id}"
        elif path.startswith('/live/'):
            video_id = path.split('/live/')[1].split('/')[0]
            return f"https://youtube.com/watch?v={video_id}"
        else:
            raise ValueError("unsupportedPlatform")
            
    elif netloc == 'youtu.be':
        video_id = path.strip('/')
        if not video_id:
            raise ValueError("unsupportedPlatform")
        return f"https://youtube.com/watch?v={video_id}"
        
    # Instagram
    elif netloc == 'instagram.com':
        m = re.match(r'/(p|reel|reels)/([^/]+)', path)
        if m:
            item_type = m.group(1)
            if item_type == 'reels':
                item_type = 'reel'
            item_id = m.group(2)
            return f"https://instagram.com/{item_type}/{item_id}/"
        else:
            raise ValueError("unsupportedPlatform")
            
    # LinkedIn
    elif netloc == 'linkedin.com':
        if path.startswith('/posts/'):
            item_id = path.split('/posts/')[1].split('/')[0]
            return f"https://linkedin.com/posts/{item_id}"
        elif path.startswith('/feed/update/'):
            item_id = path.split('/feed/update/')[1].split('/')[0]
            return f"https://linkedin.com/feed/update/{item_id}"
        else:
            raise ValueError("unsupportedPlatform")
            
    # Facebook
    elif netloc in ['facebook.com', 'fb.watch']:
        if netloc == 'fb.watch':
            video_id = path.strip('/')
            if not video_id:
                raise ValueError("unsupportedPlatform")
            return f"https://fb.watch/{video_id}/"
        else:
            if path.startswith('/watch/'):
                if 'v' in query:
                    return f"https://facebook.com/watch/?v={query['v'][0]}"
                else:
                    raise ValueError("unsupportedPlatform")
            m = re.match(r'/(?:v|video\.php)(?:/|\?v=)([^/&]+)', path + ('?' + parsed.query if parsed.query else ''))
            if m:
                return f"https://facebook.com/watch/?v={m.group(1)}"
            # Some URLs are just /username/videos/12345
            m = re.match(r'/[^/]+/videos/([^/]+)', path)
            if m:
                return f"https://facebook.com/watch/?v={m.group(1)}"
            raise ValueError("unsupportedPlatform")
            
    # Reddit
    elif netloc in ['reddit.com', 'redd.it']:
        if netloc == 'redd.it':
            item_id = path.strip('/')
            if not item_id:
                raise ValueError("unsupportedPlatform")
            return f"https://reddit.com/comments/{item_id}/"
        else:
            m = re.match(r'/r/[^/]+/comments/([^/]+)', path)
            if m:
                item_id = m.group(1)
                return f"https://reddit.com/comments/{item_id}/"
            elif path.startswith('/comments/'):
                item_id = path.split('/comments/')[1].split('/')[0]
                return f"https://reddit.com/comments/{item_id}/"
            else:
                raise ValueError("unsupportedPlatform")

    raise ValueError("unsupportedPlatform")
