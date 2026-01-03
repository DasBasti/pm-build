#!/bin/false

source "$SCRIPT_DIR/.framework/colors.sh"
source "$SCRIPT_DIR/.framework/log.sh"
source "$SCRIPT_DIR/.framework/tests.sh"
source "$SCRIPT_DIR/.framework/serial.sh"
source "$SCRIPT_DIR/.framework/ssh.sh"
source "$SCRIPT_DIR/.framework/device.sh"
source "$SCRIPT_DIR/.framework/mount_image.sh"

test_runner() {
# Display banner
cat <<'EOF'
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║     PM-LINUX TEST INFRASTRUCTURE                         ║
║     Platinenmacher Test Runner                           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF

log_console ""

# Find all test-*.sh files in the tests directory
if [ -n "$TEST_REALM" ]; then
    # Search only in specified realm subdirectory
    search_path="$SCRIPT_DIR/$TEST_REALM"
    if [ ! -d "$search_path" ]; then
        log_error "Test realm '$TEST_REALM' not found at: $search_path"
        exit 1
    fi
    log_info "Searching for test scripts in realm: $TEST_REALM"
else
    # Search in all subdirectories
    search_path="$SCRIPT_DIR"
    log_info "Searching for test scripts..."
fi

TEST_FILES=()
while IFS= read -r -d '' file; do
    TEST_FILES+=("$file")
done < <(find "$search_path" -type f -name "test-*.sh" -print0 | sort -z)

# List found test files
if [ ${#TEST_FILES[@]} -eq 0 ]; then
    log_error "No test files found."
    exit 0
else
    log_info "Found ${#TEST_FILES[@]} test file(s):"
    for test_file in "${TEST_FILES[@]}"; do
        # Display relative path from tests directory
        rel_path="${test_file#$SCRIPT_DIR/}"
        log_console "  - $rel_path"
    done
fi

# Run tests from each test file
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

for test_file in "${TEST_FILES[@]}"; do
    rel_path="${test_file#$SCRIPT_DIR/}"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Running tests from: $rel_path"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Run in subshell to isolate each test file
    (
        # Source the test file
        source "$test_file"

        # Find all functions that start with "test_" but exclude test_runner
        test_functions=$(declare -F | awk '{print $3}' | grep "^test_" | grep -v "^test_runner$")

        if [ -z "$test_functions" ]; then
            log_warning "  ⚠ No test functions found"
            exit 0
        fi

        pass_tests=0
        fail_tests=0
        # Run each test function
        while IFS= read -r test_func; do
            # Capture test output and EXPECT value in RAM
            test_output=$(mktemp -p /dev/shm)
            expect_file=$(mktemp -p /dev/shm)
            export EXPECT_FILE="$expect_file"

            # Run test function in a nested subshell to prevent exit from terminating the loop
            # Otput expect string if it was set by the test function
            if [ -s "$expect_file" ]; then
                log_info "Expected: $(cat "$expect_file")"
            fi

            # Check test result and update counters
            if ( $test_func ) > "$test_output" 2>&1; then
                echo -n -e "${COLOR_GREEN}✓${COLOR_RESET}"
                if [ -s "$expect_file" ]; then
                    log_info " Expect $(cat "$expect_file")"
                fi
                ((pass_tests++))
            else
                echo -n -e "${COLOR_RED}✗${COLOR_RESET}"
                ((fail_tests++))

                if [ -s "$expect_file" ]; then
                    log_error " Expect $(cat "$expect_file")"
                fi
                log_error "Test Failed: $rel_path :: $test_func"
                log_error "════════════════════════════════════════════════════════════"
                if [ -s "$test_output" ]; then
                    cat "$test_output"
                fi
                log_error "════════════════════════════════════════════════════════════"
                log_error ""

                # Exit immediately if fail-early is enabled
                if [ "$FAIL_EARLY" = true ]; then
                    # Clean up temp files before early exit
                    rm -f "$test_output" "$expect_file"
                    echo ""
                    exit 1
                fi
            fi

            # Clean up temp files (normal flow)
            rm -f "$test_output" "$expect_file"
        done <<< "$test_functions"
        echo ""

        if [ $fail_tests -eq 0 ]; then
            exit 0
        else
            exit 1
        fi
    )

    # Capture exit status
    test_exit=$?
    if [ $test_exit -eq 0 ]; then
        ((PASSED_TESTS++))
    else
        ((FAILED_TESTS++))

        # Exit immediately if fail-early is enabled
        if [ "$FAIL_EARLY" = true ]; then
            ((TOTAL_TESTS++))
            log_console ""
            break
        fi
    fi
    ((TOTAL_TESTS++))
    log_console ""
done

# Print summary
log_console "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Test Summary"
log_console "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_console "Total test files: $TOTAL_TESTS"
log_console "Passed: $PASSED_TESTS"
log_console "Failed: $FAILED_TESTS"
log_console ""

if [ $FAILED_TESTS -eq 0 ]; then
    log_success "✓ All tests passed!"
    exit 0
else
    log_error "✗ Some tests failed."
    exit 1
fi
}
