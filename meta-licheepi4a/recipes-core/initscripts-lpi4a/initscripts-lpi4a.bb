SUMMARY = "Init scripts for Lichee Pi 4A with DPDK/XDP"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://init-lpi4a.sh"

inherit update-rc.d

INITSCRIPT_NAME = "init-lpi4a.sh"
INITSCRIPT_PARAMS = "start 99 S ."

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/init-lpi4a.sh ${D}${sysconfdir}/init.d/init-lpi4a.sh
}
