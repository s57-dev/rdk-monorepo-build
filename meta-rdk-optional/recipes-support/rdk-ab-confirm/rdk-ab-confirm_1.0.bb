# This is an example for confirming a succesfull boot
# if the boot reaches this stage, we disable the rollback

SUMMARY = "A/B update confirmation service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

SRC_URI = " \
    file://rdk-ab-confirm.sh \
    file://rdk-ab-confirm.service \
"

S = "${WORKDIR}"

RDEPENDS:${PN} += "libubootenv-bin"

SYSTEMD_SERVICE:${PN} = "rdk-ab-confirm.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/rdk-ab-confirm.sh ${D}${sbindir}/rdk-ab-confirm.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/rdk-ab-confirm.service ${D}${systemd_system_unitdir}/rdk-ab-confirm.service
}

FILES:${PN} += " \
    ${sbindir}/rdk-ab-confirm.sh \
    ${systemd_system_unitdir}/rdk-ab-confirm.service \
"
