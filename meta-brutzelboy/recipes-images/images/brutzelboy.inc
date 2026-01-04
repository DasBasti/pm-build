inherit core-image

# Keep original rootfs size but partition will be image size + 1GB
IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = " ${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

PV = "2026.01.4"

IMAGE_INSTALL:append = " \
    resize-userdata \
    parted \
    e2fsprogs-resize2fs \
    persist-config \
    openssh \
    usb-automount \
    sudo \
    wayland \
    weston \
    weston-init \
    xdg-user-dirs \
    xcursor-themes \
    plymouth \
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
    swupdate-key \
    libubootenv-bin \
    swupdate-hw-compatibility \
    swupdate-config \
"

# Brutzelboy stuff
IMAGE_INSTALL:append = " \
    scummvm \
    libgl-mesa \
    libegl-mesa \
    libgbm \
    mesa-megadriver \
    steam-controller-udev \
"

IMAGE_FEATURES:append = " \
    splash \
"

# Generate ext4 image for swupdate packages
IMAGE_FSTYPES += "ext4 wic.zip"

# Use custom WKS file for A/B partitioning
WKS_FILE = "platinenmacher-ab.wks"


# SWUpdate artifacts configuration for /etc/sw-versions
# Maps artifact names to their deploy paths
SWUPDATE_ARTIFACTS = "idbloader.img u-boot.itb"

# Create /etc/sw-versions with artifact names and SHA256 hashes
# Note: The rootfs uses the distro version since we cannot include the hash
# of the ext4 image inside the image itself
generate_sw_versions() {
    SW_VERSIONS_FILE="${IMAGE_ROOTFS}${sysconfdir}/sw-versions"
    rm -f ${SW_VERSIONS_FILE}

    # Add rootfs entry using distro version
    echo "${PN} ${PV}" >> ${SW_VERSIONS_FILE}

    # Add bootloader artifacts
    for artifact in ${SWUPDATE_ARTIFACTS}; do
        artifact_path="${DEPLOY_DIR_IMAGE}/${artifact}"
        if [ -f "${artifact_path}" ]; then
            hash=$(sha256sum "${artifact_path}" | awk '{print $1}')
            echo "${artifact} ${hash}" >> ${SW_VERSIONS_FILE}
        else
            bbwarn "SWUpdate artifact not found: ${artifact_path}"
        fi
    done
}

ROOTFS_POSTPROCESS_COMMAND += "generate_sw_versions;"
do_rootfs[depends] += "virtual/bootloader:do_deploy"
