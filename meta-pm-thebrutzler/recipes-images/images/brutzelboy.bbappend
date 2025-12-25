# Use custom WKS file for A/B partitioning
WKS_FILE = "platinenmacher-ab.wks"

# Ensure IMAGE_BOOT_FILES contains the files we want to place into the
# boot partition. This lets the WIC bootimg_partition plugin copy FITs (and
# kernel/dtb if needed) into the boot partition during WIC creation.
# Use ${@...} to force evaluation of DTB_FILES in this context so WIC gets
# concrete filenames instead of the literal token.
IMAGE_BOOT_FILES:append = " fitImage "
