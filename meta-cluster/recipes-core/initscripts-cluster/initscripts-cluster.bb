SUMMARY = "Init scripts for cluster image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://init.sh \
           file://dnsmasq.conf \
"

RDEPENDS:${PN} = "dnsmasq"

inherit update-rc.d

INITSCRIPT_NAME = "init.sh"
INITSCRIPT_PARAMS = "start 99 S ."

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/init.sh ${D}${sysconfdir}/init.d/init.sh
    install -d ${D}${sysconfdir}/cluster
    install -m 0644 ${WORKDIR}/dnsmasq.conf ${D}${sysconfdir}/cluster/dnsmasq.conf
}
