#!/bin/bash
# Set bootloader version in U-Boot environment if not already set
# This script is optional - if U-Boot env tools aren't configured, it's not a failure

BOOTLOADER_VERSION_FILE="/etc/bootloader-version"
CURRENT_VERSION=""

# Check if fw_env.config exists
if [ ! -f /etc/fw_env.config ]; then
    echo "Info: /etc/fw_env.config not found, skipping U-Boot env update"
    exit 0
fi

# Try to read current version from U-Boot env
if command -v fw_printenv >/dev/null 2>&1; then
    CURRENT_VERSION=$(fw_printenv -n bootloader_version 2>/dev/null || echo "")
else
    echo "Info: fw_printenv not available, skipping U-Boot env update"
    exit 0
fi

# If not set or different from file, update it
if [ -f "$BOOTLOADER_VERSION_FILE" ]; then
    FILE_VERSION=$(cat "$BOOTLOADER_VERSION_FILE")

    if [ "$CURRENT_VERSION" != "$FILE_VERSION" ]; then
        echo "Updating bootloader version in U-Boot env: $FILE_VERSION"
        if command -v fw_setenv >/dev/null 2>&1; then
            fw_setenv bootloader_version "$FILE_VERSION" || {
                echo "Warning: fw_setenv failed, U-Boot env may not be writable"
                exit 0
            }
        else
            echo "Info: fw_setenv not available"
        fi
    fi
fi

exit 0
