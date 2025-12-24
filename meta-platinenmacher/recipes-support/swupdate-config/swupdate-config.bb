SUMMARY = "SWUpdate configuration file"
DESCRIPTION = "Provides swupdate.cfg for automatic A/B partition selection"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://swupdate.cfg \
    file://detect-rootfs.sh \
"

inherit allarch

S = "${UNPACKDIR}"

RDEPENDS:${PN} = "bash libubootenv-bin util-linux"

do_install() {
    install -d ${D}${sysconfdir}/swupdate
    install -m 0644 ${UNPACKDIR}/swupdate.cfg ${D}${sysconfdir}/swupdate/swupdate.cfg

    install -d ${D}${sbindir}
    install -m 0755 ${UNPACKDIR}/detect-rootfs.sh ${D}${sbindir}/detect-rootfs
}

FILES:${PN} = "\
    ${sysconfdir}/swupdate/swupdate.cfg \
    ${sbindir}/detect-rootfs \
"
