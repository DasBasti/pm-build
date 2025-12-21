SUMMARY = "Benchmark tools"
DESCRIPTION = "Collection of Benchmark tools"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = "\
    bonnie++ \
    cpuburn-arm \
    dhrystone \
    fio \
    hdparm \
    iozone3 \
    iperf3 \
    lmbench \
    pmbw \
    rt-tests \
    evtest \
    perf \
    stress-ng \
    sysbench \
    ${@bb.utils.contains("MACHINE_FEATURES", "gpu", "glmark2", "",d)} \
    ${@bb.utils.contains("DISTRO_FEATURES", "systemd", "systemd-analyze", "",d)} \
"
