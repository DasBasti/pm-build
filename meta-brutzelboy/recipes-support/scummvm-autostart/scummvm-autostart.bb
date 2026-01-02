SUMMARY = "Autostart unit for ScummVM in Weston"
LICENSE = "MIT"

PR = "r0"

SRC_URI = "file://scummvm-autostart.service"

FILESEXTRAPATHS := "${THISDIR}/files:${FILESEXTRAPATHS}"

inherit systemd

SYSTEMD_SERVICE = "scummvm-autostart.service"

do_install() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/scummvm-autostart.service ${D}${systemd_unitdir}/system/scummvm-autostart.service
}

FILES:${PN} = "${systemd_unitdir}/system/scummvm-autostart.service"
