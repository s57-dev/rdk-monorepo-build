#!/bin/bash
# Builds the custom kas container image with all RDK build dependencies.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="rdk-kas-builder:latest"

docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
