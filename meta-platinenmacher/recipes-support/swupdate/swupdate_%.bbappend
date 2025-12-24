FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add defconfig fragment to ensure U-Boot support
SRC_URI:append = " file://defconfig-uboot.cfg"

# Override mongoose args to run webserver in background mode
SRC_URI:append = " file://10-mongoose-args"

# Make sure libubootenv is available at runtime
RDEPENDS:${PN}:append = " libubootenv-bin"
