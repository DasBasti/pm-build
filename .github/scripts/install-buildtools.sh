#!/usr/bin/env bash

set -eo pipefail
PROJECT_ROOT="${GITHUB_WORKSPACE}"
export PROJECT_ROOT

# Source build environment scripts directly (no safeguards)
if [ -f "$PROJECT_ROOT/bitbake-builds/poky-whinlatter/build/init-build-env" ]; then
  source "$PROJECT_ROOT/bitbake-builds/poky-whinlatter/build/init-build-env"
else
  echo "Warning: init-build-env not found at $PROJECT_ROOT/bitbake-builds/poky-whinlatter/build/init-build-env" >&2
fi

echo "we are here"
# Install build tools and capture environment-setup path
# Save stdout/stderr to a log for debugging
bitbake-setup install-buildtools 2>&1 | tee buildtools-install.log
