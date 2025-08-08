SUMMARY = "Controller"
DESCRIPTION = "Controller program for cluster"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "git://github.com/moevm/grpc_server;branch=main;protocol=https"
SRCREV = "${AUTOREV}"

DEPENDS = "go-native protobuf-native protoc-gen-go-native protoc-gen-go-grpc-native"

GOARCH = "${@ "amd64" if d.getVar('TARGET_ARCH') == "x86_64" else "riscv64"}"

do_compile() {
    cd controller
    protoc \
      --go_out=. \
      --go_opt=paths=source_relative \
      --go-grpc_out=. \
      --go-grpc_opt=paths=source_relative \
      pkg/proto/communication/communication.proto

    cd cmd/manager
    GOOS=${TARGET_GOOS} GOARCH=${GOARCH} go build -trimpath -o manager test.go
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/controller/cmd/manager/manager ${D}${bindir}/manager
}

INSANE_SKIP:${PN} += "ldflags"

FILES:${PN} = "${bindir}"
