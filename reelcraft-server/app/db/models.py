from sqlalchemy import Column, String, Integer, DateTime
from app.db.database import Base
from datetime import datetime
import zoneinfo

IST = zoneinfo.ZoneInfo("Asia/Kolkata")

class CacheEntry(Base):
    __tablename__ = "cache_entries"
    canonical_url = Column(String, primary_key=True, index=True)
    result_json = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(IST))

class DeviceQuota(Base):
    __tablename__ = "device_quota"
    device_id = Column(String, primary_key=True, index=True)
    used_today = Column(Integer, default=0)
    last_reset_date = Column(String, nullable=False) # e.g. "2026-08-01"

class Job(Base):
    __tablename__ = "jobs"
    job_id = Column(String, primary_key=True, index=True)
    status = Column(String, nullable=False, default="pending")
    result = Column(String, nullable=True) # JSON string of result on success
    error = Column(String, nullable=True)  # Enum error string on failure
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(IST))
