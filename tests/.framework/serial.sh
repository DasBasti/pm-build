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

    # Read and sanitize response - remove various control sequences
    # Remove: \r, null bytes, bell, ESC character, CSI sequences, OSC sequences
    local response=$(cat "$capture_file" | sed 's/\x1b\[[^a-zA-Z]*[a-zA-Z]//g' | sed 's/\x1b][^\x07]*\x07//g' | sed 's/\x1b[^\[]]//g' | tr -d '\r\000\007')

    # Clean up
    rm -f "$capture_file"

    # Return response
    echo "$response"
}

# Send command and check if expected expression appears in response
# Usage: serial_send_and_expect <command> <expected_pattern> [timeout_seconds]
# Returns: 0 if pattern found, 1 if not found
serial_send_and_expect() {
    local command="$1"
    local expected="$2"
    local timeout="${3:-2}"

    # Get response
    local response=$(serial_send_and_capture "$command" "$timeout")

    # Check if expected pattern is in response
    if [[ "$response" =~ $expected ]]; then
        return 0
    else
        return 1
    fi
}

# Global variables for background serial reading
SERIAL_READER_PID=""
SERIAL_FIFO=""
SERIAL_LINE=""

# Start background reading from serial port
# Must be called before serial_read_line
# Usage: serial_start_reading
serial_start_reading() {
    # Clean up any existing reader
    serial_stop_reading

    # Create named pipe (FIFO)
    SERIAL_FIFO=$(mktemp -u -p /dev/shm)
    mkfifo "$SERIAL_FIFO"

    # Start reading in background with a wrapper that keeps retrying
    # This prevents the reader from dying
    # Ignore SIGHUP to prevent signals from tests killing the reader
    (
        trap '' HUP
        while true; do
            cat "$SERIAL" 2>/dev/null || sleep 0.1
        done
    ) > "$SERIAL_FIFO" &
    SERIAL_READER_PID=$!

    # Give reader time to start
    sleep 0.1
}

# Read a single line from serial with timeout
# Must call serial_start_reading first
# Usage: serial_read_line [timeout_seconds]
# Returns: 0 if line read, 1 if timeout or no data
# Line is stored in global SERIAL_LINE variable (sanitized)
serial_read_line() {
    local timeout="${1:-2}"
    SERIAL_LINE=""

    # Check if reader is active
    if [ -z "$SERIAL_READER_PID" ] || [ -z "$SERIAL_FIFO" ]; then
        echo "DEBUG: Reader not active (PID=$SERIAL_READER_PID, FIFO=$SERIAL_FIFO)" > /dev/tty 2>/dev/null || true
        return 1
    fi

    # Check if reader process is still alive
    if ! kill -0 "$SERIAL_READER_PID" 2>/dev/null; then
        echo "DEBUG: Reader process died (PID=$SERIAL_READER_PID)" > /dev/tty 2>/dev/null || true
        return 1
    fi

    # Debug: Show we're about to read
    # echo "DEBUG: Starting read with ${timeout}s timeout..." > /dev/tty 2>/dev/null || true

    # Read one line with timeout from FIFO
    if IFS= read -r -t "$timeout" SERIAL_LINE < "$SERIAL_FIFO"; then
        # Sanitize the line - remove various control sequences
        SERIAL_LINE=$(echo "$SERIAL_LINE" | sed 's/\x1b\[[^a-zA-Z]*[a-zA-Z]//g' | sed 's/\x1b][^\x07]*\x07//g' | sed 's/\x1b[^\[]]//g' | tr -d '\r\000\007')

        # Echo to terminal for debugging (bypass output capture)
        echo "SERIAL: $SERIAL_LINE" > /dev/tty 2>/dev/null || true

        return 0
    else
        # local read_result=$?
        # echo "DEBUG: Read timed out or failed (exit code: $read_result)" > /dev/tty 2>/dev/null || true
        return 1
    fi
}

# Stop background reading and clean up
# Usage: serial_stop_reading
serial_stop_reading() {
    if [ -n "$SERIAL_READER_PID" ]; then
        kill $SERIAL_READER_PID 2>/dev/null
        wait $SERIAL_READER_PID 2>/dev/null
        SERIAL_READER_PID=""
    fi

    if [ -n "$SERIAL_FIFO" ] && [ -e "$SERIAL_FIFO" ]; then
        rm -f "$SERIAL_FIFO"
        SERIAL_FIFO=""
    fi

    SERIAL_LINE=""
}

# Sanitize string for safe display (make control chars visible)
sanitize_for_display() {
    echo "$1" | cat -v
}
