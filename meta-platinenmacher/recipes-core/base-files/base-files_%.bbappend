FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
    file://home.mount \
    file://motd \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "home.mount"
SYSTEMD_AUTO_ENABLE = "enable"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/home.mount ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/home.mount"
