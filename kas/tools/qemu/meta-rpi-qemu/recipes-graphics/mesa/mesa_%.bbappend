# Enable the virgl (virtio-gpu 3D) and software (llvmpipe) gallium
# drivers so the guest can render graphics inside QEMU.

PACKAGECONFIG:append = " gallium"
GALLIUMDRIVERS:append = ",virgl,swrast"
