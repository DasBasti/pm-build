inherit core-image

# Keep original rootfs size but partition will be image size + 1GB
IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = " ${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"


IMAGE_INSTALL:append = " \
    resize-userdata \
    parted \
    e2fsprogs-resize2fs \
    persist-config \
    thebrutzler-user \
    openssh \
    usb-automount \
"

# Network connection manager
IMAGE_INSTALL:append = " \
    connman \
    connman-client \
"

# For swupdate A/B updates
IMAGE_INSTALL:append = " \
    swupdate \
    swupdate-www \
    swupdate-usb \
    libubootenv-bin \
    swupdate-hw-compatibility \
    swupdate-bootloader-version \
    swupdate-config \
"

# Use custom WKS file for A/B partitioning
WKS_FILE = "platinenmacher-ab.wks"

# Generate ext4 image for swupdate packages
IMAGE_FSTYPES += "ext4 wic.zip"
