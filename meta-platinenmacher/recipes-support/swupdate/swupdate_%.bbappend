FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add defconfig fragment to ensure U-Boot support
SRC_URI:append = " file://defconfig-uboot.cfg"

# Override systemd service to use Type=simple instead of Type=notify
# This prevents timeout when mongoose webserver is running
SRC_URI:append = " file://swupdate.service"

# Make sure libubootenv is available at runtime
RDEPENDS:${PN}:append = " libubootenv-bin"
