#!/bin/bash
set -e

# Initialize conda
. /opt/conda/etc/profile.d/conda.sh

# We activate the mitogex environment by default
conda activate mitogex

# Start Celery worker
# We use the python from the conda environment to run celery
exec python -m celery -A app.tasks.worker worker --loglevel=info --concurrency=1
