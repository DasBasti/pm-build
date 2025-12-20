#!/usr/bin/env bash

set -eo pipefail

# Source the provided init-build-env script (supports either ./init-build-env or init-build-env)
if [ -f ./init-build-env ]; then
  # shellcheck disable=SC1091
  source ./init-build-env
elif [ -f init-build-env ]; then
  # shellcheck disable=SC1091
  source init-build-env
else
  echo "Warning: init-build-env not found"
fi

# Install build tools and capture environment-setup path
# Save stdout/stderr to a log for debugging
bitbake-setup install-buildtools 2>&1 | tee buildtools-install.log

# Prefer to find the environment-setup file under bitbake-builds
ENV_FILE=""
if [ -n "${GITHUB_WORKSPACE:-}" ] && [ -d "$GITHUB_WORKSPACE/bitbake-builds" ]; then
  ENV_FILE=$(find "$GITHUB_WORKSPACE/bitbake-builds" -type f -name 'environment-setup-*' -print -quit || true)
fi

if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  echo "$ENV_FILE" > "$GITHUB_WORKSPACE/.buildtools_env" || true
  echo "Saved buildtools env: $ENV_FILE"
else
  # Fallback: try to extract from the install log
  ENV_FILE=$(grep -o '/[^ ]*environment-setup[^ ]*' buildtools-install.log | tail -n1 || true)
  if [ -n "$ENV_FILE" ]; then
    echo "$ENV_FILE" > "$GITHUB_WORKSPACE/.buildtools_env" || true
    echo "Saved buildtools env (from log): $ENV_FILE"
  else
    echo "Warning: environment-setup file not found"
  fi
fi

# If a saved buildtools env file exists, source it
if [ -f "$GITHUB_WORKSPACE/.buildtools_env" ]; then
  SAVED_ENV_FILE=$(cat "$GITHUB_WORKSPACE/.buildtools_env" 2>/dev/null || true)
  if [ -n "$SAVED_ENV_FILE" ] && [ -f "$SAVED_ENV_FILE" ]; then
    echo "Sourcing buildtools env: $SAVED_ENV_FILE"
    # shellcheck disable=SC1090
    . "$SAVED_ENV_FILE"
  else
    echo "Saved buildtools env path not valid: $SAVED_ENV_FILE"
  fi
fi
