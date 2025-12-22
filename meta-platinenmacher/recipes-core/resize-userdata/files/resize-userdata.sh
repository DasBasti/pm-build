#!/bin/bash
# Resize userdata partition to use remaining disk space

set -e

MARKER_FILE="/var/lib/resize-userdata-done"

# Exit if already resized
if [ -f "$MARKER_FILE" ]; then
    echo "User data partition already resized"
    exit 0
fi

# Find the userdata partition by label (more reliable than mount point)
# Wait up to 10 seconds for the partition label to appear
USERDATA_PART="/dev/disk/by-partlabel/userdata"
for i in $(seq 1 10); do
    if [ -e "$USERDATA_PART" ]; then
        break
    fi
    echo "Waiting for userdata partition label to appear... ($i/10)"
    sleep 1
done

if [ ! -e "$USERDATA_PART" ]; then
    echo "ERROR: Could not find userdata partition by label after 10 seconds"
    # Try to find it by GPT partition name directly
    USERDATA_PART=$(blkid -t PARTLABEL=userdata -o device | head -n1)
    if [ -z "$USERDATA_PART" ]; then
        echo "ERROR: Could not find userdata partition by any method"
        exit 1
    fi
    echo "Found userdata partition using blkid: $USERDATA_PART"
else
    # Resolve symlink to actual device
    USERDATA_PART=$(readlink -f "$USERDATA_PART")
    echo "Found userdata partition: $USERDATA_PART"
fi

# Extract device and partition number
# Handle both /dev/sdX3 and /dev/mmcblk0p3 formats
if [[ "$USERDATA_PART" =~ ^/dev/mmcblk[0-9]+ ]]; then
    # MMC/SD card format: /dev/mmcblk0p11
    DEVICE=$(echo "$USERDATA_PART" | sed 's/p[0-9]\+$//')
    PARTNUM=$(echo "$USERDATA_PART" | sed 's/.*p\([0-9]\+\)$/\1/')
elif [[ "$USERDATA_PART" =~ ^/dev/[a-z]+[0-9]+$ ]]; then
    # Standard disk format: /dev/sda3
    DEVICE=$(echo "$USERDATA_PART" | sed 's/[0-9]\+$//')
    PARTNUM=$(echo "$USERDATA_PART" | sed 's/.*[^0-9]\([0-9]\+\)$/\1/')
else
    echo "ERROR: Unable to parse device and partition number from $USERDATA_PART"
    exit 1
fi

echo "Device: $DEVICE"
echo "Partition number: $PARTNUM"
echo "Resizing partition $PARTNUM on $DEVICE..."

# Fix GPT backup header if needed (move to end of disk)
sgdisk --move-second-header "$DEVICE" 2>/dev/null || true

# Resize partition using parted (answer yes to prompts)
echo "Yes" | parted -s "$DEVICE" ---pretend-input-tty resizepart "$PARTNUM" 100% 2>&1 || {
    echo "Warning: parted returned non-zero, but this might be expected"
}

# Wait a moment for kernel to update partition table
sleep 2

# Resize filesystem
resize2fs "$USERDATA_PART"

# Create marker file
mkdir -p /var/lib
touch "$MARKER_FILE"

echo "User data partition successfully resized to $(df -h /home | tail -1 | awk '{print $2}')"
