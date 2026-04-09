#!/bin/bash

set -e

IMAGE_DIR=""

usage() {
    echo "Usage: $0 [-i|--image-dir <path>]"
    echo "Flashes built Yocto images to Lichee Pi 4A via fastboot."
}

while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
        usage
        exit 0
        ;;
    -i | --image-dir)
        IMAGE_DIR="$2"
        shift 2
        ;;
    *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

if [ -z "$IMAGE_DIR" ]; then
    IMAGE_DIR="$(dirname "$0")/../yocto/poky/build/tmp/deploy/images/licheepi4a"
fi

if [ ! -d "$IMAGE_DIR" ]; then
    echo "Error: Image directory '$IMAGE_DIR' does not exist."
    exit 1
fi

for f in u-boot-with-spl.bin boot-licheepi4a.ext4; do
    if [ ! -f "${IMAGE_DIR}/${f}" ]; then
        echo "Error: ${f} not found in ${IMAGE_DIR}"
        exit 1
    fi
done

ROOTFS="${IMAGE_DIR}/licheepi4a-dpdk-image-licheepi4a.rootfs.ext4"
if [ ! -f "$ROOTFS" ]; then
    echo "Error: rootfs not found: ${ROOTFS}"
    exit 1
fi

lsusb | grep -q "T-HEAD" || {
    echo "Error: Lichee Pi 4A not detected."
    echo "Connect via USB-C and hold BOOT button while powering on."
    exit 1
}

echo "Flashing U-Boot to RAM and rebooting..."
sudo fastboot flash ram "${IMAGE_DIR}/u-boot-with-spl.bin"
sudo fastboot reboot
sleep 2

echo "Flashing U-Boot to eMMC..."
sudo fastboot flash uboot "${IMAGE_DIR}/u-boot-with-spl.bin"

echo "Flashing boot partition..."
sudo fastboot flash boot "${IMAGE_DIR}/boot-licheepi4a.ext4"

echo "Flashing rootfs..."

ROOTFS_SIZE=$(stat -L -c %s "$ROOTFS")
if ((ROOTFS_SIZE % 4096 != 0)); then
    ALIGNED_ROOTFS=$(mktemp /tmp/rootfs_aligned.XXXXXX.ext4)
    trap "rm -f '$ALIGNED_ROOTFS'" EXIT
    cp "$ROOTFS" "$ALIGNED_ROOTFS"
    truncate -s $(((ROOTFS_SIZE / 4096 + 1) * 4096)) "$ALIGNED_ROOTFS"
    sudo fastboot flash root "$ALIGNED_ROOTFS"
else
    sudo fastboot flash root "$ROOTFS"
fi

echo "Done."
