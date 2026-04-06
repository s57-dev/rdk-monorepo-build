#!/usr/bin/env bash
# ===================================================================
# run-qemu-rpi.sh — Boot the RDK RPi4 image inside QEMU
#
# Usage:
#   ./run-qemu-rpi.sh                  # graphical with virgl 3D
#   ./run-qemu-rpi.sh --no-gl          # graphical, software GPU
#   ./run-qemu-rpi.sh --nographic      # serial console only
#
# ===================================================================
set -euo pipefail

# ---- Pre-flight checks ---------------------------------------------
missing=()
for cmd in qemu-system-aarch64 qemu-img; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
done
if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: Missing required commands: ${missing[*]}" >&2
    echo "       Install with:  sudo apt install qemu-system-arm qemu-utils" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../../.."
MACHINE="raspberrypi4-64-rdke"
IMAGE_BASENAME="lib32-rdk-fullstack-image"
DEPLOY_DIR="${REPO_ROOT}/build/tmp/deploy/images/${MACHINE}"

NOGRAPHIC=0
GL_MODE="on"
MEM="4048"
SMP="12"
SSH_PORT="2222"
EXTRA_ARGS=()

# ---- Parse arguments -----------------------------------------------
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --nographic       Disable graphical output (serial console only)
  --no-gl           Graphical mode without GL acceleration (sw rendering)
  --mem=N           Guest RAM in MiB (default: $MEM)
  --smp=N           Guest vCPUs      (default: $SMP)
  --ssh-port=N      Host port forwarded to guest :22 (default: $SSH_PORT)
  --kernel=PATH     Override kernel image path
  --rootfs=PATH     Override rootfs image path
  --deploy-dir=PATH Override deploy directory
  --                Pass remaining args directly to QEMU
  -h, --help        Show this help
EOF
    exit 0
}

KERNEL=""
ROOTFS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --nographic)    NOGRAPHIC=1;        shift ;;
        --no-gl)        GL_MODE="off";      shift ;;
        --mem=*)        MEM="${1#*=}";       shift ;;
        --smp=*)        SMP="${1#*=}";       shift ;;
        --ssh-port=*)   SSH_PORT="${1#*=}";  shift ;;
        --kernel=*)     KERNEL="${1#*=}";    shift ;;
        --rootfs=*)     ROOTFS="${1#*=}";    shift ;;
        --deploy-dir=*) DEPLOY_DIR="${1#*=}";shift ;;
        -h|--help)      usage ;;
        --)             shift; EXTRA_ARGS+=("$@"); break ;;
        *)  echo "Unknown option: $1 (use -- to pass args to QEMU)"; exit 1 ;;
    esac
done

# ---- Locate build artifacts ----------------------------------------
find_artifact() {
    local pattern="$1" desc="$2"
    local found
    found=$(find "$DEPLOY_DIR" -maxdepth 1 -name "$pattern" -not -name "*.qcow2" \
                 -type l -o -name "$pattern" -not -name "*.qcow2" -type f \
            2>/dev/null | head -1)
    if [[ -z "$found" ]]; then
        echo "ERROR: $desc not found (pattern: $DEPLOY_DIR/$pattern)" >&2
        exit 1
    fi
    echo "$found"
}

if [[ -z "$KERNEL" ]]; then
    KERNEL=$(find_artifact "Image" "Kernel image")
fi

if [[ -z "$ROOTFS" ]]; then
    ROOTFS=$(find_artifact "${IMAGE_BASENAME}-${MACHINE}.ext4" "Root filesystem (ext4)")
fi

# ---- Create QCOW2 overlay (copy-on-write) --------------------------
# This avoids mutating the original build artifact.
OVERLAY="${ROOTFS}.qcow2"
if [[ ! -f "$OVERLAY" ]] || [[ "$ROOTFS" -nt "$OVERLAY" ]]; then
    echo "Creating QCOW2 overlay (base: $(basename "$ROOTFS"))..."
    qemu-img create -f qcow2 -b "$ROOTFS" -F raw "$OVERLAY" 8G
fi

# ---- Build QEMU command line ----------------------------------------
QEMU_CMD=(
    qemu-system-aarch64
    -machine virt,gic-version=3
    -cpu    cortex-a72
    -smp    "$SMP"
    -m      "$MEM"

    -kernel "$KERNEL"
    -drive  "file=${OVERLAY},format=qcow2,if=virtio"
    -netdev "user,id=net0,hostfwd=tcp::${SSH_PORT}-:22"
    -device "virtio-net-device,netdev=net0"

    -device "virtio-rng-device"
    -device "virtio-sound-pci"
    -accel tcg,thread=multi
    -serial mon:stdio
)

KCMD="root=/dev/vda rw earlycon loglevel=7"

if [[ "$NOGRAPHIC" -eq 1 ]]; then
    KCMD+=" console=ttyAMA0,115200"
    QEMU_CMD+=(-nographic)
else
    KCMD+=" console=ttyAMA0,115200 console=tty0"

    if [[ "$GL_MODE" == "on" ]]; then
        QEMU_CMD+=(
            -device "virtio-gpu-gl-pci,edid=on,xres=1280,yres=720"
            -display gtk,gl=on
        )
    else
        QEMU_CMD+=(
            -device "virtio-gpu-gl-pci,edid=on,xres=1280,yres=720"
            -display gtk
        )
    fi
    QEMU_CMD+=(-device virtio-keyboard-pci -device virtio-mouse-pci)
fi
KCMD+=" video=Virtual-1:1280x720@60"
QEMU_CMD+=(-append "$KCMD")

QEMU_CMD+=("${EXTRA_ARGS[@]}")

# ---- Launch ----------------------------------------------------------
cat <<EOF
╔══════════════════════════════════════════════════════════════╗
║              QEMU  ·  RDK RPi4 (aarch64)                     ║
╠══════════════════════════════════════════════════════════════╣
║  Kernel   : $(basename "$KERNEL")
║  RootFS   : $(basename "$OVERLAY")
║  Memory   : ${MEM}M  ·  CPUs: ${SMP}
║  SSH      : ssh -p ${SSH_PORT} root@localhost
║  Graphics : $(printf '%-46s' "$([ "$NOGRAPHIC" -eq 1 ] && echo "disabled (serial only)" || echo "virtio-gpu (GL=${GL_MODE})")")
╚══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo "$ ${QEMU_CMD[*]}"
echo ""

exec "${QEMU_CMD[@]}"
