#!/usr/bin/env bash

set -eo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the repository root (two levels up from .github/scripts)
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Find the environment-setup file under bitbake-builds
ENV_FILE=""
if [ -d "$REPO_ROOT/bitbake-builds" ]; then
  ENV_FILE=$(find "$REPO_ROOT/bitbake-builds" -type f -name 'environment-setup-*' -print -quit 2>/dev/null || true)
else
  echo "Error: bitbake-builds directory not found at $REPO_ROOT/bitbake-builds"
  exit 1
fi

if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  # Save the environment file path for later use
  if [ -n "${GITHUB_WORKSPACE:-}" ]; then
    echo "$ENV_FILE" > "$GITHUB_WORKSPACE/.buildtools_env" || true
  fi
  echo "Found buildtools env: $ENV_FILE"
  
  # Source the environment setup script
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  echo "Sourced buildtools environment"
else
  echo "Error: environment-setup file not found in $REPO_ROOT/bitbake-builds"
  exit 1
fi
