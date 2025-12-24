#!/bin/bash
# Detect current rootfs partition from mount point
# Returns: rootfsA or rootfsB

CURRENT_ROOT=$(findmnt -n -o SOURCE /)

case "$CURRENT_ROOT" in
    */mmcblk0p9|*rootfsA)
        echo "rootfsA"
        ;;
    */mmcblk0p10|*rootfsB)
        echo "rootfsB"
        ;;
    *)
        echo "unknown"
        exit 1
        ;;
esac
