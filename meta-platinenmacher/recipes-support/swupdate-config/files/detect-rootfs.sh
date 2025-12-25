#!/bin/bash
# Detect current rootfs partition label
# Returns: copyA or copyB

set -euo pipefail

CURRENT_ROOT=$(findmnt -n -o SOURCE /)
LABEL=$(blkid -s PARTLABEL -o value "$CURRENT_ROOT")

case "$LABEL" in
    rootfsA)
        echo "copyA"
        ;;
    rootfsB)
        echo "copyB"
        ;;
    *)
        echo "unknown"
        exit 1
        ;;
esac
