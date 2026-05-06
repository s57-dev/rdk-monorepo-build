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

## SWUpdate + A/B overlay

Build with the optional SWUpdate A/B layer supprot and recovery. This will be a much larger image, since
it contains both A and B partitions. 

```bash
KAS_CONTAINER_IMAGE=rdk-kas-builder:latest \
    kas-container build kas/monolithic-raspberrypi4.yml:kas/extras/swupdate.yml
```

This produces:

- SD image with `boot + rootfsA + rootfsB + data` partitions


To generate an OTA update file:

```bash
KAS_CONTAINER_IMAGE=rdk-kas-builder:latest \
    kas-container build kas/monolithic-raspberrypi4.yml:kas/extras/swupdate.yml \
    --target rdk-ab-update-image
```

The output is:

- `build/tmp/deploy/images/<machine>/*.swu`

Install to the inactive rootfs slot on target:

```bash
# when currently booted from mmcblk0p2
swupdate -e stable,copy2 -H raspberrypi4-64-rdke:1.0 -i /path/to/rdk-ab-update-image-*.swu -v

# when currently booted from mmcblk0p3
swupdate -e stable,copy1 -H raspberrypi4-64-rdke:1.0 -i /path/to/rdk-ab-update-image-*.swu -v
```

How it works

- active slot is stored in U-Boot env as `slot` (`a` or `b`)
- boot mapping is `a -> /dev/mmcblk0p2`, `b -> /dev/mmcblk0p3`
- Checking and setting the slots: `fw_printenv slot`, `fw_setenv slot a`/`fw_setenv slot b`. SWUpdate automatically switches the slots

