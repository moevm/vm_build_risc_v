SUMMARY = "XDP programming helper library"
DESCRIPTION = "libxdp provides helper functions for loading and managing XDP programs"
HOMEPAGE = "https://github.com/xdp-project/xdp-tools"
LICENSE = "GPL-2.0-only & LGPL-2.1-only & BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9ee53f8d06bbdb4c11b1557ecc4f8cd5"

SRC_URI = "git://github.com/xdp-project/xdp-tools.git;protocol=https;branch=main \
           file://config.mk.in \
"
SRCREV = "v1.4.2"

S = "${WORKDIR}/git"

DEPENDS = "libbpf elfutils zlib clang-native"

inherit pkgconfig

EXTRA_OEMAKE = " \
    PREFIX=${prefix} \
    LIBDIR=${libdir} \
    DESTDIR=${D} \
"

do_configure() {
    sed -e "s|@CC@|${CC}|g" \
        -e "s|@LD@|${LD}|g" \
        -e "s|@OBJCOPY@|${OBJCOPY}|g" \
        -e "s|@READELF@|${READELF}|g" \
        -e "s|@CFLAGS@|${CFLAGS}|g" \
        -e "s|@STAGING_INCDIR@|${STAGING_INCDIR}|g" \
        ${WORKDIR}/config.mk.in > ${S}/config.mk
}

do_compile() {
    oe_runmake -C lib/libxdp
}

do_install() {
    oe_runmake -C lib/libxdp install
    chown -R root:root ${D}
}

FILES:${PN} = "${libdir}/lib*.so.* ${libdir}/bpf"
FILES:${PN}-dev = "${includedir} ${libdir}/lib*.so ${libdir}/pkgconfig"
FILES:${PN}-staticdev = "${libdir}/lib*.a"
