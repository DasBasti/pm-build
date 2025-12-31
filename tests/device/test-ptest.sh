#!/bin/false

# Helper function to run a single ptest
# Parameters: testname
# Returns: 0 if test passed, 1 if test failed
run_single_ptest() {
    local testname="$1"

    log_info "Running ptest: $testname"

    # Run ptest via SSH and capture output
    local output
    output=$(ssh_cmd "ptest-runner $testname" 2>&1) || true

    # Check for test result indicators
    local has_result=false
    local has_fail=false

    if echo "$output" | grep -qE "(PASS|FAIL|SKIP)"; then
        has_result=true
        if echo "$output" | grep -q "FAIL"; then
            has_fail=true
        fi
    fi

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

    # Check if ptest-runner is installed and responds
    response=$(ssh_cmd "ptest-runner -h" 2>&1) || {
        log_error "ptest-runner not found or SSH connection failed"
        fail
    }

    if ! echo "$response" | grep -q "Usage: ptest-runner"; then
        log_error "ptest-runner not responding correctly"
        fail
    fi

    pass
}

test_get_ptest_list() {
    expect "ptest to list available tests"

    # Check if ptest-runner can list tests
    response=$(ssh_cmd "ptest-runner -l" 2>&1) || {
        log_error "ptest-runner failed to list available tests"
        fail
    }

    if ! echo "$response" | grep -q "Available ptests:"; then
        log_error "ptest-runner output missing expected header"
        fail
    fi

    pass
}

test_parse_and_run_ptests() {
    expect "to parse ptest list and run tests individually"

    # Get the list of available ptests
    response=$(ssh_cmd "ptest-runner -l" 2>&1) || {
        log_error "Failed to get ptest list"
        fail
    }

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
