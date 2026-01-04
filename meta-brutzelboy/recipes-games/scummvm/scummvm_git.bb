SUMMARY = "Virtual Machine for several classic adventure games"
DESCRIPTION = "Virtual Machine for several classic graphical point-and-click adventure games"
HOMEPAGE = "https://www.scummvm.org"
SECTION = "games"
PRIORITY = "optional"
LICENSE = "GPL-3.0-or-later"
LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464"

inherit autotools-brokensep pkgconfig gtk-icon-cache manpages features_check

REQUIRED_DISTRO_FEATURES = "x-wayland opengl"

SRC_URI = "\
    git://github.com/scummvm/scummvm.git;protocol=https;branch=branch-2-9-1 \
    file://0001-use-pkg-config-to-gather-sdl-information.patch \
    file://0002-Do-not-split-binaries-during-install.patch \
    file://scummvm.desktop \
"
SRCREV = "673fa29d8e83a0d1cd35867b55d9cd2fab2a3f77"
PV = "2.9.1"

DEPENDS = "\
    virtual/libgl \
    libsdl2 \
    libsdl2-net \
    gtk+3 \
    curl \
    hicolor-icon-theme \
    libpng \
    jpeg \
    libvorbis \
    libogg \
    libtheora \
    zlib \
    flac \
    faad2 \
    libmad \
    mpeg2dec \
    fluidsynth \
    librsvg-native \
"

DISABLE_STATIC = ""

EXTRA_OECONF = "\
    --backend=sdl \
    --prefix=${prefix} \
    --mandir=${mandir} \
    --host=${HOST_SYS} \
    --enable-all-engines \
    --enable-optimizations \
    --enable-plugins \
    --default-dynamic \
"

do_configure() {
    ./configure ${EXTRA_OECONF}
        sed -i "s/AS := as/AS := ${AS}/" ${S}/config.mk
        sed -i "s/AR := ar cru/AR := ${AR} cru/" ${S}/config.mk
        sed -i "s/STRIP := strip/STRIP := ${STRIP}/" ${S}/config.mk
        sed -i "s/RANLIB := ranlib/RANLIB := ${RANLIB}/" ${S}/config.mk
}

PACKAGES:prepend = "${PN}-autostart "
FILES:${PN} += "${datadir}"

do_install:append(){
    install -D ${UNPACKDIR}/scummvm.desktop ${D}${sysconfdir}/xdg/autostart/scummvm.desktop

    # Convert SVG icon to PNG for weston launcher
    install -d ${D}${datadir}/icons/hicolor/128x128/apps
    rsvg-convert -w 128 -h 128 \
        ${D}${datadir}/icons/hicolor/scalable/apps/org.scummvm.scummvm.svg \
        -o ${D}${datadir}/icons/hicolor/128x128/apps/org.scummvm.scummvm.png
}

FILES:${PN}-autostart = "\
    ${sysconfdir}/xdg/autostart/scummvm.desktop \
"
