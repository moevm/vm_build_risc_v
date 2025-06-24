#!/bin/bash

set -e

sudo chown builder /home/builder/qemu

cd /home/builder/qemu/

if [ ! -d "poky" ]; then
  git clone git://git.yoctoproject.org/poky
fi

cd poky

if [ ! -d "meta-virtualization" ]; then
  git clone git://git.yoctoproject.org/meta-virtualization
fi

if [ ! -d "meta-openembedded" ]; then
  git clone https://github.com/openembedded/meta-openembedded
fi

if [ ! -d "vm_build_risc_v" ]; then
  git clone https://github.com/moevm/vm_build_risc_v
fi

source oe-init-build-env

bitbake-layers add-layer ../meta-openembedded/meta-oe ../meta-openembedded/meta-python \
  ../meta-openembedded/meta-networking ../meta-openembedded/meta-filesystems ../meta-virtualization \
  ../vm_build_risc_v/meta-cluster

echo "MACHINE ?= \"qemuriscv64\"" >>conf/local.conf
echo "DISTRO_FEATURES:append = \" virtualization\"" >>conf/local.conf
echo "IMAGE_INSTALL:append = \" docker docker-compose git controller-bin worker-bin\"" >>conf/local.conf
echo "IMAGE_ROOTFS_EXTRA_SPACE = \" 1048576\"" >>conf/local.conf

bitbake core-image-minimal
