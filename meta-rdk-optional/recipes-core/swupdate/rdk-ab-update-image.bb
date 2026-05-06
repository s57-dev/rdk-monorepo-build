DESCRIPTION = "Generate SWUpdate image for RPi4 A/B rootfs update"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://sw-description \
"

IMAGE_DEPENDS = "lib32-rdk-fullstack-image"
SWUPDATE_IMAGES = "lib32-rdk-fullstack-image"
SWUPDATE_IMAGES_FSTYPES[lib32-rdk-fullstack-image] = ".ext4.gz"

inherit swupdate
