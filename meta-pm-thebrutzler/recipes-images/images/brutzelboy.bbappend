# Use custom WKS file for A/B partitioning
WKS_FILE = "platinenmacher-ab.wks"

# Ensure IMAGE_BOOT_FILES contains the files we want to place into the
# boot partition. This lets the WIC bootimg_partition plugin copy FITs (and
# kernel/dtb if needed) into the boot partition during WIC creation.
# Use ${@...} to force evaluation of DTB_FILES in this context so WIC gets
# concrete filenames instead of the literal token.
IMAGE_BOOT_FILES:append = " fitImageA "

do_rename_fitImage() {
    if [ -f ${DEPLOY_DIR_IMAGE}/fitImage ]; then
        mv ${DEPLOY_DIR_IMAGE}/fitImage ${DEPLOY_DIR_IMAGE}/fitImageA
    else
        ls ${DEPLOY_DIR_IMAGE}
        bberr "No fitImage found"
    fi
}
addtask do_rename_fitImage before do_image_wic after do_image

# Remove any kernel, dtb or extlinux files from the rootfs so the boot
# partition contains the authoritative boot artifacts (extlinux + FITs).
# This avoids duplicate/non-A/B extlinux files being picked up from
# rootfs/boot and ensures SWUpdate updates the boot device correctly.
cleanup_rootfs_boot() {
    bbnote "Cleaning /boot from rootfs to ensure boot partition holds boot files"
    if [ -d "${IMAGE_ROOTFS}/boot" ]; then
        rm -rf ${IMAGE_ROOTFS}/boot/* || true
    fi
}

ROOTFS_POSTPROCESS_COMMAND += "cleanup_rootfs_boot; "
