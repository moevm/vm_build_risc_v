SUMMARY = "Cluster worker and controller binaries with configs"
LICENSE = "CLOSED"

SRC_URI = " \
    file://worker \
    file://controller \
    file://categories.json \
    file://providers.json \
    file://worker.env \
    file://controller.env \
    file://policy.toml \
    file://worker_af_packet \
"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP:${PN} = "ldflags already-stripped file-rdeps"

do_install() {
    install -d ${D}/usr/bin
    install -m 0755 ${WORKDIR}/worker ${D}/usr/bin/cluster-worker
    install -m 0755 ${WORKDIR}/controller ${D}/usr/bin/cluster-controller
    install -m 0755 ${WORKDIR}/worker_af_packet ${D}/usr/bin/worker_af_packet

    install -d ${D}/etc/cluster
    install -m 0644 ${WORKDIR}/categories.json ${D}/etc/cluster/
    install -m 0644 ${WORKDIR}/providers.json ${D}/etc/cluster/
    install -m 0644 ${WORKDIR}/worker.env ${D}/etc/cluster/
    install -m 0644 ${WORKDIR}/controller.env ${D}/etc/cluster/
    install -m 0644 ${WORKDIR}/policy.toml ${D}/etc/cluster/
}

FILES:${PN} = "/usr/bin/cluster-worker /usr/bin/cluster-controller /usr/bin/worker_af_packet /etc/cluster"
