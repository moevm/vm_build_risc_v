SUMMARY = "Go gRPC protocol buffers compiler plugin"
HOMEPAGE = "https://github.com/grpc/grpc-go"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

SRC_URI = "git://github.com/grpc/grpc-go.git;branch=master;protocol=https"
SRCREV = "${AUTOREV}"

DEPENDS = "go-native"

GOARCH = "${@ "amd64" if d.getVar('TARGET_ARCH') == "x86_64" else "riscv64"}"

do_compile[network] = "1"

do_compile() {
    cd cmd/protoc-gen-go-grpc
    GOOS=${TARGET_GOOS} GOARCH=${GOARCH} go build -trimpath -o protoc-gen-go-grpc .
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/cmd/protoc-gen-go-grpc/protoc-gen-go-grpc ${D}${bindir}
}

INSANE_SKIP:${PN} += "ldflags"

FILES:${PN} = "${bindir}"

BBCLASSEXTEND = "native"
