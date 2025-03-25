#!/bin/bash

if [ ! -d "build" ]; then
    echo "Error: The script must be run from the 'poky' directory."
    exit 1
fi

#check oe-init-build-env file
if [ ! -f "oe-init-build-env" ]; then
    echo "Error: The 'oe-init-build-env' file is missing! Make sure Yocto is installed."
    exit 1
fi

#initialize the Yocto build environment
source oe-init-build-env
if [ $? -ne 0 ]; then
    echo "Error: Failed to initialize the Yocto environment."
    exit 1
fi

#check if the image is built (it should be in tmp/deploy/images/qemuriscv64/)
if [ ! -f "tmp/deploy/images/qemuriscv64/core-image-minimal-qemuriscv64.ext4" ]; then
    echo "Error: Image not found! Run 'bitbake core-image-minimal' before starting the VM."
    exit 1
fi

#check if runqemu is available
if [ ! -x "$(command -v runqemu)" ]; then
    echo "Error: runqemu not found. Make sure Yocto is properly installed."
    exit 1
fi

#check if QEMU is already running
if pgrep -f qemu-system-riscv64 > /dev/null; then
    echo "Warning: QEMU is already running. The virtual machine might be active!"
    echo "Terminating the existing process..."
    pkill -f qemu-system-riscv64
    sleep 2
fi

#start the virtual machine
echo "Starting the RISC-V virtual machine..."
runqemu qemuriscv64 nographic
if [ $? -ne 0 ]; then
    echo "Error: Failed to start the virtual machine."
    exit 1
fi

