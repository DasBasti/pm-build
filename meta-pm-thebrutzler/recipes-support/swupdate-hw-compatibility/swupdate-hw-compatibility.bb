SUMMARY = "Hardware compatibility file for SWUpdate"
DESCRIPTION = "Provides hardware revision information for SWUpdate compatibility checking"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://hwrevision"

inherit allarch

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${UNPACKDIR}/hwrevision ${D}${sysconfdir}/hwrevision
}

FILES:${PN} = "${sysconfdir}/hwrevision"
