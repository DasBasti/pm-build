SUMMARY = "udev rules for Valve Steam Controller"
DESCRIPTION = "Provides udev rules to enable Steam Controller access for the input group \
               and tags the device as a pointer for libinput/Weston recognition."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://70-steam-controller.rules"

S = "${UNPACKDIR}"
do_install() {
    install -d ${D}${nonarch_base_libdir}/udev/rules.d
    install -m 0644 ${S}/70-steam-controller.rules ${D}${nonarch_base_libdir}/udev/rules.d/
}

FILES:${PN} = "${nonarch_base_libdir}/udev/rules.d/*"

RDEPENDS:${PN} = "udev"
