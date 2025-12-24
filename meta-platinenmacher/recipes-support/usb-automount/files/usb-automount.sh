#!/bin/bash
# USB Automount Helper Script
# Mounts USB storage devices to /media/<label or uuid>

set -e

DEVICE="/dev/$1"
MOUNT_BASE="/media"

# Ensure mount base exists
mkdir -p "$MOUNT_BASE"

# Get filesystem type
FSTYPE=$(blkid -o value -s TYPE "$DEVICE" || echo "auto")

# Get filesystem label or UUID for mount point name
LABEL=$(blkid -o value -s LABEL "$DEVICE" 2>/dev/null || echo "")
UUID=$(blkid -o value -s UUID "$DEVICE" 2>/dev/null || echo "")

if [ -n "$LABEL" ]; then
    # Use label if available (sanitize for filesystem safety)
    MOUNT_POINT="$MOUNT_BASE/$(echo "$LABEL" | tr -cs '[:alnum:]_-' '_')"
else
    # Use UUID as fallback
    MOUNT_POINT="$MOUNT_BASE/${UUID:-usb}"
fi

# Create mount point
mkdir -p "$MOUNT_POINT"

# Mount with appropriate options based on filesystem
case "$FSTYPE" in
    vfat|ntfs|exfat)
        # Windows filesystems - mount with user permissions
        mount -t "$FSTYPE" -o rw,noatime,uid=1000,gid=100,dmask=000,fmask=111 "$DEVICE" "$MOUNT_POINT"
        ;;
    ext[234]|xfs|btrfs)
        # Linux filesystems
        mount -t "$FSTYPE" -o rw,noatime "$DEVICE" "$MOUNT_POINT"
        ;;
    *)
        # Auto-detect
        mount -o rw,noatime "$DEVICE" "$MOUNT_POINT"
        ;;
esac

echo "Mounted $DEVICE at $MOUNT_POINT"
logger -t usb-automount "Mounted $DEVICE ($FSTYPE) at $MOUNT_POINT"
