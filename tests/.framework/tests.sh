#!/bin/false

pass() {
    exit 0
}

fail() {
    exit 1
}

# Set expectation message for test (will be shown on failure)
expect() {
    if [ -n "$EXPECT_FILE" ]; then
        echo "$1" > "$EXPECT_FILE"
    fi
}
