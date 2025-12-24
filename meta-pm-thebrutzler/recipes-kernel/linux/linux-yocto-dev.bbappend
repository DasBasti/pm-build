COMPATIBLE_MACHINE:thebrutzler-v2 = "thebrutzler-v2"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

KMACHINE:thebrutzler-v2 = "thebrutzler-v2"

SRC_URI:append:thebrutzler-v2 = "\
    file://rockchip-kmeta;type=kmeta;name=rockchip-kmeta;destsuffix=rockchip-kmeta \
    file://lcsc-taishanpi-rk3566.dts;subdir=dts-files \
"

do_configure:append(){
    cp ${UNPACKDIR}/dts-files/lcsc-taishanpi-rk3566.dts ${S}/arch/arm64/boot/dts/rockchip/
    echo 'dtb-$(CONFIG_ARCH_ROCKCHIP) += lcsc-taishanpi-rk3566.dtb' >> ${S}/arch/arm64/boot/dts/rockchip/Makefile
}
