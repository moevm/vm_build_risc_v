SUMMARY = "Data Plane Development Kit"
HOMEPAGE = "http://dpdk.org"
LICENSE = "BSD-3-Clause & LGPL-2.1-only & GPL-2.0-only"
LIC_FILES_CHKSUM = "file://license/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://license/lgpl-2.1.txt;md5=4b54a1fd55a448865a0b32d41598759d \
                    file://license/bsd-3-clause.txt;md5=0f00d99239d922ffd13cabef83b33444"

SRC_URI = "git://dpdk.org/git/dpdk-stable;protocol=https;branch=23.11 \
           file://0001-config-meson-get-cpu_instruction_set-from-meson-opti.patch \
           "
SRCREV = "62f583c49bf67dd4d6733ece14e55fe6839e66d1"

S = "${WORKDIR}/git"

DEPENDS = "numactl python3-pyelftools-native libbpf libxdp"

inherit meson pkgconfig

EXTRA_OEMESON = " \
    -Dplatform=generic \
    -Dcpu_instruction_set=rv64gc \
    -Denable_docs=false \
    -Dtests=false \
    -Dmax_lcores=128 \
    -Dmax_numa_nodes=1 \
    -Ddisable_drivers=crypto/*,compress/*,regex/*,vdpa/*,event/*,baseband/*,gpu/*,raw/*,dma/* \
    -Denable_drivers=net/af_xdp,net/tap \
"

EXTRA_OEMESON:append:riscv64 = " \
    --cross-file ${WORKDIR}/riscv-dpdk-cross.ini \
"

do_configure:prepend() {
    cat > ${WORKDIR}/riscv-dpdk-cross.ini << 'EOF'
[properties]
vendor_id = 'generic'
arch_id = 'generic'
numa = false
EOF
}

do_install:append() {
    rm -rf ${D}${datadir}/dpdk/examples || true
    rm -rf ${D}${prefix}/share/dpdk/examples || true
}

PACKAGES =+ "${PN}-examples"

FILES:${PN} += " \
    ${libdir}/*.so* \
    ${libdir}/dpdk/ \
"
FILES:${PN}-dev = "${includedir} ${libdir}/pkgconfig"
FILES:${PN}-staticdev = "${libdir}/*.a"

RDEPENDS:${PN} += "numactl libbpf libxdp"

INSANE_SKIP:${PN} += "dev-so"

COMPATIBLE_MACHINE = "(qemuriscv64|licheepi4a)"
