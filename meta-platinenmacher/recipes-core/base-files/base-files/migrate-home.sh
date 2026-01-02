#!/bin/bash
# Migrate rootfs /home contents to userdata partition
# Runs before home.mount to move any files from the rootfs to userdata

set -e

USERDATA_DEV="/dev/disk/by-partlabel/userdata"
TEMP_MOUNT="/mnt/userdata-temp"

# Check if rootfs /home has any content (excluding lost+found)
has_content=false
for item in /home/*; do
    if [ -e "$item" ] && [ "$(basename "$item")" != "lost+found" ]; then
        has_content=true
        break
    fi
done

if [ "$has_content" = false ]; then
    echo "No content in rootfs /home to migrate"
    exit 0
fi

echo "Found content in rootfs /home, migrating to userdata partition..."

# Wait for userdata partition to be available
for i in $(seq 1 10); do
    if [ -e "$USERDATA_DEV" ]; then
        break
    fi
    echo "Waiting for userdata partition... ($i/10)"
    sleep 1
done

if [ ! -e "$USERDATA_DEV" ]; then
    echo "ERROR: userdata partition not found"
    exit 1
fi

# Temporarily mount userdata
mkdir -p "$TEMP_MOUNT"
mount -t ext4 "$USERDATA_DEV" "$TEMP_MOUNT"

# Move all contents from rootfs /home to userdata
for item in /home/*; do
    if [ -e "$item" ] && [ "$(basename "$item")" != "lost+found" ]; then
        name=$(basename "$item")
        if [ ! -e "$TEMP_MOUNT/$name" ]; then
            echo "  Moving $name..."
            mv "$item" "$TEMP_MOUNT/"
        else
            echo "  Merging $name (already exists on userdata)..."
            cp -a "$item"/* "$TEMP_MOUNT/$name"/ 2>/dev/null || true
            cp -a "$item"/.[!.]* "$TEMP_MOUNT/$name"/ 2>/dev/null || true
            rm -rf "$item"
        fi
    fi
done

# Cleanup
umount "$TEMP_MOUNT"
rmdir "$TEMP_MOUNT"

echo "Home migration complete"
