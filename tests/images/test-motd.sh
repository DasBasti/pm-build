#!/bin/false

# Use mount helper to inspect ext4 rootfs images
source "$SCRIPT_DIR/.framework/mount_image.sh"


test_motd_exists_in_rootfs() {
    expect "rootfs images to contain /etc/motd with welcome message"

    found=0

    # Look for rootfs ext4 images (wildcard to cover naming variants)
    for img in $DEPLOY_DIR/images/$MACHINE/*.rootfs*.ext4 $DEPLOY_DIR/images/$MACHINE/*.ext4; do
        [ -e "$img" ] || continue

        mountdir=$(mount_rootfs_image "$img") || { log_error "$img: failed to mount"; fail; }

        if [ ! -e "$mountdir/etc/motd" ]; then
            umount_rootfs_image "$mountdir"
            log_error "$img: missing /etc/motd"
            fail
        fi

        if ! grep -q "Welcome to Platinenmacher Linux" "$mountdir/etc/motd"; then
            log_error "$img: motd does not contain welcome text - content follows:"
            sed -n '1,120p' "$mountdir/etc/motd" | sed 's/^/    /'
            umount_rootfs_image "$mountdir"
            fail
        fi

        umount_rootfs_image "$mountdir"
        found=1
    done

    [ $found -eq 1 ] || { log_error "No rootfs images checked"; fail; }

    pass
}
