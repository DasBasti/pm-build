SUMMARY = "Bootloader version tracking for swupdate"
DESCRIPTION = "Creates /etc/bootloader-version file and service for tracking bootloader updates"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://swupdate-set-bootenv.sh \
    file://swupdate-bootenv.service \
    file://fw_env.config \
"

S = "${UNPACKDIR}"

inherit systemd allarch

SYSTEMD_SERVICE:${PN} = "swupdate-bootenv.service"
SYSTEMD_AUTO_ENABLE = "enable"

# Get version from U-Boot - use a default if not available
BOOTLOADER_VERSION ??= "2025.01"

RDEPENDS:${PN} = "libubootenv-bin bash"

do_install() {
    # Install bootloader version file
    install -d ${D}${sysconfdir}
    echo "${BOOTLOADER_VERSION}" > ${D}${sysconfdir}/bootloader-version

    # Install fw_env.config for U-Boot environment access
    install -m 0644 ${S}/fw_env.config ${D}${sysconfdir}/fw_env.config

    # Install script
    install -d ${D}${sbindir}
    install -m 0755 ${S}/swupdate-set-bootenv.sh ${D}${sbindir}/

    # Install systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/swupdate-bootenv.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} = "\
    ${sysconfdir}/bootloader-version \
    ${sysconfdir}/fw_env.config \
    ${sbindir}/swupdate-set-bootenv.sh \
    ${systemd_system_unitdir}/swupdate-bootenv.service \
"
