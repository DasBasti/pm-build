#!/bin/false

test_serial_connection_parameter() {
    expect "Environment has SERIAL and BAUD set"
    # Check if serial device exists
    [ -z "$SERIAL" ] && { log_error "SERIAL variable not set"; fail; }
    [ ! -e "$SERIAL" ] && { log_error "Serial device $SERIAL does not exist"; fail; }
    # Check if we have read/write access
    [ ! -r "$SERIAL" ] && { log_error "No read access to $SERIAL"; fail; }
    [ ! -w "$SERIAL" ] && { log_error "No write access to $SERIAL"; fail; }

    [ -z "$BAUD" ] && { log_error "BAUD variable not set"; fail; }

}

test_autologin() {
    expect "to open the console and be logged in as thebrutzler"

    # Configure serial port
    serial_configure || fail

    # Send newline and capture response
    response=$(serial_send_and_capture "" 2)
    if [[ ! "$response" =~ thebrutzler@ ]]; then
        log_error "Did not receive thebrutzler@ prompt"
        log_error "Response length: ${#response}"
        if [ ${#response} -gt 0 ]; then
            safe_response=$(sanitize_for_display "$response")
            log_error "Response:\n'${safe_response}'"
        fi
        fail
    fi

    # Send ctrl+d and capture response with longer timeout for auto-login
    response=$(serial_send_and_capture "$(printf '\x04')" 8)

    # Verify we got back to the prompt (auto-login worked)
    if [[ ! "$response" =~ thebrutzler@ ]]; then
        safe_response=$(sanitize_for_display "$response")
        log_error "Did not return to thebrutzler@ prompt after ctrl+d"
        log_error "Response:\n'${safe_response}'"
        fail
    fi

    pass
}
