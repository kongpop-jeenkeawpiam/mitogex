# MitoGEx Docker Deployment Guide

## Prerequisites

- Docker
- For GUI: X11 server (Linux) or VcXsrv/X410 (Windows)

## Quick Start

### 1. Build and Setup

```bash
# Make setup script executable
chmod +x docker-setup.sh

# Run setup (downloads references, builds image)
./docker-setup.sh
```

### 2. Run MitoGEx

**Interactive Shell:**
```bash
docker compose run --rm mitogex
```

**GUI Application:**
```bash
chmod +x run-gui-x11.sh
./run-gui-x11.sh
```


## Directory Structure

```
.
├── Dockerfile              # Main Docker image definition
├── docker_compose.yml      # Docker Compose configuration
├── .dockerignore          # Build context exclusions
├── docker-setup.sh         # Setup helper script
├── run-gui-x11.sh       # GUI launcher script
├── DOCKER_README.md        # This file
├── data/                   # Input data (mounted volume)
├── Results/                 # Results (mounted volume)
├── references/             # Reference genomes (mounted volume)
└── Logs/                   # Application logs (mounted volume)
```

## Volume Mounts

- `./data` → Container input directory
- `./Results` → Container results directory
- `./references` → Reference genomes (hg38, chrM)
- `./Logs` → Application logs

## Running Analysis

```bash
# Enter container
docker compose run --rm mitogex bash

# Activate conda environment (if needed)
conda activate mitogex

# Place your FASTQ files in ./data/
# Run your analysis commands
# Results will appear in ./Results/
```

## GUI Setup by Platform

### Linux
```bash
xhost +local:docker
docker compose run --rm mitogex bash run.sh
```



## Resource Configuration

Edit `docker compose.yml` to adjust:
- CPU limits: `cpus: '8'`
- Memory: `memory: 16G`

## Troubleshooting

### Issue: GUI won't start
- Ensure X11 server is running
- Check DISPLAY variable: `echo $DISPLAY`
- Verify X11 socket mount: `ls /tmp/.X11-unix`

### Issue: Permission denied
- Run: `xhost +local:docker`
- Check volume permissions: `ls -la ./data`

### Issue: Out of memory
- Increase Docker memory limit in Docker Desktop settings
- Adjust limits in docker compose.yml

### Issue: Reference files missing
- Manually download to `./references/`:
  - https://mitogex.com/references/hg38.zip
  - https://mitogex.com/references/chrM.zip

### Issue: Build fails
- Check Docker has enough disk space
- Try: `docker system prune -a`
- Rebuild: `docker compose build --no-cache`


## Environment Customization

### Multiple Samples Processing

Place samples in subdirectories under `./data/`:
```
data/
├── sample1_1.fastq.gz
├── sample1_2.fastq.gz
├── sample2_1.fastq.gz
└── sample2_2.fastq.gz
```



