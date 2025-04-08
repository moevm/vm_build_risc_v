#!/bin/bash

die() { echo "Error: $@" 1>&2; exit 1; }

USE_HOST_QEMU=false

#parse arguments
for arg in "$@"; do
    case $arg in
        --use-host-qemu)
            USE_HOST_QEMU=true
            shift
            ;;
    esac
done

IMAGE_PATH="tmp/deploy/images/qemuriscv64/core-image-minimal-qemuriscv64.ext4"
KERNEL_IMAGE_PATH="tmp/deploy/images/qemuriscv64/Image"

[ -d build ] || die "The script must be started from the 'poky' directory."

if [ "$USE_HOST_QEMU" = true ]; then
    # --- Host QEMU mode ---
    command -v qemu-system-riscv64 >/dev/null || die "Host QEMU not found!"
    
    QEMU_VERSION=$(
        qemu-system-riscv64 --version 2>/dev/null | grep -oP '([0-9]+)\.([0-9]+)' | head -n1
    )
    QEMU_MAJOR=$(echo "$QEMU_VERSION" | cut -d. -f1)
    QEMU_MINOR=$(echo "$QEMU_VERSION" | cut -d. -f2)
    [ "$QEMU_MAJOR" -lt 7 ] && die "QEMU version must be >= 7. Found: $QEMU_VERSION"
    
    [ -d build ] || die "The 'build' directory is missing!"
    cd build
    
    [ -f "$KERNEL_IMAGE_PATH" ] || die "Kernel image not found! Expected: $KERNEL_IMAGE_PATH"
    [ -f "$IMAGE_PATH" ] || die "Rootfs image not found! Run 'bitbake core-image-minimal' first."

    export QEMU_BINARY="qemu-system-riscv64"
else
    # --- Yocto QEMU mode ---
    [ -f oe-init-build-env ] || die "'The 'oe-init-build-env' file is missing! Make sure Yocto is installed"
    source oe-init-build-env build || die "Failed to initialize the Yocto environment."
    
    [ -f "$IMAGE_PATH" ] || die "Image not found! Run 'bitbake core-image-minimal' before starting the VM."

    #check if runqemu is available
    command -v runqemu >/dev/null || die "runqemu not found. Make sure Yocto is properly installed."
fi

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
if [ "$USE_HOST_QEMU" = true ]; then
    echo "Starting VM with host QEMU..."
    
    qemu-system-riscv64 \
        -machine virt \
        -nographic \
        -kernel "$KERNEL_IMAGE_PATH" \
        -append "root=/dev/vda rw console=ttyS0" \
        -drive file="$IMAGE_PATH",format=raw,id=hd0 \
        -device virtio-blk-device,drive=hd0 \
        -netdev user,id=net0 -device virtio-net-device,netdev=net0 \
        "$@" || die "Failed to start the VM with host QEMU."
else
    echo "Starting VM using Yocto's runqemu..."
    runqemu qemuriscv64 nographic qemuparams="$*" || die "Failed to start the VM with Yocto's runqemu."
fi
