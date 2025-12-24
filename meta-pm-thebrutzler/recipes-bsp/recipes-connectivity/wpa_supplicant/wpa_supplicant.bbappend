# When using ConnMan for network management, we must mask the standalone
# wpa_supplicant systemd service to prevent conflicts. ConnMan will start
# and manage wpa_supplicant instances internally on a per-interface basis.
# Running wpa_supplicant as a standalone service causes authentication
# timeouts and prevents ConnMan from properly managing WiFi connections.

SYSTEMD_SERVICE:${PN}:remove = "wpa_supplicant.service"

do_install:append() {
    # Mask wpa_supplicant.service to prevent it from running
    # ConnMan will start wpa_supplicant when needed
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/systemd/system
        ln -sf /dev/null ${D}${sysconfdir}/systemd/system/wpa_supplicant.service
    fi
}

FILES:${PN} += "${sysconfdir}/systemd/system/wpa_supplicant.service"
