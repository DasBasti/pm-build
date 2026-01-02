#!/bin/false


test_scummvm_service_installed() {
    expect "that scummvm systemd service is installed in the image"

    rootfs=$(find $DEPLOY_DIR/images/$MACHINE/ -type f -name "*rootfs*.ext4" | head -n1)
    [ -n "${rootfs}" ] || { log_error "No rootfs.ext4 artifact found"; fail; }

    tmpmnt=$(mktemp -d)
    if ! sudo mount -o loop "${rootfs}" "${tmpmnt}"; then
        log_error "Failed to mount rootfs ${rootfs}"
        rm -rf "${tmpmnt}"
        fail
    fi

    if [ ! -f "${tmpmnt}/etc/systemd/system/scummvm-autostart.service" ]; then
        log_error "scummvm systemd service missing in rootfs"
        sudo umount "${tmpmnt}" || true
        rm -rf "${tmpmnt}"
        fail
    fi

    if [ ! -L "${tmpmnt}/etc/systemd/system/graphical.target.wants/scummvm-autostart.service" ]; then
        log_error "scummvm service not enabled (no symlink in graphical.target.wants)"
        sudo umount "${tmpmnt}" || true
        rm -rf "${tmpmnt}"
        fail
    fi

    sudo umount "${tmpmnt}" || true
    rm -rf "${tmpmnt}"

    pass
}
