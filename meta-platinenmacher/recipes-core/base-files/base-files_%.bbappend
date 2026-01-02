FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://home.mount \
    file://migrate-home.sh \
    file://migrate-home.service \
    file://platinenmacher-motd \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "home.mount migrate-home.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} += "bash"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/home.mount ${D}${systemd_system_unitdir}/
    install -m 0644 ${UNPACKDIR}/migrate-home.service ${D}${systemd_system_unitdir}/

    install -d ${D}${sbindir}
    install -m 0755 ${UNPACKDIR}/migrate-home.sh ${D}${sbindir}/

    install -m 0644 ${S}/platinenmacher-motd ${D}${sysconfdir}/motd
}

FILES:${PN} += "\
    ${systemd_system_unitdir}/home.mount \
    ${systemd_system_unitdir}/migrate-home.service \
    ${sbindir}/migrate-home.sh \
"
