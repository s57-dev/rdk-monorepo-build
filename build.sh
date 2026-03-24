#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="rdk-kas-builder:latest"
KAS_FILE="monolithic-raspberrypi4-64.yml"

docker image inspect "$IMAGE_NAME" >/dev/null 2>&1 || \
    docker build --build-arg USER_ID="$(id -u)" --build-arg GROUP_ID="$(id -g)" \
        -t "$IMAGE_NAME" "$SCRIPT_DIR"

NETRC_MOUNT=()
[ -f "${HOME}/.netrc" ] && NETRC_MOUNT=(-v "${HOME}/.netrc:/home/rdk/.netrc:ro")

exec docker run --rm -it \
    -v "$SCRIPT_DIR:/work" \
    "${NETRC_MOUNT[@]}" \
    --workdir /work \
    "$IMAGE_NAME" \
    kas build "$KAS_FILE"
