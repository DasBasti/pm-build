SUMMARY = "SWUpdate public key for signature verification"
DESCRIPTION = "Installs the public key for verifying signed SWUpdate images (development key)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://swupdate-development-key.pub"

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/swupdate/certs
    install -m 0644 ${UNPACKDIR}/swupdate-development-key.pub ${D}${sysconfdir}/swupdate/certs/swupdate.pem
}

FILES:${PN} = "${sysconfdir}/swupdate/certs/swupdate.pem"

PACKAGE_ARCH = "${MACHINE_ARCH}"
