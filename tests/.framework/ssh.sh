#!/bin/false

# SSH configuration for device tests
DEVICE_HOST="${DEVICE_HOST:-thebrutzlerv2.local}"
SSH_TIMEOUT="${SSH_TIMEOUT:-5}"
SSH_USER_NAME="${SSH_USER_NAME:-root}"

# Build SSH command with standard options
# Usage: ssh_cmd "command to run"
ssh_cmd() {
    ssh -n -o ConnectTimeout="${SSH_TIMEOUT}" -o StrictHostKeyChecking=no "${SSH_USER_NAME}@${DEVICE_HOST}" "$@"
}

# Check if device is reachable via SSH
# Returns: 0 if reachable, 1 otherwise
ssh_check_connection() {
    ssh_cmd "true" 2>/dev/null
}

# Run command on device and capture output
# Usage: result=$(ssh_run "command")
ssh_run() {
    ssh_cmd "$@"
}
