#!/bin/false

# Note: Uses ssh_cmd from .framework/ssh.sh

# =============================================================================
# Basic Network Interface Tests (via Serial - no network dependency)
# =============================================================================

test_00_wlan0_interface_up() {
    expect "wlan0 interface to be in UP state"

    # Use serial connection to check interface state (no network dependency)
    serial_configure || { log_error "Failed to configure serial"; fail; }

    response=$(serial_send_and_capture "cat /sys/class/net/wlan0/operstate" 2)

    # Extract the state from the response (filter out command echo and prompt)
    state=$(echo "$response" | grep -E "^(up|down|unknown|dormant)$" | head -1)

    if [ "$state" = "up" ]; then
        log_info "wlan0 is UP"
        pass
    elif [ -n "$state" ]; then
        log_error "wlan0 state is '$state', expected 'up'"
        fail
    else
        log_error "Failed to read wlan0 interface state via serial"
        fail
    fi
}

test_00_wlan0_has_ip() {
    expect "wlan0 to have an IPv4 address assigned"

    # Use serial connection to check IP address (no network dependency)
    serial_configure || { log_error "Failed to configure serial"; fail; }

    # Use full path to ip command since thebrutzler user may not have /sbin in PATH
    response=$(serial_send_and_capture "/sbin/ip -4 addr show wlan0" 3)

    # Extract IP address from response (matches IPv4 pattern, skip broadcast address)
    wlan_ip=$(echo "$response" | grep "inet " | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)

    if [ -n "$wlan_ip" ]; then
        log_info "wlan0 IP: $wlan_ip"
        pass
    else
        log_error "wlan0 has no IPv4 address"
        fail
    fi
}

# =============================================================================
# Connectivity Tests
# =============================================================================

test_gateway_reachable() {
    expect "default gateway to be reachable via ping"

    # Get default gateway
    gateway=$(ssh_cmd "ip route | awk '/default/ {print \$3}'") || {
        log_error "Failed to get default gateway"
        fail
    }

    [ -z "$gateway" ] && { log_error "No default gateway configured"; fail; }
    log_info "Default gateway: $gateway"

    # Ping gateway (3 packets, 2 second timeout)
    ssh_cmd "ping -c 3 -W 2 $gateway >/dev/null 2>&1" || {
        log_error "Cannot ping gateway $gateway"
        fail
    }

    log_info "Gateway is reachable"
    pass
}

test_dns_resolution() {
    expect "DNS resolution to work"

    # Try to resolve a well-known hostname
    resolved_ip=$(ssh_cmd "nslookup google.com 2>/dev/null | awk '/^Address/ && !/127.0.0/ {print \$2; exit}'") || {
        # Fallback: try getent if nslookup not available
        resolved_ip=$(ssh_cmd "getent hosts google.com 2>/dev/null | awk '{print \$1; exit}'") || {
            log_error "DNS resolution failed - neither nslookup nor getent available or working"
            fail
        }
    }

    if [ -n "$resolved_ip" ]; then
        log_info "Resolved google.com to $resolved_ip"
        pass
    else
        log_error "DNS resolution returned empty result"
        fail
    fi
}

test_internet_connectivity() {
    expect "internet connectivity to an external host"

    # Ping a reliable external host (Cloudflare DNS)
    ssh_cmd "ping -c 3 -W 3 1.1.1.1 >/dev/null 2>&1" || {
        # Fallback to Google DNS
        ssh_cmd "ping -c 3 -W 3 8.8.8.8 >/dev/null 2>&1" || {
            log_error "Cannot reach external hosts (1.1.1.1 or 8.8.8.8)"
            fail
        }
    }

    log_info "Internet connectivity confirmed"
    pass
}

