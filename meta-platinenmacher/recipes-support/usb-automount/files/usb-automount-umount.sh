#!/bin/bash
# USB Automount Cleanup Script
# Unmounts and removes mount point when USB device is removed

set -e

DEVICE="/dev/$1"
MOUNT_BASE="/media"

# Find the mount point for this device
MOUNT_POINT=$(grep "^$DEVICE " /proc/mounts | awk '{print $2}' | head -n1)

if [ -z "$MOUNT_POINT" ]; then
    echo "Device $DEVICE not mounted"
    exit 0
fi

# Unmount
umount "$MOUNT_POINT"
echo "Unmounted $DEVICE from $MOUNT_POINT"
logger -t usb-automount "Unmounted $DEVICE from $MOUNT_POINT"

# Remove mount point if it's under our control and empty
if [[ "$MOUNT_POINT" == "$MOUNT_BASE/"* ]] && [ -d "$MOUNT_POINT" ]; then
    rmdir "$MOUNT_POINT" 2>/dev/null || true
fi
