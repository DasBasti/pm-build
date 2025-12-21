COMPATIBLE_MACHINE:thebrutzler-v1 = "thebrutzler-v1"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:thebrutzler-v1 = "\
    file://rockchip-kmeta;type=kmeta;name=rockchip-kmeta;destsuffix=rockchip-kmeta \
    file://lcsc-taishanpi-rk3566.dts;subdir=dts-files \
"

do_configure:append(){
    cp ${UNPACKDIR}/dts-files/lcsc-taishanpi-rk3566.dts ${S}/arch/arm64/boot/dts/rockchip/
    echo 'dtb-$(CONFIG_ARCH_ROCKCHIP) += lcsc-taishanpi-rk3566.dtb' >> ${S}/arch/arm64/boot/dts/rockchip/Makefile
}
