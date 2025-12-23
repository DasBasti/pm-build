#!/usr/bin/env bash

# Parse command line arguments
VERBOSE=true
FAIL_EARLY=false
TEST_REALM=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quiet)
            VERBOSE=false
            shift
            ;;
        --fail-early)
            FAIL_EARLY=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            # Treat as realm (positional argument)
            TEST_REALM="$1"
            shift
            ;;
    esac
done
export VERBOSE
export FAIL_EARLY
export TEST_REALM

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

source "$SCRIPT_DIR/.framework/source_env.sh"
source "$SCRIPT_DIR/.framework/runner.sh"

# Load environment files from current directory if they exist
load_test_environment

test_runner
