SUMMARY = "Persistent configuration management"
DESCRIPTION = "Manages persistent system configuration across updates"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://persist-config.sh \
    file://persist-config.service \
    file://restore-config.sh \
    file://restore-config.service \
"

S = "${UNPACKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "persist-config.service restore-config.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} = "bash rsync"

do_install() {
    # Install scripts
    install -d ${D}${sbindir}
    install -m 0755 ${S}/persist-config.sh ${D}${sbindir}/
    install -m 0755 ${S}/restore-config.sh ${D}${sbindir}/

    # Install systemd services
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/persist-config.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/restore-config.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} = "\
    ${sbindir}/persist-config.sh \
    ${sbindir}/restore-config.sh \
    ${systemd_system_unitdir}/persist-config.service \
    ${systemd_system_unitdir}/restore-config.service \
"
