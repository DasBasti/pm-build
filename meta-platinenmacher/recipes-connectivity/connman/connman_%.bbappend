# Enable WiFi support in ConnMan using iwd (iNet Wireless Daemon)
# iwd is the modern replacement for wpa_supplicant with better ConnMan integration

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://main.conf"

# Use iwd instead of wpa-supplicant for better reliability and ConnMan integration
PACKAGECONFIG:append = " wifi iwd"
PACKAGECONFIG:remove = "wpa-supplicant"

do_install:append() {
    install -d ${D}${sysconfdir}/connman
    install -m 0644 ${UNPACKDIR}/main.conf ${D}${sysconfdir}/connman/main.conf
}

FILES:${PN} += "${sysconfdir}/connman/main.conf"
