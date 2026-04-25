from celery import Celery
import subprocess
import os
import shutil
from datetime import datetime
from app.core.config import settings
from app.core.storage import get_s3_client
from app.models.models import JobStatus, Job
from app.db.session import SessionLocal

celery_app = Celery("worker", broker=settings.REDIS_URL, backend=settings.REDIS_URL)

def update_job_status(job_id: int, status: JobStatus, started: bool = False, finished: bool = False):
    db = SessionLocal()
    try:
        job = db.query(Job).filter(Job.id == job_id).first()
        if job:
            job.status = status
            if started:
                job.started_at = datetime.utcnow()
            if finished:
                job.finished_at = datetime.utcnow()
            db.commit()
    finally:
        db.close()

@celery_app.task(name="run_mitogex_pipeline")
def run_mitogex_pipeline(job_id: int, params: dict):
    """
    Background task to run the bioinformatics pipeline.
    """
    # 1. Update status to RUNNING
    update_job_status(job_id, JobStatus.RUNNING, started=True)
    
    # 2. Setup temporary workspace
    work_dir = f"/tmp/job_{job_id}"
    os.makedirs(work_dir, exist_ok=True)
    os.makedirs(f"{work_dir}/input", exist_ok=True)
    os.makedirs(f"{work_dir}/output", exist_ok=True)
    
    s3 = get_s3_client()
    
    try:
        # 3. Download input files from SeaweedFS
        # Assuming params contains a list of S3 keys under 'input_keys'
        input_keys = params.get("input_keys", [])
        local_inputs = []
        for key in input_keys:
            local_path = os.path.join(work_dir, "input", os.path.basename(key))
            s3.download_file(settings.S3_BUCKET, key, local_path)
            local_inputs.append(local_path)
        
        # 4. Execute the bash pipeline
        # We invoke the original pipeline script
        # Note: The worker Dockerfile ensures all tools (BWA, GATK) are in PATH
        script_path = "/scripts/pipeline_rCRS.sh"
        
        # Construct the command (adapting to the existing script's arguments)
        # Based on README, the script usually takes a directory or specific files
        command = [
            "bash", script_path,
            "-i", f"{work_dir}/input",
            "-o", f"{work_dir}/output",
            "-t", str(params.get("threads", 4))
        ]
        
        log_file_path = f"{work_dir}/pipeline.log"
        with open(log_file_path, "w") as log_file:
            process = subprocess.Popen(
                command,
                stdout=log_file,
                stderr=subprocess.STDOUT,
                universal_newlines=True
            )
            process.wait()
            
        if process.returncode != 0:
            raise Exception(f"Pipeline failed with return code {process.returncode}. Check logs for details.")

        # 5. Upload results back to SeaweedFS
        # Upload the entire output directory
        for root, dirs, files in os.walk(f"{work_dir}/output"):
            for file in files:
                local_file = os.path.join(root, file)
                s3_key = f"results/{job_id}/" + os.path.relpath(local_file, f"{work_dir}/output")
                s3.upload_file(local_file, settings.S3_BUCKET, s3_key)
        
        # Upload the log file too
        s3.upload_file(log_file_path, settings.S3_BUCKET, f"results/{job_id}/pipeline.log")

        # 6. Final Update
        update_job_status(job_id, JobStatus.COMPLETED, finished=True)
        
    except Exception as e:
        print(f"Error in Job {job_id}: {str(e)}")
        # Log error to S3 if possible
        with open(f"{work_dir}/error.log", "w") as f:
            f.write(str(e))
        try:
            s3.upload_file(f"{work_dir}/error.log", settings.S3_BUCKET, f"results/{job_id}/error.log")
        except:
            pass
            
        update_job_status(job_id, JobStatus.FAILED, finished=True)
    
    finally:
        # 7. Cleanup local scratch space
        shutil.rmtree(work_dir, ignore_errors=True)

    return {"status": "finished", "job_id": job_id}
