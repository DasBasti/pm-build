#!/bin/bash
# Persist system configuration to /home/.system-config/
# Run periodically or on shutdown to save current state

set -e

PERSIST_DIR="/home/.system-config"
MARKER_FILE="/var/lib/persist-config-initialized"

# Configuration items to persist
declare -A PERSIST_PATHS=(
    ["ssh_host_keys"]="/etc/ssh/ssh_host_*_key*"
    ["hostname"]="/etc/hostname"
    ["machine-id"]="/etc/machine-id"
    ["wpa_supplicant"]="/etc/wpa_supplicant/wpa_supplicant-*.conf"
    ["connman"]="/var/lib/connman"
    ["swupdate"]="/etc/swupdate/swupdate.cfg"
)

# Ensure persist directory exists
mkdir -p "$PERSIST_DIR"

echo "Persisting system configuration to $PERSIST_DIR"

# Save each configuration item
for name in "${!PERSIST_PATHS[@]}"; do
    pattern="${PERSIST_PATHS[$name]}"
    target_dir="$PERSIST_DIR/$name"

    # Create target directory
    mkdir -p "$target_dir"

    # Handle directory vs file pattern
    if [ -d "$pattern" ]; then
        # Directory - sync contents
        echo "Persisting directory: $pattern"
        rsync -a --delete "$pattern/" "$target_dir/"
    else
        # File pattern - copy matching files
        for file in $pattern; do
            if [ -e "$file" ]; then
                echo "Persisting: $file"
                cp -a "$file" "$target_dir/"
            fi
        done
    fi
done

# Mark as initialized
touch "$MARKER_FILE"

echo "Configuration persistence complete"
