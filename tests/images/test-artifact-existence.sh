#!/bin/false


test_deploydir_exists() {
    expect "the deploy dir to be available"
    ls $DEPLOY_DIR || fail

    pass
}

test_machine_has_images() {
    expect "a directory called $MACHINE in the deploy/images folder."
    ls $DEPLOY_DIR/images/$MACHINE/ || fail

    pass
}

test_rootfs_artifacts_exists() {
    expect "to have rootfs tar, and wic image for a default image."
    ls $DEPLOY_DIR/images/$MACHINE/*.tar
    ls $DEPLOY_DIR/images/$MACHINE/*.wic

    pass
}

test_spdx_is_created() {
    expect "to have a spdx.json for every rootfs image."

    # Find all rootfs image files (ext4), excluding symlinks
    rootfs_files=$(find $DEPLOY_DIR/images/$MACHINE/ -type f -name "*.rootfs*.ext4")

    # Check if we found any rootfs files
    [ -z "$rootfs_files" ] && { log_error "No rootfs.ext4 files found"; fail; }

    # For each rootfs file, check if corresponding spdx.json exists
    while IFS= read -r rootfs_file; do
        # Get the base name without .ext4 and add .spdx.json
        base="${rootfs_file%.ext4}"
        spdx_file="${base}.spdx.json"
        [ -e "$spdx_file" ] || { log_error "Missing spdx.json for $(basename $rootfs_file)"; fail; }
    done <<< "$rootfs_files"

    pass
}
