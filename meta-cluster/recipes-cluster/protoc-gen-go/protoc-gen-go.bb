SUMMARY = "Go protocol buffers compiler plugin"
HOMEPAGE = "https://github.com/golang/protobuf"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=939cce1ec101726fa754e698ac871622"

SRC_URI = "git://github.com/golang/protobuf;branch=master;protocol=https"
SRCREV = "${AUTOREV}"

DEPENDS = "go-native"

GOARCH = "${@ "amd64" if d.getVar('TARGET_ARCH') == "x86_64" else "riscv64"}"

do_compile[network] = "1"

do_compile() {
    cd protoc-gen-go
    GOOS=${TARGET_GOOS} GOARCH=${GOARCH} go build -trimpath -o protoc-gen-go main.go
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/protoc-gen-go/protoc-gen-go ${D}${bindir}/protoc-gen-go
}

INSANE_SKIP:${PN} += "ldflags"

FILES:${PN} = "${bindir}"

BBCLASSEXTEND = "native"
