SUMMARY = "SWUpdate full package for brutzelboy with bootloader"
DESCRIPTION = "SWUpdate package containing rootfs and bootloader for A/B updates with version checking"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = "\
    file://sw-description-full \
    file://check-bootloader-version.lua \
"

S = "${UNPACKDIR}"

# This image depends on the actual rootfs image and u-boot
IMAGE_DEPENDS = "brutzelboy virtual/bootloader"

# Specify which images to include in the SWU file
SWUPDATE_IMAGES = "brutzelboy idbloader.img u-boot.itb"

# Specify the filesystem type for rootfs
SWUPDATE_IMAGES_FSTYPES[brutzelboy] = ".rootfs.ext4"

# Get bootloader version from U-Boot recipe
BOOTLOADER_VERSION ??= "2025.01"

# Copy sw-description-full as sw-description for the build
do_unpack[postfuncs] += "copy_sw_description_full"

python copy_sw_description_full() {
    import shutil
    workdir = d.getVar('UNPACKDIR')
    src = os.path.join(workdir, 'sw-description-full')
    dst = os.path.join(workdir, 'sw-description')
    if os.path.exists(src):
        shutil.copyfile(src, dst)
}
