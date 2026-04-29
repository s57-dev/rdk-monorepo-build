# Monolithic RDK-E Build

Supported RDK version: RDKE-8 (draft)

## Prerequisites

- Docker
- Python3, Python venv and kas:

```
python3 -m venv venv/
source venv/bin/activate
pip install kas
```

## Build the container image

```bash
./build_container.sh
```

## KAS configuration layout

```
kas/
├── extras/
│   └── factoryapps-solution57.json # Prebuilt bolt artifacts + key manifest
├── include/
│   ├── repos-oss.yml            # Open Source upstream repos
│   └── repos-rdke.yml           # RDKE middleware/vendor/product repos
├── monolithic-raspberrypi4.yml  # 32-bit userspace
└── tools/
    └── qemu-boot.yml            # QEMU overlay (Experiment, graphics may work or not)
```

## Build the image

```bash
KAS_CONTAINER_IMAGE=rdk-kas-builder:latest \
    kas-container build kas/monolithic-raspberrypi4.yml
```

### Passing credentials

To pass `.netrc` credentials into the container:

```bash
KAS_CONTAINER_IMAGE=rdk-kas-builder:latest \
    kas-container --runtime-args "-v $HOME/.netrc:/home/builder/.netrc:ro" \
    build kas/monolithic-raspberrypi4-64.yml
```
