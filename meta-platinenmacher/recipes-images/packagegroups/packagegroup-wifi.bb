SUMMARY = "Wifi support"
DESCRIPTION = "Wifi driver and tools"
HOMEPAGE = "https://platinenmacher.tech"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = "\
    kernel-module-brcmfmac \
    linux-firmware-bcm43xx \
"
