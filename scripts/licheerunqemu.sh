#!/bin/bash

qemu-system-riscv64 \
    -M virt \
    -smp 4 \
    -m 4G \
    -display none \
    -serial mon:stdio \
    -kernel built/Image \
    -drive file=built/licheepi4a-dpdk-image-licheepi4a.rootfs.ext4,format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -append "root=/dev/vda rw console=ttyS0 earlycon=sbi"
