#!/bin/false

source "$SCRIPT_DIR/.framework/log.sh"

load_test_environment() {
    local start_dir="$PWD"

    # Check for .env (more generic)
    if [ -f "$start_dir/.env" ]; then
        log_info "Loading environment from: $start_dir/.env"
        set -a  # Automatically export all variables
        source "$start_dir/.env"
        set +a
    fi

    # Check for .test.env first (more specific)
    if [ -f "$start_dir/.test.env" ]; then
        log_info "Loading test environment from: $start_dir/.test.env"
        set -a  # Automatically export all variables
        source "$start_dir/.test.env"
        set +a
    fi
}
