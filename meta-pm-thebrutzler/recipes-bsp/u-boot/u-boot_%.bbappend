FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = "\
    file://thebrutzler_v2.env \
    file://bootcount.cfg \
"

rk_generate_env:prepend(){
    cat ${UNPACKDIR}/thebrutzler_v2.env >> ${B}/u-boot-initial-env
}
