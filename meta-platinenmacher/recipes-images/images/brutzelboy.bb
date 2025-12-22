SUMMARY = "An image for the brutzelboy during development"
DESCRIPTION = "An image based on core-image-minimal with development and benchmark tools."
LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = " ${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"


IMAGE_INSTALL:append = " \
    connman \
    connman-client \
"
