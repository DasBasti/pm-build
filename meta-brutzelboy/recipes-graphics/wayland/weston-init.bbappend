# Use thebrutzler user instead of default weston user
WESTON_USER = "thebrutzler"
WESTON_USER_HOME = "/home/thebrutzler"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://override.conf \
    file://weston.ini \
    file://weston-autologin \
    file://thebrutzler-sudoers \
"

# Additional source files for thebrutzler user setup
# Ensure BitBake searches this layer's files directory for file:// URIs
FILESEXTRAPATHS := "${THISDIR}/files:${FILESEXTRAPATHS}"

# Ensure sudo is installed for passwordless sudo access
RDEPENDS:${PN} += "sudo"

# Create thebrutzler user with all necessary groups
USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "-d ${WESTON_USER_HOME} -s /bin/bash -G sudo,wheel,audio,video,input,render,wayland ${WESTON_USER}"

# Package additional files (we generate them in do_install to avoid SRC_URI file lookups)
FILES:${PN} += "\
    ${datadir}/${PN}/thebrutzler-sudoers \
    ${sysconfdir}/pam.d/weston-autologin \
    ${systemd_unitdir}/system/weston.service.d/override.conf \
    ${sysconfdir}/xdg/weston.ini \
"

RDEPENDS:${PN} += "libpam-runtime"

do_install:append() {
    # Stage generated sudoers file for postinst
    install -d ${D}${datadir}/${PN}
    install -m 0440 ${UNPACKDIR}/thebrutzler-sudoers ${D}${datadir}/${PN}/

    # Install PAM file so systemd can create user session on service start
    install -d ${D}${sysconfdir}/pam.d
    install -m 0644 ${UNPACKDIR}/weston-autologin ${D}${sysconfdir}/pam.d/weston-autologin

    # Install systemd drop-in override for using tty1 and taking control of getty
    install -d ${D}${systemd_unitdir}/system/weston.service.d
    install -m 0644 ${UNPACKDIR}/override.conf ${D}${systemd_unitdir}/system/weston.service.d/override.conf

    # Install a system weston.ini to ensure a cursor theme is set
    install -d ${D}${sysconfdir}/xdg
    install -m 0644 ${UNPACKDIR}/weston.ini ${D}${sysconfdir}/xdg/weston.ini
}

pkg_postinst_ontarget:${PN}() {
    # Install sudoers file
    if [ -d /etc/sudoers.d ]; then
        cp ${datadir}/${PN}/thebrutzler-sudoers /etc/sudoers.d/thebrutzler
        chmod 0440 /etc/sudoers.d/thebrutzler
    fi
}
