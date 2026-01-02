# Install systemd unit to autostart ScummVM in the Weston session
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://scummvm-autostart.service \
"

SYSTEMD_SERVICE:${PN} = "scummvm-autostart.service"

FILES:${PN} += "\
    ${systemd_unitdir}/system/scummvm-autostart.service \
"

do_install_append() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/scummvm-autostart.service ${D}${systemd_unitdir}/system/scummvm-autostart.service
}
