SUMMARY = "Autostart unit for ScummVM in Weston"
LICENSE = "MIT"

PR = "r0"
PV = "1.0"

SRC_URI = "file://scummvm-autostart.service file://LICENSE"

FILESEXTRAPATHS := "${THISDIR}/files:${FILESEXTRAPATHS}"

inherit systemd

SYSTEMD_SERVICE = "scummvm-autostart.service"

LIC_FILES_CHKSUM = "file://LICENSE;md5=d7f4574ec7f8aa9131319609f6d975cd"

do_install() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${UNPACKDIR}/scummvm-autostart.service ${D}${systemd_unitdir}/system/scummvm-autostart.service
}

FILES:${PN} = "${systemd_unitdir}/system/scummvm-autostart.service"
