FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add defconfig fragment to ensure U-Boot support
SRC_URI:append = "\
    file://defconfig-diskpart.cfg \
    file://defconfig-uboot.cfg \
    file://defconfig-signing.cfg \
    file://defconfig-systemd.cfg \
"

# Make sure libubootenv is available at runtime
RDEPENDS:${PN}:append = " libubootenv-bin"

# Add dependency on public key for signature verification
RDEPENDS:${PN}:append = " swupdate-key"
