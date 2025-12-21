SUMMARY = "A image based on core-image-minimal with just benchmark tools."
require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " \
    packagegroup-benchmark \
"