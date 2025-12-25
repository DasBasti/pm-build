#!/bin/bash
PARAMS=("$@")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set IMAGES to the recipe names (filenames without the .bb extension) available
IMAGES=""
for f in "$SCRIPT_DIR"/meta-platinenmacher/recipes-images/images/*.bb; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .bb)"
    IMAGES="${IMAGES:+$IMAGES }$name"
done

# Source into bitbake environment
source ./init-build-env

# nice -n 10: Lower CPU priority (0=normal, 19=lowest)
# ionice -c 2 -n 7: Best-effort I/O class, priority 7 (0=highest, 7=lowest)
BITBAKE="nice -n 10 ionice -c 2 -n 7 bitbake"

case "${PARAMS[0]:-}" in
    list)
        echo ""
        if [ -n "$IMAGES" ]; then
            echo "Available images: $IMAGES"
        else
            echo "Available images: <none>"
        fi
        ;;
    validate)
        $BITBAKE -e
        ;;
    all)
        $BITBAKE $IMAGES
        ;;
    clean)
        $BITBAKE -c cleanall "${PARAMS[@]}"
        ;;
    *)
        $BITBAKE "${PARAMS[@]}"
        ;;
esac
