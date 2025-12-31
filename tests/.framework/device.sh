#!/bin/false

# =============================================================================
# Device Helper Functions
# Common functions for device tests (boot, reboot, marker checks)
# =============================================================================

# Wait for device to boot and show login prompt
# Usage: device_wait_for_boot [timeout_seconds]
device_wait_for_boot() {
    local timeout="${1:-120}"
    local start=$(date +%s)

    log_info "Waiting for device to boot (timeout: ${timeout}s)..."

    serial_start_reading

    while true; do
        local now=$(date +%s)
        local elapsed=$((now - start))

        if [ $elapsed -ge $timeout ]; then
            serial_stop_reading
            log_error "Timeout waiting for boot after ${timeout}s"
            return 1
        fi

        if serial_read_line 5; then
            # Check for login prompt or shell prompt
            if [[ "$SERIAL_LINE" =~ "login:" ]] || [[ "$SERIAL_LINE" =~ "#" ]] || [[ "$SERIAL_LINE" =~ "~" ]]; then
                serial_stop_reading
                log_info "Device booted successfully"
                sleep 2  # Give services time to start
                return 0
            fi
        fi
    done
}

# Trigger a reboot via serial
# Usage: device_reboot
device_reboot() {
    log_info "Rebooting device..."
    serial_configure || return 1
    serial_send_and_capture "reboot" 2
    sleep 3  # Wait for reboot to start
}

# Check if a file contains expected content via serial
# Usage: device_check_file_content <file_path> <expected_content>
# Returns: 0 if content found, 1 otherwise
device_check_file_content() {
    local file_path="$1"
    local expected_content="$2"

    serial_configure || return 1
    local response=$(serial_send_and_capture "cat $file_path 2>/dev/null" 2)

    if echo "$response" | grep -q "$expected_content"; then
        return 0
    else
        return 1
    fi
}
