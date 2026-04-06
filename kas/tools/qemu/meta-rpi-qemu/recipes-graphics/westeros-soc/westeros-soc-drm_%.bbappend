# Apply QEMU/virtio-gpu DRM mode selection patch to westeros-soc-drm.
#
# The patch adds WESTEROS_GL_USER_PREFERRED_SIZE env var support so
# westeros-gl can select a DRM mode by explicit WxH rather than relying
# on the DRM_MODE_TYPE_PREFERRED flag, which is needed for virtio-gpu.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://qemu-user-preferred-size.patch"
