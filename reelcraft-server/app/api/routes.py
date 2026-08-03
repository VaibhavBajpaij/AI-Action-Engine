from fastapi import APIRouter, Depends, BackgroundTasks, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import Job, CacheEntry
from app.services.canonicalize import canonicalize_url
from app.services.quota import check_and_increment_quota, get_quota_status
import urllib.parse
import uuid
import json

router = APIRouter()

class ProcessRequest(BaseModel):
    url: str
    deviceId: str

@router.get("/health")
def health_check():
    return {"status": "ok"}

@router.get("/quota/{device_id}")
def get_quota(device_id: str, db: Session = Depends(get_db)):
    return get_quota_status(db, device_id)

@router.post("/process")
def process_url(req: ProcessRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    try:
        canonical = canonicalize_url(req.url)
    except ValueError as e:
        if str(e) == "unsupportedPlatform":
            return JSONResponse(status_code=400, content={"error": "unsupportedPlatform"})
        raise

    # Check cache
    cached = db.query(CacheEntry).filter(CacheEntry.canonical_url == canonical).first()
    if cached:
        # Cache hit - generate a fake jobId that just resolves to this cache entry
        # Or even better, create a completed job
        job_id = str(uuid.uuid4())
        job = Job(job_id=job_id, status="done", result=cached.result_json)
        db.add(job)
        db.commit()
        return {"jobId": job_id, "cached": True}

    # Extract host for quota check
    parsed = urllib.parse.urlparse(canonical)
    host = parsed.netloc

    # Check quota
    if not check_and_increment_quota(db, req.deviceId, host):
        return JSONResponse(status_code=429, content={"error": "quotaExceeded"})

    job_id = str(uuid.uuid4())
    job = Job(job_id=job_id, status="pending")
    db.add(job)
    db.commit()
    
    # Import locally to avoid circular dependency
    from app.services.pipeline import run_pipeline
    background_tasks.add_task(run_pipeline, job_id, canonical)

    return {"jobId": job_id, "cached": False}

@router.get("/result/{job_id}")
def get_result(job_id: str, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.job_id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    if job.status == "done":
        return {"status": "done", "data": json.loads(job.result)}
    elif job.status == "failed":
        return {"status": "failed", "error": job.error}
    else:
        return {"status": "pending"}
