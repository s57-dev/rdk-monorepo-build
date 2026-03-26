# Monolithic RDK-E Build 

Builds a complete RDK-E image from source with a single command. Alternative to the
multi-layer IPK pipeline — all layers are checked out and built together, so any
recipe change across any layer produces a new image without rebuilding
intermediate IPK feeds.

Supported RDK version: RDKE-8 (draft)

## Prerequisites

- Docker
- Git credentials for `code.rdkcentral.com` in `~/.netrc`

## Build the container image

```bash
./build_container.sh
```

## Build the image

```bash
KAS_CONTAINER_IMAGE=rdk-kas-builder:latest \
    kas-container build kas/monolithic-raspberrypi4-64.yml
```

To pass `.netrc` credentials into the container:

```bash
KAS_CONTAINER_IMAGE=rdk-kas-builder:latest \
    kas-container --runtime-args "-v $HOME/.netrc:/home/builder/.netrc:ro" \
    build kas/monolithic-raspberrypi4-64.yml
```
