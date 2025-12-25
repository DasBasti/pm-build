#!/bin/bash

set -e

echo "Updating all git submodules..."

# Update all submodules to the latest commit on their tracked branches
# MAybe use --merge to merge upstream changes into the current submodule branch
git submodule update --remote --recursive

echo "Git submodules updated successfully!"
