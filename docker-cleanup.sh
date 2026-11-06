#!/bin/bash
#
# Script Name: docker-cleanup.sh
# Description: Safely cleans up unused Docker resources to reclaim disk space.
#

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure script is run with proper privileges (or user has docker socket access)
if ! docker info &>/dev/null; then
    echo "[ERROR]: Cannot connect to the Docker daemon. Are you running with sufficient privileges?" >&2
    exit 1
fi

echo "=========================================="
echo " Starting Docker Environment Cleanup"
echo "=========================================="

echo "[INFO]: Stopping and removing exited/stopped containers..."
docker container prune -f

echo ""
echo "[INFO]: Removing dangling images..."
docker image prune -f

echo ""
echo "[INFO]: Removing unused volumes (dangling)..."
docker volume prune -f

echo ""
echo "[INFO]: Cleaning up build cache..."
docker builder prune -f --all

echo ""
echo "=========================================="
echo " Docker Cleanup Complete!"
echo "=========================================="
docker system df
