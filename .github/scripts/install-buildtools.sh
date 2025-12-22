#!/usr/bin/env bash

set -eo pipefail

# Find the environment-setup file under bitbake-builds
ENV_FILE=""
if [ -d "bitbake-builds" ]; then
  ENV_FILE=$(find bitbake-builds -type f -name 'environment-setup-*' -print -quit 2>/dev/null || true)
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
  echo "Warning: environment-setup file not found in bitbake-builds"
  exit 1
fi
