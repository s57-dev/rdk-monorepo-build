# Monolithic RDK-E Build

Supported RDK version: RDKE-8 (draft)

## Prerequisites

- Docker

## Build the container image

```bash
./build_container.sh
```

## KAS configuration layout

```
kas/
├── include/
│   ├── repos-oss.yml            # Open Source upstream repos
│   └── repos-rdke.yml           # RDKE middleware/vendor/product repos
├── monolithic-raspberrypi4.yml         # 32-bit userspace (lib32 multilib)
└── tools/
    └── qemu-boot.yml            # QEMU overlay (Experiment, graphics may work or not)
```

## Build the image

```bash
KAS_CONTAINER_IMAGE=rdk-kas-builder:latest \
    kas-container build kas/monolithic-raspberrypi4.yml
```

### Native 64-bit (aarch64)

```
### Passing credentials

To pass `.netrc` credentials into the container:

```bash
KAS_CONTAINER_IMAGE=rdk-kas-builder:latest \
    kas-container --runtime-args "-v $HOME/.netrc:/home/builder/.netrc:ro" \
    build kas/monolithic-raspberrypi4-64.yml
```
