#!/bin/false

test_steam_controller_udev_rules_deployed() {
    expect "Steam Controller udev rules to be in the rootfs"

    # Find the rootfs tarball
    rootfs_tar=$(find $DEPLOY_DIR/images/$MACHINE/ -type l -name "*.rootfs.tar" | head -1)
    [ -z "$rootfs_tar" ] && { log_error "No rootfs tarball found"; fail; }

    # Check if the udev rules file exists in the tarball
    tar -tf "$rootfs_tar" | grep -q "lib/udev/rules.d/70-steam-controller.rules" || {
        log_error "70-steam-controller.rules not found in rootfs"
        fail
    }

    pass
}
