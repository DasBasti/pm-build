#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running oelint-adv checks...${NC}"

# Check if oelint-adv is installed
if ! command -v oelint-adv &> /dev/null; then
    echo -e "${YELLOW}oelint-adv not found. Installing...${NC}"
    pip install -q oelint-adv
fi

# Get the files passed by pre-commit
FILES="$@"

if [ -z "$FILES" ]; then
    echo -e "${YELLOW}No files to check${NC}"
    exit 0
fi

# Run oelint-adv on the files
echo "Checking files: $FILES"

# Run with some common options:
# --quiet: Only show findings
# --color: Add color to output
# --exit-zero: Don't fail the check (remove this for strict checking)
oelint-adv --quiet --constantmods "+.oelint-adv/soc-families.json" --extra-layer=openembedded-layer --color --fix --jobs=1 --nobackup --mode all --exit-zero $FILES

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
else
    echo -e "${RED}✗ Some issues found. Please review the output above.${NC}"
fi

exit $EXIT_CODE
