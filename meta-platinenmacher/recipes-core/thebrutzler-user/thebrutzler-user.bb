SUMMARY = "Create thebrutzler user"
DESCRIPTION = "Creates the thebrutzler user with passwordless sudo access"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://thebrutzler-sudoers"

S = "${UNPACKDIR}"

inherit useradd

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "-u 1000 -d /home/thebrutzler -s /bin/bash -g users -G sudo,wheel,audio,video -P '' thebrutzler"

# Ensure sudo is installed before this package
RDEPENDS:${PN} = "sudo-lib"

do_install() {
    # Don't install the sudoers file here - do it in postinst to avoid directory conflict
    # Just stage it for postinst use
    install -d ${D}${datadir}/thebrutzler-user
    install -m 0440 ${S}/thebrutzler-sudoers ${D}${datadir}/thebrutzler-user/thebrutzler-sudoers
}

pkg_postinst_ontarget:${PN}() {
    # Install sudoers file after sudo-lib is already installed
    if [ -d /etc/sudoers.d ]; then
        cp ${datadir}/thebrutzler-user/thebrutzler-sudoers /etc/sudoers.d/thebrutzler
        chmod 0440 /etc/sudoers.d/thebrutzler
    fi

    # Create home directory if it doesn't exist
    if [ ! -d /home/thebrutzler ]; then
        mkdir -p /home/thebrutzler/.ssh
        chmod 700 /home/thebrutzler/.ssh
        chown -R thebrutzler:users /home/thebrutzler
    fi
}

# Package the staging file
FILES:${PN} = "${datadir}/thebrutzler-user/thebrutzler-sudoers"
