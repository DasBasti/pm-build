SUMMARY = "USB automount service"
DESCRIPTION = "Automatically mount USB storage devices to /media when plugged in"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://usb-automount.sh \
    file://usb-automount-umount.sh \
    file://usb-automount@.service \
    file://99-usb-automount.rules \
"

S = "${UNPACKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "usb-automount@.service"
# Note: This is a template unit, activated by udev, not enabled directly
SYSTEMD_AUTO_ENABLE = "disable"

RDEPENDS:${PN} = "bash util-linux-mount util-linux-umount util-linux-blkid"

do_install() {
    # Install scripts
    install -d ${D}${sbindir}
    install -m 0755 ${S}/usb-automount.sh ${D}${sbindir}/
    install -m 0755 ${S}/usb-automount-umount.sh ${D}${sbindir}/

    # Install systemd service template
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/usb-automount@.service ${D}${systemd_system_unitdir}/

    # Install udev rules
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${S}/99-usb-automount.rules ${D}${sysconfdir}/udev/rules.d/

    # Create mount point directory
    install -d ${D}/media
}

FILES:${PN} = "\
    ${sbindir}/usb-automount.sh \
    ${sbindir}/usb-automount-umount.sh \
    ${systemd_system_unitdir}/usb-automount@.service \
    ${sysconfdir}/udev/rules.d/99-usb-automount.rules \
    /media \
"
