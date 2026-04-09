#!/bin/bash

set -e

YOCTO_BRANCH="scarthgap"
WORKDIR="/home/builder/yocto"

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

source oe-init-build-env build

# TODO:
# Сделать отдельный файл для конфигов
# bblayers.conf и local.conf

cat > conf/bblayers.conf << 'LAYERSEOF'
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  /home/builder/yocto/poky/meta \
  /home/builder/yocto/poky/meta-poky \
  /home/builder/yocto/poky/meta-yocto-bsp \
  /home/builder/yocto/poky/meta-openembedded/meta-oe \
  /home/builder/yocto/poky/meta-openembedded/meta-python \
  /home/builder/yocto/poky/meta-openembedded/meta-networking \
  /home/builder/yocto/poky/meta-openembedded/meta-filesystems \
  /home/builder/meta-cluster \
  /home/builder/meta-licheepi4a \
  "
LAYERSEOF

if ! grep -q "### LICHEEPI4A CONFIG ###" conf/local.conf 2>/dev/null; then
    cat >> conf/local.conf << 'CONFEOF'
### LICHEEPI4A CONFIG ###
# Machine: Lichee Pi 4A with TH1520 SoC
MACHINE = "licheepi4a"

# Use RevyOS kernel 6.6 for full hardware support
PREFERRED_PROVIDER_virtual/kernel = "linux-revyos-th1520"

# Extra disk space in rootfs
IMAGE_ROOTFS_EXTRA_SPACE = "1048576"
IMAGE_ROOTFS_ALIGNMENT = "4096"

# Accept all licenses (needed for some firmware blobs)
LICENSE_FLAGS_ACCEPTED = "commercial"

# Package management on target
EXTRA_IMAGE_FEATURES += "package-management"

# Disable network connectivity check (runs inside Docker)
CONNECTIVITY_CHECK_URIS = ""
### END LICHEEPI4A CONFIG ###
CONFEOF
fi

bitbake licheepi4a-dpdk-image

exec /home/builder/scripts/mkboot.sh
