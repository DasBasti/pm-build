SUMMARY = "SWUpdate configuration file"
DESCRIPTION = "Provides swupdate.cfg for automatic A/B partition selection"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://swupdate.cfg \
    file://detect-rootfs.sh \
    file://post-update.sh \
    file://00-detect-rootfs \
    file://01-signing \
    file://fw-mark-boot-good.sh \
    file://fw-mark-boot-good.service \
"

inherit allarch
inherit systemd

SYSTEMD_SERVICE:${PN} = "fw-mark-boot-good.service"
SYSTEMD_AUTO_ENABLE = "enable"

S = "${UNPACKDIR}"

RDEPENDS:${PN} = "bash libubootenv-bin util-linux"

do_install() {
    install -d ${D}${sysconfdir}/swupdate
    install -m 0644 ${UNPACKDIR}/swupdate.cfg ${D}${sysconfdir}/swupdate/swupdate.cfg

    install -d ${D}${libexecdir}
    install -m 0755 ${UNPACKDIR}/detect-rootfs.sh ${D}${libexecdir}/swupdate-detect-rootfs
    install -m 0755 ${S}/fw-mark-boot-good.sh ${D}${libexecdir}/fw-mark-boot-good.sh
    install -m 0755 ${S}/post-update.sh ${D}${libexecdir}/post-update.sh

    install -d ${D}${libdir}/swupdate/conf.d/
    install -m 0755 ${UNPACKDIR}/00-detect-rootfs ${D}${libdir}/swupdate/conf.d/00-detect-rootfs
    install -m 0644 ${UNPACKDIR}/01-signing ${D}${libdir}/swupdate/conf.d/01-signing

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/fw-mark-boot-good.service ${D}${systemd_system_unitdir}/fw-mark-boot-good.service
}

FILES:${PN} = "\
    ${sysconfdir}/swupdate/swupdate.cfg \
    ${libexecdir}/swupdate-detect-rootfs \
    ${libexecdir}/fw-mark-boot-good.sh \
    ${libexecdir}/post-update.sh \
    ${libdir}/swupdate/conf.d/00-detect-rootfs \
    ${libdir}/swupdate/conf.d/01-signing \
    ${systemd_system_unitdir}/fw-mark-boot-good.service \
"
