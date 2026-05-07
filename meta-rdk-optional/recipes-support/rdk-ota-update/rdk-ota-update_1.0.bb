SUMMARY = "OTA update script for A/B SWUpdate"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://update_ota.sh \
    file://rdk-ota.conf \
"

S = "${WORKDIR}"

RDEPENDS:${PN} += "curl unzip libubootenv-bin swupdate"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/update_ota.sh ${D}${sbindir}/update_ota.sh

    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/rdk-ota.conf ${D}${sysconfdir}/rdk-ota.conf
}

FILES:${PN} += " \
    ${sbindir}/update_ota.sh \
    ${sysconfdir}/rdk-ota.conf \
"
