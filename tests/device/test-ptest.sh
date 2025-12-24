#!/bin/false

# Helper function to run a single ptest
# Parameters: testname
# Returns: 0 if test passed, 1 if test failed
run_single_ptest() {
    local testname="$1"

    log_info "Running ptest: $testname"

    # Start background serial reading
    serial_start_reading

    # Send the ptest command
    echo "ptest-runner $testname" > "$SERIAL"

    # Process output line by line
    local has_result=false
    local has_fail=false

    while serial_read_line 60; do
        # Check for test result indicators
        if echo "$SERIAL_LINE" | grep -qE "(PASS|FAIL|SKIP)"; then
            has_result=true
            if echo "$SERIAL_LINE" | grep -q "FAIL"; then
                has_fail=true
            fi
        fi
    done

    # Stop reading and clean up
    serial_stop_reading

    # Classify test result and return status
    if [ "$has_result" = true ]; then
        if [ "$has_fail" = true ]; then
            log_warn "Test $testname had failures"
            return 1
        else
            log_info "Test $testname completed successfully"
            return 0
        fi
    else
        log_warn "Test $testname did not produce expected output"
        return 1
    fi
}

test_ptest_is_installed() {
    expect "ptest to be installed"

    # Configure serial port
    serial_configure || fail

    # Check if ptest-runner is installed and responds
    if ! serial_send_and_expect "ptest-runner -h" "Usage: ptest-runner" 2; then
        log_error "ptest-runner not found or not responding correctly"
        fail
    fi

    pass
}

test_get_ptest_list() {
    expect "ptest to list available tests"

    # Configure serial port
    serial_configure || fail

    # Check if ptest-runner can list tests
    if ! serial_send_and_expect "ptest-runner -l" "Available ptests:" 2; then
        log_error "ptest-runner failed to list available tests"
        fail
    fi

    pass
}

test_parse_and_run_ptests() {
    expect "to parse ptest list and run tests individually"

    # Configure serial port
    serial_configure || fail

    # become root
    if ! serial_send_and_expect "su" "root@" 2; then
        log_error "failed to become root"
        fail
    fi

    # Get the list of available ptests
    # Note: We still need to capture the response to parse test names
    response=$(serial_send_and_capture "ptest-runner -l" 5)
    if ! echo "$response" | grep -q "Available ptests:"; then
        log_error "Failed to get ptest list"
        fail
    fi

    # Parse the output to extract test names and paths
    # Format: testname    /path/to/ptest
    local test_count=0
    local failed_tests=()
    local passed_tests=()

    while IFS= read -r line; do
        # Skip empty lines and the header
        [[ -z "$line" ]] && continue
        [[ "$line" =~ "Available ptests:" ]] && continue
        [[ "$line" =~ "ptest-runner" ]] && continue
        [[ "$line" =~ "$USER_NAME" ]] && continue


        # Extract test name (first column)
        testname=$(echo "$line" | awk '{print $1}')
        testpath=$(echo "$line" | awk '{print $2}')

        # Skip if no test name
        [[ -z "$testname" ]] && continue

        ((test_count++))

        # Run the test using helper function
        if run_single_ptest "$testname"; then
            passed_tests+=("$testname")
        else
            failed_tests+=("$testname")
        fi
    done <<< "$response"

    # Report results
    log_info "Total tests found: $test_count"
    log_info "Passed/Completed: ${#passed_tests[@]}"
    log_info "Failed/Incomplete: ${#failed_tests[@]}"

    if [ ${#failed_tests[@]} -gt 0 ]; then
        log_warning "Failed tests: ${failed_tests[*]}"
    fi

    if [ $test_count -eq 0 ]; then
        log_error "No ptests were found or run"
        fail
    fi

    pass
}
