#!/bin/false

# Configure serial port with standard settings
# Uses global $SERIAL and $BAUD variables
serial_configure() {
    stty -F "$SERIAL" "$BAUD" raw -echo cs8 -cstopb -parenb || return 1
}

# Send command to serial and capture response with timeout
# Usage: serial_send_and_capture <command> [timeout_seconds]
# Uses global $SERIAL variable
# Returns sanitized response via stdout
serial_send_and_capture() {
    local command="$1"
    local timeout="${2:-2}"

    # Create temp file to capture serial output
    local capture_file=$(mktemp -p /dev/shm)

    # Start reading from serial in background
    cat "$SERIAL" > "$capture_file" &
    local reader_pid=$!

    # Give reader time to start
    sleep 0.2

    # Send command to serial
    if [ -n "$command" ]; then
        echo "$command" > "$SERIAL"
    else
        # Send empty line if no command
        echo "" > "$SERIAL"
    fi

    # Wait for response
    sleep "$timeout"

    # Stop the reader
    kill $reader_pid 2>/dev/null
    wait $reader_pid 2>/dev/null

    # Read and sanitize response
    local response=$(cat "$capture_file" | tr -d '\r\000\007\033' | sed 's/\x1b\[[0-9;]*[mGKHJA-Z]//g')

    # Clean up
    rm -f "$capture_file"

    # Return response
    echo "$response"
}

# Sanitize string for safe display (make control chars visible)
sanitize_for_display() {
    echo "$1" | cat -v
}
