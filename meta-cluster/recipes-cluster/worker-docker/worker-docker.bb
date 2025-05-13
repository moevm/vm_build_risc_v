SUMMARY = "Worker"
DESCRIPTION = "Docker image for worker"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI="file://Dockerfile"
DEPENDS="docker-moby"

IMAGE_NAME="worker"

do_build() {
    docker build -t ${IMAGE_NAME} .
}

do_install() {
    install -d ${D}${datadir}/docker
    docker save ${IMAGE_NAME} -o ${D}${datadir}/docker/${IMAGE_NAME}.tar
}

FILES_${PN} += "${datadir}/docker/${IMAGE_NAME}.tar"
