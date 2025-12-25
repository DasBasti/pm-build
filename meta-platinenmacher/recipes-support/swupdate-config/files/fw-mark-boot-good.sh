#!/bin/sh
set -e

# Exit if fw_printenv is not available
if ! command -v fw_printenv >/dev/null 2>&1; then
    exit 0
fi

# Only act if an upgrade is pending
UPGRADE_PENDING=$(fw_printenv -n upgrade_pending 2>/dev/null || echo 0)
if [ "${UPGRADE_PENDING}" != "1" ]; then
    exit 0
fi

# If already marked successful, just clear pending and reset bootcount
BOOT_SUCCESS=$(fw_printenv -n boot_success 2>/dev/null || echo 0)
if [ "${BOOT_SUCCESS}" = "1" ]; then
    fw_setenv upgrade_pending 0 || true
    fw_setenv bootcount 0 || true
    exit 0
fi

# Mark boot as successful and clear pending flag
fw_setenv boot_success 1 || true
fw_setenv upgrade_pending 0 || true
fw_setenv bootcount 0 || true

exit 0
