SUMMARY = "Worker"
DESCRIPTION = "Worker binary file"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI="file://worker.tar.gz"

S="${WORKDIR}/worker"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/worker-bin ${D}${bindir}/worker-bin
}

FILES_${PN} += "${bindir}/worker-bin"
