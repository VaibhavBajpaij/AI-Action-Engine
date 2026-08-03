from sqlalchemy.orm import Session
from app.db.models import DeviceQuota, IST
from datetime import datetime

QUOTA_LIMIT = 3
QUOTA_PLATFORMS = ['instagram.com', 'linkedin.com', 'facebook.com', 'fb.watch']

def get_today_date_str() -> str:
    return datetime.now(IST).strftime("%Y-%m-%d")

def check_and_increment_quota(db: Session, device_id: str, platform_host: str) -> bool:
    """
    Returns True if quota is available (and increments it if applicable),
    False if quota is exceeded.
    """
    if platform_host not in QUOTA_PLATFORMS:
        return True
        
    today_str = get_today_date_str()
    quota_record = db.query(DeviceQuota).filter(DeviceQuota.device_id == device_id).first()
    
    if not quota_record:
        quota_record = DeviceQuota(device_id=device_id, used_today=1, last_reset_date=today_str)
        db.add(quota_record)
        db.commit()
        return True
        
    if quota_record.last_reset_date != today_str:
        quota_record.used_today = 0
        quota_record.last_reset_date = today_str
        
    if quota_record.used_today >= QUOTA_LIMIT:
        return False
        
    quota_record.used_today += 1
    db.commit()
    return True

def get_quota_status(db: Session, device_id: str):
    today_str = get_today_date_str()
    quota_record = db.query(DeviceQuota).filter(DeviceQuota.device_id == device_id).first()
    
    used = 0
    if quota_record and quota_record.last_reset_date == today_str:
        used = quota_record.used_today
        
    # calculate resetsAt in IST
    now = datetime.now(IST)
    # Midnight of the NEXT day
    next_midnight = now.replace(hour=0, minute=0, second=0, microsecond=0)
    from datetime import timedelta
    next_midnight += timedelta(days=1)
    
    return {
        "usedToday": used,
        "limit": QUOTA_LIMIT,
        "resetsAt": next_midnight.isoformat()
    }
