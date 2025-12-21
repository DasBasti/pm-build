DESCRIPTION = "Wifi stuff"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    kernel-module-brcmfmac \
    linux-firmware-bcm43xx \
"