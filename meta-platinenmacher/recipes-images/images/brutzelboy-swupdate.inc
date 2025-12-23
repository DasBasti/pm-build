inherit swupdate

SRC_URI = "file://sw-description"

# This image depends on the actual rootfs image
IMAGE_DEPENDS = "brutzelboy"

# Specify which images to include in the SWU file
SWUPDATE_IMAGES = "brutzelboy"

# Specify the filesystem type to package
SWUPDATE_IMAGES_FSTYPES[brutzelboy] = ".rootfs.ext4"
