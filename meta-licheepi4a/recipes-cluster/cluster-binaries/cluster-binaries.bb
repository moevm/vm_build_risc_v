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
    file://cluster-dhcp \
    file://cluster-run \
"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP:${PN} = "ldflags already-stripped file-rdeps"

do_install() {
    install -d ${D}/opt/traffic-filtering
    install -m 0755 ${WORKDIR}/worker ${D}/opt/traffic-filtering/worker
    install -m 0755 ${WORKDIR}/controller ${D}/opt/traffic-filtering/controller
    install -m 0755 ${WORKDIR}/worker_af_packet ${D}/opt/traffic-filtering/worker_af_packet
    install -m 0755 ${WORKDIR}/cluster-dhcp ${D}/opt/traffic-filtering/cluster-dhcp
    install -m 0755 ${WORKDIR}/cluster-run ${D}/opt/traffic-filtering/cluster-run

    install -d ${D}/opt/traffic-filtering/internal/service/config
    install -m 0644 ${WORKDIR}/categories.json ${D}/opt/traffic-filtering/internal/service/config
    install -m 0644 ${WORKDIR}/providers.json ${D}/opt/traffic-filtering/internal/service/config
    install -m 0644 ${WORKDIR}/worker.env ${D}/opt/traffic-filtering/internal/service/config
    install -m 0644 ${WORKDIR}/controller.env ${D}/opt/traffic-filtering/internal/service/config
    install -m 0644 ${WORKDIR}/policy.toml ${D}/opt/traffic-filtering/internal/service/config
}

RDEPENDS:${PN} += "dnsmasq"

FILES:${PN} = "/opt/traffic-filtering"
