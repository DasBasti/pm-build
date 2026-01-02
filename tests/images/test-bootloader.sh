#!/bin/false

test_uboot_environment_variables() {
    expect "u-boot environment to contain values from u-boot.env file"

    # Get the project root (assuming tests are in PROJECT_ROOT/tests/)
    local project_root="$(cd "$SCRIPT_DIR/.." && pwd)"

    # Get the path to the dump script
    local dump_script="$project_root/bitbake-builds/poky-whinlatter/layers/meta-rockchip/scripts/dump-uboot-env-from-yocto-image.sh"

    # Check if the script exists
    if [ ! -f "$dump_script" ]; then
        log_error "U-Boot environment dump script not found: $dump_script"
        fail
    fi

    # Find the WIC image
    local wic_image=$(find $DEPLOY_DIR/images/$MACHINE/ -type f -name "*.wic" ! -name "*.wic.bmap" ! -name "*.wic.zip" | head -n 1)

    if [ -z "$wic_image" ]; then
        log_error "No WIC image found in $DEPLOY_DIR/images/$MACHINE/"
        fail
    fi

    log_info "Using WIC image: $(basename $wic_image)"

    # Dump the u-boot environment
    local env_dump=$(mktemp)
    local SKIP=$(( 8128 * 512 ))
    dd if="$wic_image" ibs=1 skip=$SKIP count=32k 2> /dev/null | strings > "$env_dump" 2>&1

    if [ $? -ne 0 ]; then
        log_error "Failed to dump u-boot environment"
        cat "$env_dump"
        rm -f "$env_dump"
        fail
    fi

    # Get the expected u-boot.env file
    local uboot_env_file="$project_root/meta-pm-thebrutzler/recipes-bsp/u-boot/files/thebrutzler_v2.env"

    if [ ! -f "$uboot_env_file" ]; then
        log_error "U-Boot environment file not found: $uboot_env_file"
        rm -f "$env_dump"
        fail
    fi

    # Parse expected values from u-boot.env
    local failed=0
    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # Skip if key is empty after trimming
        [ -z "$key" ] && continue

        # Remove surrounding single/double quotes from the value (they may be present in the .env file but not in the stored env)
        local orig_value="$value"
        value=$(printf '%s' "$value" | sed -e "s/^['\"]//" -e "s/['\"]$//")

        # Search for the key=value pair in the hex dump
        # The environment is stored as null-terminated strings, so we look for the ASCII representation
        # Format in hexdump: key=value\x00
        local search_pattern="${key}=${value}"

        # Try direct fixed-string match first
        if grep -F -q -- "$search_pattern" "$env_dump"; then
            log_info "✓ Found: $key=$orig_value"
        else
            # Fallback: strip single/double quotes from both the pattern and the dump and try again
            local search_pattern_nq="$(printf '%s' "$search_pattern" | tr -d "'\"")"
            local env_dump_nq
            env_dump_nq=$(mktemp)
            tr -d "'\"" < "$env_dump" > "$env_dump_nq"

            if grep -F -q -- "$search_pattern_nq" "$env_dump_nq"; then
                log_info "✓ Found (after stripping quotes): $key=$orig_value"
                rm -f "$env_dump_nq"
            else
                log_error "Missing or incorrect u-boot environment variable: $key=$orig_value"
                cat "$env_dump"
                rm -f "$env_dump_nq"
                failed=1
            fi
        fi
    done < "$uboot_env_file"

    # Clean up
    rm -f "$env_dump"

    if [ $failed -eq 1 ]; then
        fail
    fi

    pass
}
