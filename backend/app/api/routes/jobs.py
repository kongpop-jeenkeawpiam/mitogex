from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import uuid

from app import models, schemas
from app.api import deps
from app.db.session import get_db
from app.core import storage
from app.tasks.worker import run_mitogex_pipeline

router = APIRouter()

@router.get("/", response_model=List[schemas.Job])
def read_jobs(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(deps.get_current_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """
    Retrieve jobs.
    """
    jobs = db.query(models.Job).filter(models.Job.owner_id == current_user.id).offset(skip).limit(limit).all()
    return jobs

@router.post("/", response_model=schemas.Job)
def create_job(
    *,
    db: Session = Depends(get_db),
    job_in: schemas.JobCreate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Create new job and trigger the pipeline.
    """
    job = models.Job(
        title=job_in.title,
        parameters=job_in.parameters,
        owner_id=current_user.id,
        status=models.JobStatus.PENDING
    )
    db.add(job)
    db.commit()
    db.refresh(job)
    
    # Trigger Celery Task
    run_mitogex_pipeline.delay(job.id, job_in.parameters)
    
    return job

@router.post("/upload-url")
def get_upload_url(
    request: schemas.StorageUploadRequest,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Generate a presigned URL for direct upload to SeaweedFS.
    """
    # Generate a unique object name to prevent collisions
    unique_filename = f"{uuid.uuid4()}_{request.filename}"
    presigned_url = storage.generate_presigned_upload_url(unique_filename)
    
    if not presigned_url:
        raise HTTPException(status_code=500, detail="Could not generate upload URL")
        
    return {"url": presigned_url, "key": unique_filename}
