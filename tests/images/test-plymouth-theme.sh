#!/bin/false


test_plymouth_theme_installed() {
    expect "that the plymouth theme files are installed in the rootfs tar"

        # Look for rootfs ext4 images (wildcard to cover naming variants)
    found=0

    for img in $DEPLOY_DIR/images/$MACHINE/*.rootfs*.ext4 $DEPLOY_DIR/images/$MACHINE/*.ext4; do
        [ -e "$img" ] || continue

        mountdir=$(mount_rootfs_image "$img") || { log_error "$img: failed to mount"; fail; }

        if [ ! -e "$mountdir/usr/share/plymouth/themes/platinenmacher/platinenmacher.plymouth" ]; then
            umount_rootfs_image "$mountdir"
            log_error "$img: missing platinenmacher.plymouth"
            fail
        fi

        if [ ! -e "$mountdir/usr/share/plymouth/themes/platinenmacher/splash.png" ]; then
            umount_rootfs_image "$mountdir"
            log_error "$img: missing splash.png"
            fail
        fi

        if [ ! -e "$mountdir/etc/plymouth/plymouthd.conf" ]; then
            umount_rootfs_image "$mountdir"
            log_error "$img: missing /etc/plymouth/plymouthd.conf"
            fail
        fi

        if ! grep -q "^Theme=platinenmacher" "$mountdir/etc/plymouth/plymouthd.conf"; then
            umount_rootfs_image "$mountdir"
            log_error "$img: plymouthd.conf does not contain Theme=platinenmacher"
            fail
        fi

        umount_rootfs_image "$mountdir"
        found=1
    done

    [ $found -eq 1 ] || { log_error "No rootfs images checked"; fail; }

    pass
}
