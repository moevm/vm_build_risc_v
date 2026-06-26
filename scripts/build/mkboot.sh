#!/bin/bash

set -e

DEPLOY="/home/builder/yocto/poky/build/tmp/deploy/images/licheepi4a"
BOOT_IMG="${DEPLOY}/boot-licheepi4a.ext4"
BOOT_SIZE_MB=200

for f in Image.gz fw_dynamic.bin light_aon_fpga.bin; do
    if [ ! -f "${DEPLOY}/${f}" ]; then
        echo "ERROR: ${f} not found in ${DEPLOY}"
        exit 1
    fi
done

DTB="${DEPLOY}/th1520-lichee-pi-4a-16g.dtb"
if [ ! -f "$DTB" ]; then
    DTB=$(find "${DEPLOY}" -name "th1520-lichee-pi-4a-16g.dtb" -print -quit)
    if [ -z "$DTB" ]; then
        echo "ERROR: DTB not found in ${DEPLOY}"
        exit 1
    fi
fi

BOOT_DIR=$(mktemp -d)
trap "rm -rf ${BOOT_DIR}" EXIT

cp -v "${DEPLOY}/Image.gz" "${BOOT_DIR}/"
cp -v "${DEPLOY}/fw_dynamic.bin" "${BOOT_DIR}/"
cp -v "${DEPLOY}/light_aon_fpga.bin" "${BOOT_DIR}/"

mkdir -p "${BOOT_DIR}/dtbs"
cp -v "$DTB" "${BOOT_DIR}/dtbs/"

mkdir -p "${BOOT_DIR}/extlinux"
cat >"${BOOT_DIR}/extlinux/extlinux.conf" <<'EXTEOF'
default yocto
menu title Lichee Pi 4A Boot Menu

label yocto
    menu label Yocto DPDK Image
    linux /Image.gz
    fdt /dtbs/th1520-lichee-pi-4a-16g.dtb
    append root=/dev/mmcblk0p4 console=ttyS0,115200 console=tty1 earlycon=uart8250,mmio32,0xffe7014000,115200n8 rootwait rw clk_ignore_unused loglevel=7 rootfstype=ext4
EXTEOF

echo "    [extlinux.conf]"
cat "${BOOT_DIR}/extlinux/extlinux.conf"

truncate -s ${BOOT_SIZE_MB}M "${BOOT_IMG}"
mkfs.ext4 -F -d "${BOOT_DIR}" -L boot "${BOOT_IMG}"

echo "Created: ${BOOT_IMG}"
echo "Output artifacts in: ${DEPLOY}/"
