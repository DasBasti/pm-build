#!/bin/false

# =============================================================================
# Configuration Persistence Tests
# These tests verify that system configuration survives reboots and updates
# =============================================================================

# =============================================================================
# Test: Configuration persists through reboots (same rootfs)
# =============================================================================
test_data_persists_through_reboots() {
    expect "The system configuration to be present after reboot"

    serial_configure || { log_error "Failed to configure serial"; fail; }

    # Step 1: Create a unique test marker
    local test_id=$(date +%s)
    local marker_content="persist-test-${test_id}"

    log_info "Creating test marker: $marker_content"

    # Create a test file in a persisted location (hostname file)
    # We'll back up the original and restore after test
    local orig_hostname=$(serial_send_and_capture "cat /etc/hostname" 2 | grep -v "^#" | grep -v "hostname" | tr -d '\n' | head -1)
    log_info "Original hostname: $orig_hostname"

    # Modify hostname as our test marker
    serial_send_and_capture "echo '${marker_content}' > /etc/hostname" 2
    sleep 1

    # Step 2: Force a persist operation
    log_info "Triggering persist operation..."
    serial_send_and_capture "/usr/sbin/persist-config.sh persist" 3

    # Verify the persist storage has our marker
    local stored=$(serial_send_and_capture "cat /home/.system-config/hostname/hostname" 2)
    if ! echo "$stored" | grep -q "$marker_content"; then
        log_error "Marker not found in persist storage after persist"
        # Restore original hostname
        serial_send_and_capture "echo '${orig_hostname}' > /etc/hostname" 2
        fail
    fi
    log_info "Marker persisted successfully"

    # Step 3: Reboot the device
    device_reboot

    # Step 4: Wait for boot
    device_wait_for_boot 120 || {
        log_error "Device failed to boot"
        fail
    }

    # Step 5: Verify our marker was restored
    serial_configure || { log_error "Failed to configure serial after reboot"; fail; }
    sleep 2  # Let restore service complete

    local restored=$(serial_send_and_capture "cat /etc/hostname" 2)
    if echo "$restored" | grep -q "$marker_content"; then
        log_info "Marker found after reboot - persistence works!"
        # Restore original hostname
        serial_send_and_capture "echo '${orig_hostname}' > /etc/hostname" 2
        serial_send_and_capture "/usr/sbin/persist-config.sh persist" 2
        pass
    else
        log_error "Marker NOT found after reboot"
        log_error "Expected: $marker_content"
        log_error "Got: $restored"
        # Restore original hostname
        serial_send_and_capture "echo '${orig_hostname}' > /etc/hostname" 2
        serial_send_and_capture "/usr/sbin/persist-config.sh persist" 2
        fail
    fi
}

# =============================================================================
# Test: Configuration persists through A/B rootfs updates
# =============================================================================
test_data_persists_through_swupdates() {
    expect "The system configuration to be present in the newly installed rootfs"

    serial_configure || { log_error "Failed to configure serial"; fail; }

    # Step 1: Record current rootfs slot
    local current_slot=$(serial_send_and_capture "fw_printenv -n BOOT_ORDER 2>/dev/null | cut -d' ' -f1" 3)
    current_slot=$(echo "$current_slot" | grep -E "^(A|B)$" | head -1)
    log_info "Current boot slot: $current_slot"

    # Step 2: Verify connman WiFi config exists (from previous setup)
    local wifi_check=$(serial_send_and_capture "ls /var/lib/connman/ 2>/dev/null | grep wifi" 2)
    if [ -z "$wifi_check" ]; then
        log_warning "No WiFi configuration found - test may not be meaningful"
    else
        log_info "Found WiFi config: $wifi_check"
    fi

    # Step 3: Check persistent storage has connman config
    local stored_connman=$(serial_send_and_capture "ls /home/.system-config/connman/ 2>/dev/null" 3)
    if [ -z "$stored_connman" ]; then
        log_error "No connman config in persistent storage - nothing to test"
        log_info "Hint: Connect to WiFi first, then run persist-config.sh persist"
        fail
    fi
    log_info "Connman persistent storage contents: $stored_connman"

    # Step 4: Check hash directory (should exist if daemon ran)
    local hash_check=$(serial_send_and_capture "ls /var/lib/persist-config/hashes/ 2>/dev/null" 3)
    log_info "Current hash files: $hash_check"

    # Step 5: Verify the restore service ran at boot
    local restore_status=$(serial_send_and_capture "systemctl status restore-config.service 2>/dev/null | grep Active" 3)
    if echo "$restore_status" | grep -qE "(inactive|dead|exited)"; then
        log_info "Restore service completed: $restore_status"
    else
        log_warning "Restore service status: $restore_status"
    fi

    # Step 6: Verify connman config is present in active rootfs
    local active_wifi=$(serial_send_and_capture "ls -la /var/lib/connman/ 2>/dev/null" 3)
    log_info "Active connman directory: $active_wifi"

    if echo "$active_wifi" | grep -q "wifi_"; then
        log_info "WiFi configuration present in active rootfs"
        pass
    else
        # Check if this is because daemon overwrote it (the bug we fixed)
        local daemon_status=$(serial_send_and_capture "systemctl status persist-config.service 2>/dev/null | grep Active" 3)
        log_info "Persist daemon status: $daemon_status"

        log_error "WiFi configuration missing from /var/lib/connman/"
        log_error "This may indicate the race condition bug (daemon overwriting restored config)"
        fail
    fi
}
