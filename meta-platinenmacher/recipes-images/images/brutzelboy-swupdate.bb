SUMMARY = "SWUpdate package for brutzelboy"
DESCRIPTION = "SWUpdate package containing rootfs for A/B updates"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = "file://sw-description"

# This image depends on the actual rootfs image
IMAGE_DEPENDS = "brutzelboy"

# Specify which images to include in the SWU file
SWUPDATE_IMAGES = "brutzelboy"

# Specify the filesystem type to package
SWUPDATE_IMAGES_FSTYPES[brutzelboy] = ".rootfs.ext4"
