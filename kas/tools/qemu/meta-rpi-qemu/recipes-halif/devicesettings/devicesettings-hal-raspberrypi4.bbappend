# Override the DRI_CARD cmake definition for QEMU virtio-gpu.
# The vendor recipe hardcodes -DDRI_CARD=/dev/dri/card1 for the RPi VC4 GPU.
# In QEMU the virtio-gpu DRM device is /dev/dri/card0.

EXTRA_OECMAKE:remove = "-DDRI_CARD=/dev/dri/card1"
EXTRA_OECMAKE += "-DDRI_CARD=/dev/dri/card0"
