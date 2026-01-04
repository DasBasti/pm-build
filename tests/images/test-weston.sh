#!/bin/false


test_weston_ini_in_rootfs() {
    local ini_path="/etc/xdg/weston/weston.ini"
    expect "that ${ini_path} exists and sets a cursor theme"

    rootfs=$(find $DEPLOY_DIR/images/$MACHINE/ -type f -name "*rootfs*.ext4" | head -n1)
    [ -n "${rootfs}" ] || { log_error "No rootfs.ext4 artifact found"; fail; }

    tmpmnt=$(mktemp -d)
    if ! sudo mount -o loop "${rootfs}" "${tmpmnt}"; then
        log_error "Failed to mount rootfs ${rootfs}"
        rm -rf "${tmpmnt}"
        fail
    fi

    if [ ! -f "${tmpmnt}${ini_path}" ]; then
        log_error "${ini_path} missing in rootfs"
        sudo umount "${tmpmnt}" || true
        rm -rf "${tmpmnt}"
        fail
    fi

    grep -q "cursor-theme" "${tmpmnt}${ini_path}" || { log_error "cursor-theme not set in weston.ini"; sudo umount "${tmpmnt}" || true; rm -rf "${tmpmnt}"; fail; }

    sudo umount "${tmpmnt}" || true
    rm -rf "${tmpmnt}"

    pass
}

test_cursor_theme_installed() {
    expect "that a cursor theme is installed in the image"

    # Find the built rootfs ext4 image
    rootfs=$(find $DEPLOY_DIR/images/$MACHINE/ -type f -name "*rootfs*.ext4" | head -n1)
    [ -n "${rootfs}" ] || { log_error "No rootfs.ext4 artifact found"; fail; }

    # Mount it temporarily and look for cursor directories
    tmpmnt=$(mktemp -d)
    if ! sudo mount -o loop "${rootfs}" "${tmpmnt}"; then
        log_error "Failed to mount rootfs ${rootfs}"
        rm -rf "${tmpmnt}"
        fail
    fi

    matches=$(find "${tmpmnt}"/usr/share -type d -path "*/icons/*/cursors" 2>/dev/null)
    if [ -z "${matches}" ]; then
        log_error "No cursor theme directories found inside mounted rootfs"
        sudo umount "${tmpmnt}" || true
        rm -rf "${tmpmnt}"
        fail
    fi

    # Best-effort cleanup: prefer regular unmount, fall back to lazy unmount and detach loop device
    if mountpoint -q "${tmpmnt}" ; then
        sudo umount "${tmpmnt}" || sudo umount -l "${tmpmnt}" || true
    fi
    # Detach loop device if one was associated with the file
    loopdev=$(losetup -j "${rootfs}" 2>/dev/null | cut -d: -f1)
    [ -n "${loopdev}" ] && sudo losetup -d "${loopdev}" || true
    rm -rf "${tmpmnt}"

    pass
}
