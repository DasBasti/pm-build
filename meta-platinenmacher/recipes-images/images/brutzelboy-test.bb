SUMMARY = "Test image with ptest support for brutzelboy"
DESCRIPTION = "An image based on core-image-minimal with ptest packages and runner for automated testing."
LICENSE = "MIT"

require brutzelboy.inc

# Add ptest-pkgs to image features to automatically include all ptest packages
EXTRA_IMAGE_FEATURES += "ptest-pkgs"

IMAGE_INSTALL:append = " \
    ptest-runner \
"
