#!/bin/bash
set -eo pipefail

cd "$(git rev-parse --show-toplevel)"

# Find all files matching oelint-adv file types, excluding git submodules
FILES=$(git ls-files | grep -E '\.(bb|bbappend|bbclass|inc|conf)$' || true)

echo "Run oelint-adv on $(echo "$FILES" | wc -l) files"
oelint-adv --quiet --constantmods "+.oelint-adv/soc-families.json" --extra-layer=openembedded-layer --color --fix --jobs=1 --nobackup --mode all --exit-zero $FILES
