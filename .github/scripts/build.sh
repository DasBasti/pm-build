#!/usr/bin/env bash
set -eo pipefail

source $GITHUB_WORKSPACE/init-build-env

# Run the Yocto build
bitbake core-image-minimal