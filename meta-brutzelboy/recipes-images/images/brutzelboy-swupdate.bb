SUMMARY = "SWUpdate full package for brutzelboy with bootloader"
DESCRIPTION = "SWUpdate package containing rootfs and bootloader for A/B updates with version checking"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

# This image depends on the actual rootfs image and u-boot
IMAGE_DEPENDS = "brutzelboy virtual/bootloader"

# Specify which images to include in the SWU file
SWUPDATE_IMAGES = "brutzelboy idbloader.img u-boot.itb"

# Specify the filesystem type to package
SWUPDATE_IMAGES_FSTYPES[brutzelboy] = ".rootfs.ext4"

# Enable RSA signing of SWUpdate packages with development key
SWUPDATE_SIGNING = "RSA"
SWUPDATE_PRIVATE_KEY = "${THISDIR}/../../../meta-platinenmacher/recipes-support/swupdate-key/files/swupdate-development-key.pem"

SRC_URI = "\
    file://sw-description \
"
