#!/bin/bash

# Script to run MitoGEx GUI with host X11 display forwarding

echo "Setting up X11 forwarding for Docker..."

# Automatically set USER_ID and GROUP_ID for proper file permissions
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
echo "Running as USER_ID:GROUP_ID = $USER_ID:$GROUP_ID"

# Allow Docker to connect to X11
xhost +local:docker

# Get the display variable
echo "Using DISPLAY: $DISPLAY"

# Ensure Results directory is writable on host
mkdir -p Results
chmod 775 Results

# Run with host display
docker compose run --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    mitogex bash run.sh

# Clean up
xhost -local:docker
