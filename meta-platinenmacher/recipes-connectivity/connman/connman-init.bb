SUMMARY = "Initialization service for ConnMan"
DESCRIPTION = "Initializes necessary ConnMan services. This is \
               needed in headless system, otherwise we might not be able to \
               connect to device after installation. This service is only run \
               once in the first boot.\
"
LICENSE  = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://connman-firstboot.sh;beginline=7;endline=18;md5=95c5d66479370ef3964c4aef9255476f"

SRC_URI = "\
    file://connman-firstboot.sh \
    file://connman-init.service \
    file://connman.settings.template \
"

S = "${UNPACKDIR}"
PR = "r1"

inherit systemd

SYSTEMD_PACKAGES = "connman-init"

SYSTEMD_SERVICE:${PN} = "connman-init.service"

FILES:${PN} = "connman-init.service \
               ${libdir}/connman/connman-firstboot.sh \
               ${libdir}/connman/connman.settings.template \
"

do_install() {
    install -d ${D}${libdir}/connman
    install -d ${D}${nonarch_base_libdir}/systemd/system
    install -m 0755 ${UNPACKDIR}/connman-firstboot.sh ${D}${libdir}/connman
    install -m 0644 ${UNPACKDIR}/connman.settings.template ${D}${libdir}/connman
    install -m 0755 ${UNPACKDIR}/connman-init.service ${D}${nonarch_base_libdir}/systemd/system
}
