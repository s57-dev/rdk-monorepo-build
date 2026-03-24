# Monolithic RDK-E Build for Raspberry Pi 4

Builds a complete RDK-E image from source with a single command. Alternative to the
multi-layer IPK pipeline — all layers are checked out and built together, so any
recipe change across any layer produces a new image without rebuilding
intermediate IPK feeds.

## Prerequisites

- Docker
- Git credentials for `code.rdkcentral.com` in `~/.netrc`

## Build

```bash
# Using the wrapper script
./build.sh

# Or run the container directly
docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) \
    -t rdk-kas-builder:latest .
docker run --rm -it -v "$PWD:/work" -v "$HOME/.netrc:/home/rdk/.netrc:ro" \
    --workdir /work rdk-kas-builder:latest kas build monolithic-raspberrypi4-64.yml

# Or natively
pip install kas
kas build monolithic-raspberrypi4-64.yml
```
