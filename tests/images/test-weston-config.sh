#!/bin/false


test_weston_ini_in_rootfs() {
    expect "that /etc/xdg/weston.ini exists and sets a cursor theme"

    rootfs=$(find $DEPLOY_DIR/images/$MACHINE/ -type f -name "*rootfs*.ext4" | head -n1)
    [ -n "${rootfs}" ] || { log_error "No rootfs.ext4 artifact found"; fail; }

    tmpmnt=$(mktemp -d)
    if ! sudo mount -o loop "${rootfs}" "${tmpmnt}"; then
        log_error "Failed to mount rootfs ${rootfs}"
        rm -rf "${tmpmnt}"
        fail
    fi

    if [ ! -f "${tmpmnt}/etc/xdg/weston.ini" ]; then
        log_error "/etc/xdg/weston.ini missing in rootfs"
        sudo umount "${tmpmnt}" || true
        rm -rf "${tmpmnt}"
        fail
    fi

    grep -q "cursor-theme" "${tmpmnt}/etc/xdg/weston.ini" || { log_error "cursor-theme not set in weston.ini"; sudo umount "${tmpmnt}" || true; rm -rf "${tmpmnt}"; fail; }

    sudo umount "${tmpmnt}" || true
    rm -rf "${tmpmnt}"

    pass
}
