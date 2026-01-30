#!/bin/bash
# Helper script to set up Docker environment for MitoGEx

set -e

echo "=== MitoGEx Docker Setup ==="

# Create necessary directories
mkdir -p data references Logs

# Download reference genomes (if not already present)
if [ ! -d "references/hg38" ]; then
    echo "Downloading hg38 reference genome..."
    cd references
    wget https://mitogex.com/references/hg38.zip && unzip hg38.zip && rm hg38.zip
    wget https://mitogex.com/references/chrM.zip && unzip chrM.zip && rm chrM.zip
    cd ..
fi

# Set X11 permissions (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Setting X11 permissions..."
    xhost +local:docker
fi

# Build Docker image
echo "Building Docker image..."
docker compose build

echo "=== Setup Complete ==="
echo ""
echo "To start MitoGEx:"
echo "  docker compose run --rm mitogex"
echo ""
echo "To run the GUI application:"
echo "  ./run-gui-x11.sh"
