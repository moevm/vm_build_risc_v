#!/bin/bash

set -e

YOCTO_BRANCH="scarthgap"
WORKDIR="/home/builder/qemu"

mkdir -p "${WORKDIR}"
if [ ! -d "${WORKDIR}/poky" ]; then
    sudo chown builder:builder "${WORKDIR}"
fi
cd "${WORKDIR}"

if [ ! -d "poky" ]; then
    git clone -b "${YOCTO_BRANCH}" --depth=1 https://git.yoctoproject.org/poky
fi

cd poky

if [ ! -d "meta-openembedded" ]; then
    git clone -b "${YOCTO_BRANCH}" --depth=1 https://github.com/openembedded/meta-openembedded
fi

if [ ! -d "meta-clang" ]; then
    git clone -b "${YOCTO_BRANCH}" --depth=1 https://github.com/kraj/meta-clang.git
fi

source oe-init-build-env build

cat > conf/bblayers.conf << 'LAYERSEOF'
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  /home/builder/qemu/poky/meta \
  /home/builder/qemu/poky/meta-poky \
  /home/builder/qemu/poky/meta-yocto-bsp \
  /home/builder/qemu/poky/meta-openembedded/meta-oe \
  /home/builder/qemu/poky/meta-openembedded/meta-python \
  /home/builder/qemu/poky/meta-openembedded/meta-networking \
  /home/builder/qemu/poky/meta-openembedded/meta-filesystems \
  /home/builder/qemu/poky/meta-clang \
  /home/builder/meta-cluster \
  "
LAYERSEOF

if ! grep -q "### QEMU RISCV64 CONFIG ###" conf/local.conf 2>/dev/null; then
    cat >> conf/local.conf << 'CONFEOF'
### QEMU RISCV64 CONFIG ###
MACHINE = "qemuriscv64"
CONNECTIVITY_CHECK_URIS = ""
IMAGE_ROOTFS_EXTRA_SPACE = "1048576"
### END QEMU RISCV64 CONFIG ###
CONFEOF
fi

bitbake cluster-image
