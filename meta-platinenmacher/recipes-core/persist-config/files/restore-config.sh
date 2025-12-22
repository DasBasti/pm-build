#!/bin/bash
# Restore persistent configuration from /home/.system-config/
# Run at early boot before network services start

set -e

PERSIST_DIR="/home/.system-config"
MARKER_FILE="/var/lib/persist-config-initialized"

# Wait for /home to be mounted (max 30 seconds)
for i in {1..30}; do
    if mountpoint -q /home; then
        break
    fi
    sleep 1
done

if [ ! -d "$PERSIST_DIR" ]; then
    echo "No persistent configuration found at $PERSIST_DIR"
    exit 0
fi

echo "Restoring system configuration from $PERSIST_DIR"

# Configuration items to restore
declare -A RESTORE_PATHS=(
    ["ssh_host_keys"]="/etc/ssh/"
    ["hostname"]="/etc/"
    ["machine-id"]="/etc/"
    ["wpa_supplicant"]="/etc/wpa_supplicant/"
    ["connman"]="/var/lib/"
    ["swupdate"]="/etc/swupdate/"
)

# Restore each configuration item
for name in "${!RESTORE_PATHS[@]}"; do
    source_dir="$PERSIST_DIR/$name"
    target_base="${RESTORE_PATHS[$name]}"

    if [ ! -d "$source_dir" ]; then
        echo "Skipping $name: no persistent data found"
        continue
    fi

    # Ensure target directory exists
    mkdir -p "$target_base"

    # Restore files
    echo "Restoring: $name"
    if [ "$name" == "connman" ]; then
        # For connman, restore entire directory structure
        rsync -a "$source_dir/" "$target_base/connman/"
    else
        # For others, restore files
        cp -a "$source_dir"/* "$target_base/" 2>/dev/null || true
    fi
done

# Fix permissions for SSH keys
if [ -d "$PERSIST_DIR/ssh_host_keys" ]; then
    chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null || true
    chmod 644 /etc/ssh/ssh_host_*_key.pub 2>/dev/null || true
fi

echo "Configuration restore complete"
