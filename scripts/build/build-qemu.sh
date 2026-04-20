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

cp /home/builder/scripts/conf/bblayers-qemu.conf conf/bblayers.conf

if ! grep -q "### QEMU RISCV64 CONFIG ###" conf/local.conf 2>/dev/null; then
    cp /home/builder/scripts/conf/local-qemu.conf conf/local.conf
fi

bitbake cluster-image
