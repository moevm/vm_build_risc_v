SUMMARY = "Controller"
DESCRIPTION = "Controller binary file"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI="file://controller.tar.gz"

S="${WORKDIR}/controller"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/controller-bin ${D}${bindir}/controller-bin
}

FILES_${PN} += "${bindir}/controller-bin"
