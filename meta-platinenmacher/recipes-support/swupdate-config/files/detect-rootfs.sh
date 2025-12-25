#!/bin/bash
# Detect current rootfs partition from mount point
# Returns: copyA or copyB

CURRENT_ROOT=$(findmnt -n -o SOURCE /)

case "$CURRENT_ROOT" in
    */mmcblk0p9|*rootfsA)
        echo "copyA"
        ;;
    */mmcblk0p10|*rootfsB)
        echo "copyB"
        ;;
    *)
        echo "unknown"
        exit 1
        ;;
esac
