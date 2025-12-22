SUMMARY = "First boot userdata partition resize service"
DESCRIPTION = "Systemd service to expand userdata partition to fill remaining disk space"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://resize-userdata.sh \
    file://resize-userdata.service \
"

inherit systemd

S = "${UNPACKDIR}"

SYSTEMD_SERVICE:${PN} = "resize-userdata.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} = "parted e2fsprogs-resize2fs util-linux bash gptfdisk"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${UNPACKDIR}/resize-userdata.sh ${D}${sbindir}/

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/resize-userdata.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} = "${sbindir}/resize-userdata.sh ${systemd_system_unitdir}/resize-userdata.service"
