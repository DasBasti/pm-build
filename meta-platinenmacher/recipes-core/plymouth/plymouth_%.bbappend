# Add custom splash image and a minimal theme that uses it
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://splash.png \
    file://platinenmacher.plymouth \
    file://platinenmacher.script \
    file://plymouthd.conf\
"

# Ensure files are installed into a dedicated theme directory and set default theme

do_install:append() {
    install -d ${D}${datadir}/plymouth/themes/platinenmacher
    install -m 0644 ${UNPACKDIR}/splash.png ${D}${datadir}/plymouth/themes/platinenmacher/splash.png
    install -m 0644 ${UNPACKDIR}/platinenmacher.plymouth ${D}${datadir}/plymouth/themes/platinenmacher/platinenmacher.plymouth
    install -m 0755 ${UNPACKDIR}/platinenmacher.script ${D}${datadir}/plymouth/themes/platinenmacher/platinenmacher.script

    install -d ${D}${sysconfdir}/plymouth
    install -m 0644 ${UNPACKDIR}/plymouthd.conf ${D}${sysconfdir}/plymouth/plymouthd.conf
}

# Ensure theme files are included in the main package
FILES:${PN} += "${datadir}/plymouth/themes/platinenmacher/* ${sysconfdir}/plymouth/plymouthd.conf"

# Enable DRM/KMS backend on arm64 so plymouth can use KMS for early graphics if needed
PACKAGECONFIG:append:arm64 = " drm"
