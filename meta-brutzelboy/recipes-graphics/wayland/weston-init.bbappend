# Use thebrutzler user instead of default weston user
WESTON_USER = "thebrutzler"
WESTON_USER_HOME = "/home/thebrutzler"

# Additional source files for thebrutzler user setup
FILESEXTRAPATHS:prepend := "${THISDIR}/weston-init:"

SRC_URI += "\
    file://thebrutzler-sudoers \
"

# Ensure sudo is installed for passwordless sudo access
RDEPENDS:${PN} += "sudo"

# Create thebrutzler user with all necessary groups
USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "-d ${WESTON_USER_HOME} -s /bin/bash -G sudo,wheel,audio,video,input,render,wayland ${WESTON_USER}"

# Package additional files
FILES:${PN} += "\
    ${datadir}/${PN}/thebrutzler-sudoers \
"

do_install:append() {
    # Stage sudoers file for postinst
    install -d ${D}${datadir}/${PN}
    install -m 0440 ${UNPACKDIR}/thebrutzler-sudoers ${D}${datadir}/${PN}/thebrutzler-sudoers
}

pkg_postinst_ontarget:${PN}() {
    # Install sudoers file
    if [ -d /etc/sudoers.d ]; then
        cp ${datadir}/${PN}/thebrutzler-sudoers /etc/sudoers.d/thebrutzler
        chmod 0440 /etc/sudoers.d/thebrutzler
    fi
}
