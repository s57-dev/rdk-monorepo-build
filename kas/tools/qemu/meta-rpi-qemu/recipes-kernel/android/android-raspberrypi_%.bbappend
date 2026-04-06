# Append virtio kernel config fragment so the android-raspberrypi kernel
# can boot inside QEMU's "virt" machine without needing an initramfs.
#
# The recipe inherits linux-yocto.inc which automatically merges .cfg
# fragments from SRC_URI into the kernel config.

FILESEXTRAPATHS:prepend := "${THISDIR}/qemu-files:"
SRC_URI += "file://qemu-virtio.cfg"
