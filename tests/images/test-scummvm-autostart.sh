#!/bin/false


test_scummvm_autostart_installed() {
    expect "that scummvm autostart desktop file is installed in the image"

    rootfs=$(find $DEPLOY_DIR/images/$MACHINE/ -type f -name "*rootfs*.ext4" | head -n1)
    [ -n "${rootfs}" ] || { log_error "No rootfs.ext4 artifact found"; fail; }

    tmpmnt=$(mktemp -d)
    if ! sudo mount -o loop "${rootfs}" "${tmpmnt}"; then
        log_error "Failed to mount rootfs ${rootfs}"
        rm -rf "${tmpmnt}"
        fail
    fi

    if [ ! -f "${tmpmnt}/etc/xdg/autostart/scummvm.desktop" ]; then
        log_error "scummvm autostart desktop missing in rootfs"
        sudo umount "${tmpmnt}" || true
        rm -rf "${tmpmnt}"
        fail
    fi

    sudo umount "${tmpmnt}" || true
    rm -rf "${tmpmnt}"

    pass
}
