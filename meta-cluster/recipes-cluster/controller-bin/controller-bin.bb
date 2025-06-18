SUMMARY = "Controller"
DESCRIPTION = "Controller program for cluster"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "git://github.com/moevm/grpc_server;branch=main;protocol=https"
SRCREV = "3bf8b7841cde8c3c4c684f0ae18ff80f950e7d8b"

S = "${WORKDIR}/git/controller"

DEPENDS = "go-native"

GOARCH = "${@ "amd64" if d.getVar('TARGET_ARCH') == "x86_64" else "riscv64"}"

do_compile() {
    cd cmd/manager
    GOOS=${TARGET_GOOS} GOARCH=${GOARCH} go build -trimpath -o manager main.go
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/cmd/manager/manager ${D}${bindir}/manager
}

INSANE_SKIP:${PN} += "ldflags"

FILES:${PN} = "${bindir}"
