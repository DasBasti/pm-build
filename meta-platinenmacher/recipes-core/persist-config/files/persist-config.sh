#!/bin/bash
# Persistent configuration management
# Handles both persisting and restoring system configuration to/from /home/.system-config/

PERSIST_DIR="/home/.system-config"
HASH_DIR="/home/.system-config/hashes"
CONFIG_FILE="/etc/persist-config.conf"
CHECK_INTERVAL=60  # seconds between checks

# Handle signals for graceful shutdown (daemon mode)
cleanup() {
    echo "Received shutdown signal, performing final persist..."
    do_persist
    exit 0
}

# Parse config file and return entries
parse_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Config file not found: $CONFIG_FILE" >&2
        return 1
    fi
    grep -v '^#' "$CONFIG_FILE" | grep -v '^[[:space:]]*$'
}

# Get target directory from source path
# For directories: returns the source path itself
# For file patterns: returns the parent directory
get_target_dir() {
    local source="$1"
    if [ -d "$source" ]; then
        echo "$source"
    else
        dirname "$source"
    fi
}

# Calculate hash of a file or directory
calculate_hash() {
    local path="$1"
    if [ -d "$path" ]; then
        # For directories, hash the listing and all file contents
        find "$path" -type f -exec md5sum {} \; 2>/dev/null | sort | md5sum | cut -d' ' -f1
    elif [ -f "$path" ]; then
        md5sum "$path" 2>/dev/null | cut -d' ' -f1
    else
        echo ""
    fi
}

# Get stored hash for a config item
get_stored_hash() {
    local name="$1"
    local hash_file="$HASH_DIR/${name}.hash"
    if [ -f "$hash_file" ]; then
        cat "$hash_file"
    else
        echo ""
    fi
}

# Store hash for a config item
store_hash() {
    local name="$1"
    local hash="$2"
    mkdir -p "$HASH_DIR"
    echo "$hash" > "$HASH_DIR/${name}.hash"
}

# Persist a single config item
persist_item() {
    local name="$1"
    local source="$2"
    local target_dir="$PERSIST_DIR/$name"

    mkdir -p "$target_dir"

    if [ -d "$source" ]; then
        # Directory - sync contents
        rsync -a --delete "$source/" "$target_dir/"
    else
        # File pattern (glob) - copy matching files
        # Clear target first to handle removed files
        rm -f "$target_dir"/* 2>/dev/null || true
        for file in $source; do
            if [ -e "$file" ]; then
                cp -a "$file" "$target_dir/"
            fi
        done
    fi
}

# Check and persist a single item if changed
check_and_persist() {
    local name="$1"
    local source="$2"

    # Calculate current hash
    local current_hash
    if [ -d "$source" ]; then
        current_hash=$(calculate_hash "$source")
    else
        # For glob patterns, hash all matching files
        local combined=""
        for file in $source; do
            if [ -e "$file" ]; then
                combined+=$(calculate_hash "$file")
            fi
        done
        current_hash=$(echo "$combined" | md5sum | cut -d' ' -f1)
    fi

    local stored_hash
    stored_hash=$(get_stored_hash "$name")

    if [ "$current_hash" != "$stored_hash" ] && [ -n "$current_hash" ]; then
        echo "Change detected in $name, persisting..."
        persist_item "$name" "$source"
        store_hash "$name" "$current_hash"
        return 0
    fi
    return 1
}

# Persist all config items
do_persist() {
    local changes=0

    mkdir -p "$PERSIST_DIR"
    chown root:root "$PERSIST_DIR"
    chmod 0700 "$PERSIST_DIR"

    while IFS=: read -r name source; do
        # Skip empty entries
        [ -z "$name" ] && continue

        if check_and_persist "$name" "$source"; then
            changes=$((changes + 1))
        fi
    done < <(parse_config)

    if [ $changes -gt 0 ]; then
        echo "Persisted $changes changed configuration(s)"
    fi
}

# Calculate and store hash for a config item based on current state
update_hash() {
    local name="$1"
    local source="$2"

    local current_hash
    if [ -d "$source" ]; then
        current_hash=$(calculate_hash "$source")
    else
        # For glob patterns, hash all matching files
        local combined=""
        for file in $source; do
            if [ -e "$file" ]; then
                combined+=$(calculate_hash "$file")
            fi
        done
        current_hash=$(echo "$combined" | md5sum | cut -d' ' -f1)
    fi

    if [ -n "$current_hash" ]; then
        store_hash "$name" "$current_hash"
    fi
}

# Restore all config items
do_restore() {
    # Wait for /home to be mounted (max 30 seconds)
    for i in {1..30}; do
        if mountpoint -q /home; then
            break
        fi
        sleep 1
    done

    if [ ! -d "$PERSIST_DIR" ]; then
        echo "No persistent configuration found at $PERSIST_DIR"
        return 0
    fi

    echo "Restoring system configuration from $PERSIST_DIR"

    while IFS=: read -r name source; do
        # Skip empty entries
        [ -z "$name" ] && continue

        backup_dir="$PERSIST_DIR/$name"

        if [ ! -d "$backup_dir" ]; then
            echo "Skipping $name: no persistent data found"
            continue
        fi

        # Determine target directory from source path
        target_dir=$(get_target_dir "$source")

        # Ensure target directory exists
        mkdir -p "$target_dir"

        if [ -d "$source" ]; then
            # For directories, restore entire directory structure
            rsync -a "$backup_dir/" "$source/"
            echo "Restore folder $source/"
        else
            # For file patterns, restore files to target directory
            cp -a "$backup_dir" "$target_dir/" 2>/dev/null || true
            echo "copy file $(basnename $backup_dir) to $target_dir/"
        fi

        # Update hash to match restored state so daemon doesn't overwrite
        update_hash "$name" "$source"
    done < <(parse_config)

    # Fix permissions for SSH keys
    if [ -d "$PERSIST_DIR/ssh_host_keys" ]; then
        chmod 600 /etc/ssh/* 2>/dev/null || true
        chmod 644 /etc/ssh/*.pub 2>/dev/null || true
    fi

    echo "Configuration restore complete"
}

# Daemon mode - run periodically
do_daemon() {
    trap cleanup SIGTERM SIGINT SIGHUP

    echo "Starting persist-config daemon (interval: ${CHECK_INTERVAL}s)"

    # Initial persist on startup
    do_persist

    while true; do
        sleep "$CHECK_INTERVAL"
        do_persist
    done
}

# Main
case "${1:-}" in
    persist)
        echo "Running single persist check..."
        do_persist
        echo "Configuration persistence complete"
        ;;
    restore)
        do_restore
        ;;
    daemon)
        do_daemon
        ;;
    *)
        echo "Usage: $0 {persist|restore|daemon}"
        echo "  persist - Run a single persist check and exit"
        echo "  restore - Restore configuration from persistent storage"
        echo "  daemon  - Run as a background daemon"
        exit 1
        ;;
esac
