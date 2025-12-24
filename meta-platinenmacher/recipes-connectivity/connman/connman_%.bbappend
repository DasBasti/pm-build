# Enable WiFi support in ConnMan using iwd (iNet Wireless Daemon)
# iwd is the modern replacement for wpa_supplicant with better ConnMan integration

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://main.conf"

# Use iwd instead of wpa-supplicant - completely remove wpa-supplicant support
PACKAGECONFIG:append = " wifi iwd"
PACKAGECONFIG:remove = "wpa-supplicant"

# Ensure wpa-supplicant is not installed as a dependency
RDEPENDS:${PN}:remove = "wpa-supplicant"

do_install:append() {
    install -d ${D}${sysconfdir}/connman
    install -m 0644 ${UNPACKDIR}/main.conf ${D}${sysconfdir}/connman/main.conf
}

FILES:${PN} += "${sysconfdir}/connman/main.conf"
