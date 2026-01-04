#!/bin/false

test_steam_controller_udev_rules_deployed() {
    expect "Steam Controller udev rules to be in the rootfs"

    for img in $DEPLOY_DIR/images/$MACHINE/*.rootfs*.ext4 $DEPLOY_DIR/images/$MACHINE/*.ext4; do
        [ -e "$img" ] || continue

        mountdir=$(mount_rootfs_image "$img") || { log_error "$img: failed to mount"; fail; }

        if [ ! -e "$mountdir/lib/udev/rules.d/70-steam-controller.rules" ]; then
            umount_rootfs_image "$mountdir"
            log_error "$img: 70-steam-controller.rules"
            fail
        fi

        umount_rootfs_image "$mountdir"
        found=1
    done
    pass
}
