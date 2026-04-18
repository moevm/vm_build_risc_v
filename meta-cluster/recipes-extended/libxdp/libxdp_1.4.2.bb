SUMMARY = "XDP programming helper library"
DESCRIPTION = "libxdp provides helper functions for loading and managing XDP programs"
HOMEPAGE = "https://github.com/xdp-project/xdp-tools"
LICENSE = "GPL-2.0-only & LGPL-2.1-only & BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9ee53f8d06bbdb4c11b1557ecc4f8cd5"

SRC_URI = "git://github.com/xdp-project/xdp-tools.git;protocol=https;branch=main"
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
    cat > ${S}/config.mk << EOF
CC := ${CC}
CLANG := clang
LLC := llc
LD := ${LD}
OBJCOPY := ${OBJCOPY}
M4 := m4
READELF := ${READELF}
PKG_CONFIG := pkg-config
BPFTOOL :=

PRODUCTION := 1
DYNAMIC_LIBXDP := 1
MAX_DISPATCHER_ACTIONS := 10
BPF_TARGET := bpf

HAVE_ZLIB := y
HAVE_ELF := y
SECURE_GETENV := y
HAVE_FEATURES := ZLIB ELF SECURE_GETENV \
  LIBBPF_BPF_XDP_ATTACH \
  LIBBPF_BPF_MAP_CREATE \
  LIBBPF_BTF__LOAD_FROM_KERNEL_BY_ID \
  LIBBPF_BTF__TYPE_CNT \
  LIBBPF_BPF_OBJECT__NEXT_MAP \
  LIBBPF_BPF_OBJECT__NEXT_PROGRAM \
  LIBBPF_BPF_PROGRAM__INSN_CNT \
  LIBBPF_BPF_PROGRAM__TYPE \
  LIBBPF_BPF_PROGRAM__FLAGS \
  LIBBPF_BPF_PROGRAM__EXPECTED_ATTACH_TYPE

SYSTEM_LIBBPF := y
LIBBPF_VERSION := 1.4.7
OBJECT_LIBBPF :=

CFLAGS += ${CFLAGS}
LDLIBS := -lbpf -lelf -lz
ARCH_INCLUDES := -isystem ${STAGING_INCDIR}
EOF
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
