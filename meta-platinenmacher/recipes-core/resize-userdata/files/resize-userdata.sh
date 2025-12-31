#!/bin/bash
# Resize userdata partition to use remaining disk space
# This script auto-detects if resize is needed by checking for unallocated space

set -e

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
if [[ "$USERDATA_PART" =~ ^/dev/mmcblk0p[0-9]+ ]]; then
    DEVICE=$(echo "$USERDATA_PART" | sed 's/p[0-9]\+$//')
    PARTNUM=$(echo "$USERDATA_PART" | sed 's/.*p\([0-9]\+\)$/\1/')
else
    echo "ERROR: Unable to parse device and partition number from $USERDATA_PART"
    exit 1
fi

echo "Device: $DEVICE"
echo "Partition number: $PARTNUM"

# Fix GPT backup header if needed (move to end of disk)
sgdisk --move-second-header "$DEVICE" 2>/dev/null || true

# Get current partition end and disk size in sectors
PART_END=$(partx -g -o END -n "$PARTNUM" "$DEVICE" | tr -d ' ')
DISK_SECTORS=$(blockdev --getsz "$DEVICE")
# Leave 34 sectors for GPT backup header
MAX_END=$((DISK_SECTORS - 34))

echo "Partition end: $PART_END sectors"
echo "Disk usable end: $MAX_END sectors"

# Check if there's significant space to gain (at least 1MB = 2048 sectors)
SPACE_AVAILABLE=$((MAX_END - PART_END))
if [ "$SPACE_AVAILABLE" -lt 2048 ]; then
    echo "Partition already uses available space (only $SPACE_AVAILABLE sectors free). Nothing to do."
    exit 0
fi

echo "Found $((SPACE_AVAILABLE / 2048)) MB of unallocated space. Resizing partition..."

# Resize partition using parted
echo "Yes" | parted -s "$DEVICE" ---pretend-input-tty resizepart "$PARTNUM" 100% 2>&1 || {
    echo "Warning: parted returned non-zero, but this might be expected"
}

# Wait a moment for kernel to update partition table
sleep 2

# Resize filesystem
resize2fs "$USERDATA_PART"

echo "User data partition successfully resized to $(df -h /home | tail -1 | awk '{print $2}')"
