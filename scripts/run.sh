#!/bin/bash

die() { echo "Error: $@" 1>&2; exit 1; }

[ -d build ] || die "The script must be started from the 'poky' directory."
[ -f oe-init-build-env ] || die "The 'oe-init-build-env' file is missing! Make sure Yocto is installed."

#initialize the Yocto build environment
source oe-init-build-env build > /dev/null 2>&1 || die "Failed to initialize the Yocto environment."

#check if the image is built
IMAGE_PATH="tmp/deploy/images/qemuriscv64/core-image-minimal-qemuriscv64.ext4"
[ -f "$IMAGE_PATH" ] || die "Image not found! Run 'bitbake core-image-minimal' before starting the VM."

#check if runqemu is available
command -v runqemu >/dev/null || die "runqemu not found. Make sure Yocto is properly installed."

#check if QEMU is already running
PIDS=$(pgrep -f qemu-system-riscv64)
if [ -n "$PIDS" ]; then
    echo "Warning: QEMU is already running. The virtual machine might be active!"
    echo "Terminating the existing process..."
    
    pkill -f qemu-system-riscv64

    for PID in $PIDS; do
        if command -v pidwait >/dev/null 2>&1; then
            pidwait $PID 2>/dev/null || wait $PID 2>/dev/null
        else
            wait $PID 2>/dev/null
        fi
    done
fi

#start the virtual machine
echo "Starting the RISC-V virtual machine with parameters: $@"
runqemu qemuriscv64 nographic qemuparams="$*" || die "Failed to start the virtual machine."
