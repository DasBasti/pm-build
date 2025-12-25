#!/usr/bin/env bash
set -euo pipefail

# Regex to match and extract year, month, and patch from the version string
version_regex='^([0-9]{4})\.([0-9]{2})\.([0-9]+)(.*)'

CONF="meta-platinenmacher/conf/distro/platinenmacher-linux.conf"

if [[ ! -f "$CONF" ]]; then
    echo "Error: $CONF not found" >&2
    exit 1
fi

# Extract the current DISTRO_VERSION value (between the first pair of quotes on the line)
version_line=$(grep -E "^\s*DISTRO_VERSION\s*=" "$CONF" || true)
if [[ -z "$version_line" ]]; then
    echo "Error: DISTRO_VERSION not found in $CONF" >&2
    exit 1
fi

# get the value between quotes
current_version=$(echo "$version_line" | sed -E 's/.*=\s*"(.*)".*/\1/')
if [[ -z "$current_version" ]]; then
    echo "Error: unable to parse current DISTRO_VERSION" >&2
    exit 1
fi

echo "Current version: $current_version"

if [[ $current_version =~ $version_regex ]]; then
    year="${BASH_REMATCH[1]}"
    month="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
    build="${BASH_REMATCH[4]}"
else
    echo "Error: did not find version in current DISTRO_VERSION ('$current_version')" >&2
    exit 1
fi

# current year/month
now_year=$(date +%Y)
now_month=$(date +%m)

if [[ "$year" == "$now_year" && "$month" == "$now_month" ]]; then
    patch=$((patch + 1))
else
    year="$now_year"
    month="$now_month"
    patch=0
fi

new_version="${year}.${month}.${patch}${build}"
echo "New version: $new_version"

# Replace the DISTRO_VERSION value in place, keeping surrounding formatting intact
escaped_new_version=$(printf '%s' "$new_version" | sed 's/[&/\\]/\\&/g')
# Use sed for in-place replacement of the first matching DISTRO_VERSION line
# Replace only the value inside the first pair of quotes on the line
sed -i -E '0,/^[[:space:]]*DISTRO_VERSION[[:space:]]*=/{s/^[[:space:]]*(DISTRO_VERSION[[:space:]]*=[[:space:]]*")(.*?)(".*)/\1'"${escaped_new_version}"'\3/}' "$CONF"

echo "Updated $CONF"

# Replace the PV value in meta-platinenmacher/recipes-images/images/brutzelboy.inc
INC_FILE="meta-platinenmacher/recipes-images/images/brutzelboy.inc"

if [[ ! -f "$INC_FILE" ]]; then
    echo "Error: $INC_FILE not found" >&2
    exit 1
fi

# Replace the PV value in place, keeping surrounding formatting intact
sed -i -E '0,/^[[:space:]]*PV[[:space:]]*=/{s/^[[:space:]]*(PV[[:space:]]*=[[:space:]]*")(.*?)(".*)/\1'"${year}.${month}.${patch}"'\3/}' "$INC_FILE"

echo "Updated $INC_FILE"

# Show the modified line for verification
grep -E "^\s*DISTRO_VERSION\s*=" "$CONF" || true
grep -E "^\s*PV\s*=" "$INC_FILE" || true
