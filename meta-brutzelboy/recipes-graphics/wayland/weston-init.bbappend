# Use thebrutzler user instead of default weston user
WESTON_USER = "thebrutzler"
WESTON_USER_HOME = "/home/thebrutzler"

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
    cat > ${D}${datadir}/${PN}/thebrutzler-sudoers << 'EOF'
# Allow thebrutzler user to run commands without password
thebrutzler ALL=(ALL) NOPASSWD: ALL
EOF
    chmod 0440 ${D}${datadir}/${PN}/thebrutzler-sudoers

    # Install PAM file so systemd can create user session on service start
    install -d ${D}${sysconfdir}/pam.d
    cat > ${D}${sysconfdir}/pam.d/weston-autologin << 'EOF'
# PAM configuration for Weston auto-login
# Ensures systemd-logind creates a user runtime dir and session

auth     required pam_unix.so
account  required pam_unix.so
session  required pam_env.so
session  required pam_unix.so
# Create a systemd user session for Weston so XDG_RUNTIME_DIR is available
session  optional pam_systemd.so type=wayland class=user desktop=weston
# Ensure loginuid is set
session  optional pam_loginuid.so
EOF
    chmod 0644 ${D}${sysconfdir}/pam.d/weston-autologin

    # Install systemd drop-in override for using tty1 and taking control of getty
    install -d ${D}${systemd_unitdir}/system/weston.service.d
    cat > ${D}${systemd_unitdir}/system/weston.service.d/override.conf << 'EOF'
[Unit]
Conflicts=getty@tty1.service
Before=getty@tty1.service

[Service]
# Use tty1 for the Weston session
TTYPath=/dev/tty1
UtmpIdentifier=tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
EOF
    chmod 0644 ${D}${systemd_unitdir}/system/weston.service.d/override.conf

    # Install a system weston.ini to ensure a cursor theme is set
    install -d ${D}${sysconfdir}/xdg
    cat > ${D}${sysconfdir}/xdg/weston.ini << 'EOF'
[core]
# Use an installed theme to ensure the pointer is visible
cursor-theme=whiteglass
cursor-size=32
EOF
    chmod 0644 ${D}${sysconfdir}/xdg/weston.ini
}

pkg_postinst_ontarget:${PN}() {
    # Install sudoers file
    if [ -d /etc/sudoers.d ]; then
        cp ${datadir}/${PN}/thebrutzler-sudoers /etc/sudoers.d/thebrutzler
        chmod 0440 /etc/sudoers.d/thebrutzler
    fi
}
