#!/bin/false


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

    sudo umount "${tmpmnt}" || true
    rm -rf "${tmpmnt}"

    pass
}