test_network_latency() {
    expect "network latency to gateway to be reasonable (< 100ms average)"

    # Get default gateway
    gateway=$(ssh_cmd "ip route | awk '/default/ {print \$3}'") || {
        log_error "Failed to get default gateway"
        fail
    }

    [ -z "$gateway" ] && { log_error "No default gateway configured"; fail; }

    # Ping gateway and extract average latency (BusyBox compatible)
    ping_output=$(ssh_cmd "ping -c 5 -W 2 $gateway 2>&1") || {
        log_error "Ping to gateway failed"
        fail
    }

    # Parse avg from "round-trip min/avg/max = X/Y/Z ms" (BusyBox format)
    avg_latency=$(echo "$ping_output" | awk -F'[/ =]' '/round-trip|rtt/ {for(i=1;i<=NF;i++) if($i=="avg" || (i>1 && $(i-1)=="min")) {print $(i+1); exit}}')

    # Alternative parsing for different ping output formats
    if [ -z "$avg_latency" ]; then
        avg_latency=$(echo "$ping_output" | awk '/round-trip/ {split($4,a,"/"); print a[2]}')
    fi

    if [ -n "$avg_latency" ]; then
        log_info "Average latency to gateway: ${avg_latency}ms"

        # Check if latency is under 100ms (comparing as integers)
        latency_int=$(echo "$avg_latency" | awk '{printf "%d", $1}')
        if [ "$latency_int" -lt 100 ]; then
            log_info "Latency is acceptable"
            pass
        else
            log_error "Latency too high: ${avg_latency}ms (threshold: 100ms)"
            fail
        fi
    else
        log_error "Could not parse ping latency from output"
        fail
    fi
}

# =============================================================================
# Throughput Tests
# =============================================================================

test_iperf_via_wifi() {
    expect "iperf3 throughput test via WiFi to succeed with reasonable bandwidth"

    # 1. Check if wlan0 has an IP (network connection is established)
    # Use awk instead of grep -P for BusyBox compatibility
    wlan_ip=$(ssh_cmd "ip -4 addr show wlan0 2>/dev/null | awk '/inet / {split(\$2,a,\"/\"); print a[1]}'") || {
        log_error "Failed to get wlan0 IP from device - WiFi not connected?"
        fail
    }
    [ -z "$wlan_ip" ] && { log_error "wlan0 has no IP address"; fail; }
    log_info "Device wlan0 IP: $wlan_ip"

    # 2. Check if iperf3 is installed on the device and the host
    ssh_cmd "command -v iperf3 >/dev/null" || { log_error "iperf3 not installed on device"; fail; }
    command -v iperf3 >/dev/null || { log_error "iperf3 not installed on host"; fail; }

    # 3. Get the host IP that can reach the device (use awk for portability)
    host_ip=$(ip route get "$wlan_ip" 2>/dev/null | awk '/src/ {for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}') || {
        log_error "Failed to determine host IP for reaching device"
        fail
    }
    log_info "Host IP: $host_ip"

    # 4. Start iperf3 server on host in background
    iperf3 -s -1 -D -B "$host_ip" 2>/dev/null
    iperf_server_pid=$!
    sleep 1  # Give server time to start

    # Ensure cleanup on exit
    cleanup() {
        pkill -f "iperf3 -s" 2>/dev/null || true
    }
    trap cleanup EXIT

    # 5. Run iperf3 client on device connecting to host
    log_info "Running iperf3 client on device..."
    iperf_output=$(ssh_cmd "iperf3 -c $host_ip -t 5 -J" 2>&1) || {
        log_error "iperf3 client failed on device"
        cleanup
        fail
    }

    # Parse the result - extract bits_per_second using awk (BusyBox compatible)
    # Get the last occurrence of bits_per_second (receiver side)
    bandwidth_bps=$(echo "$iperf_output" | awk -F'[:,]' '/"bits_per_second"/ {gsub(/[^0-9.]/,"",$2); bps=$2} END {print bps}')
    if [ -n "$bandwidth_bps" ]; then
        bandwidth_mbps=$(echo "scale=2; $bandwidth_bps / 1000000" | bc)
        log_info "Measured bandwidth: ${bandwidth_mbps} Mbits/sec"

        # Check if bandwidth is at least 1 Mbit/s (reasonable minimum for WiFi)
        min_bandwidth=1000000
        if [ "$(echo "$bandwidth_bps > $min_bandwidth" | bc)" -eq 1 ]; then
            log_info "Bandwidth test passed"
        else
            log_error "Bandwidth too low: ${bandwidth_mbps} Mbits/sec (minimum: 1 Mbit/s)"
            fail
        fi
    else
        log_error "Failed to parse iperf3 output"
        fail
    fi

    # 6. Cleanup (trap will handle this, but explicit for clarity)
    cleanup

    pass
}
