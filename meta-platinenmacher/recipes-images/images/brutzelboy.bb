SUMMARY = "An image for the brutzelboy during development"
DESCRIPTION = "An image based on core-image-minimal with development and benchmark tools."
LICENSE = "MIT"

# nooelint: oelint.file.requirenotfound - this is a file from poky
require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " \
    packagegroup-wifi \
"
