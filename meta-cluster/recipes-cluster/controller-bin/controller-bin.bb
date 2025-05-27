SUMMARY = "Controller"
DESCRIPTION = "Controller program for cluster"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
HOMEPAGE = "https://github.com/moevm/grpc_server"

SRC_URI = "git://github.com/moevm/grpc_server;branch=main;protocol=https;destsuffix=${GO_SRCURI_DESTSUFFIX}"
SRCREV = "3bf8b7841cde8c3c4c684f0ae18ff80f950e7d8b"

GO_IMPORT="github.com/moevm/grpc_server"
GO_INSTALL = "${GO_IMPORT}/controller/cmd/manager"

GO_WORKDIR = "${S}/src/${GO_IMPORT}/controller"

inherit go-mod

do_install:append() {
    mv ${D}${bindir}/controller ${D}${bindir}/${BPN}
}

FILES:${PN} = "${bindir}/${BPN}"
