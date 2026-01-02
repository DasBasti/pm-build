#!/bin/false

# Helper to mount an ext4 rootfs image read-only and return the mount point
# Usage:
#   mountdir=$(mount_rootfs_image "${IMAGE}") || return 1
#   ... use files under ${mountdir} ...
#   umount_rootfs_image "${mountdir}"

mount_rootfs_image() {
    local image="$1"

    if [ -z "$image" ]; then
        log_error "mount_rootfs_image: no image specified"
        return 1
    fi

    if [ ! -f "$image" ]; then
        log_error "mount_rootfs_image: image not found: $image"
        return 1
    fi

    local mdir
    mdir=$(mktemp -d /tmp/rootfs-mount-XXXXXX) || return 1

    # Mount read-only using loop device. Requires sudo privileges for mount.
    if ! sudo mount -o loop,ro "$image" "$mdir"; then
        rmdir "$mdir" 2>/dev/null || true
        log_error "mount_rootfs_image: failed to mount $image"
        return 1
    fi

    echo "$mdir"
}

umount_rootfs_image() {
    local mdir="$1"
    if [ -z "$mdir" ]; then
        log_error "umount_rootfs_image: no mount point specified"
        return 1
    fi

    if mountpoint -q "$mdir"; then
        sudo umount "$mdir" || { log_error "umount_rootfs_image: failed to unmount $mdir"; return 1; }
    fi
    rmdir "$mdir" 2>/dev/null || true
}
