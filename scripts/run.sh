#!/bin/bash

die() { echo "Error: $@" 1>&2; exit 1; }

USE_HOST_QEMU=false
VM_COUNT=3
PORTS_FILE="ports.conf"
VM_IMAGE_DIR="build/vm_images"
EXTRA_ARGS=()

#parse arguments
for arg in "$@"; do
    case $arg in
        --use-host-qemu)
            USE_HOST_QEMU=true
            shift
            ;;
        --vm-count=*)
            VM_COUNT="${arg#*=}"
            shift
            ;;
        *)
            EXTRA_ARGS+=("$arg")
            shift
            ;;
    esac
done

IMAGE_PATH="tmp/deploy/images/qemuriscv64/core-image-minimal-qemuriscv64.ext4"
KERNEL_IMAGE_PATH="tmp/deploy/images/qemuriscv64/Image"

[ -d build ] || die "The script must be started from the 'poky' directory."
[ -f "$PORTS_FILE" ] || die "Port config file '$PORTS_FILE' not found."

mapfile -t PORTS < "$PORTS_FILE"
[ "${#PORTS[@]}" -lt "$VM_COUNT" ] && die "Not enough ports in $PORTS_FILE for $VM_COUNT VMs."

if [ "$USE_HOST_QEMU" = true ]; then
    command -v qemu-system-riscv64 >/dev/null || die "Host QEMU not found!"
    QEMU_VERSION=$(
        qemu-system-riscv64 --version 2>/dev/null | grep -oP '([0-9]+)\.([0-9]+)' | head -n1
    )
    QEMU_MAJOR=$(echo "$QEMU_VERSION" | cut -d. -f1)
    QEMU_MINOR=$(echo "$QEMU_VERSION" | cut -d. -f2)
    [ "$QEMU_MAJOR" -lt 7 ] && die "QEMU version must be >= 7. Found: $QEMU_VERSION"

    cd build || die "Failed to enter build directory."

    [ -f "$KERNEL_IMAGE_PATH" ] || die "Kernel image not found: $KERNEL_IMAGE_PATH"
    
else
    [ -f oe-init-build-env ] || die "'oe-init-build-env' not found!"
    source oe-init-build-env build || die "Failed to source Yocto environment."
    command -v runqemu >/dev/null || die "runqemu not found."
fi

[ -f "$IMAGE_PATH" ] || die "Rootfs image not found! Run 'bitbake core-image-minimal' first."

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

mkdir -p "$VM_IMAGE_DIR"

#multiple VM
for ((i=0; i<VM_COUNT; i++)); do
    PORT=${PORTS[$i]}
    VM_ROOTFS="${VM_IMAGE_DIR}/rootfs_vm${i}.ext4"
    LOGFILE="vm_${i}.log"

    #copy rootfs
    if [ ! -f "$VM_ROOTFS" ]; then
        echo "Creating rootfs copy for VM $i..."
        cp "$IMAGE_PATH" "$VM_ROOTFS" || die "Failed to copy rootfs for VM $i"
    fi

    if [ "$USE_HOST_QEMU" = true ]; then
        echo "Launching VM $i on SSH port $PORT with host QEMU..."
        qemu-system-riscv64 \
            -machine virt \
            -nographic \
            -kernel "$KERNEL_IMAGE_PATH" \
            -append "root=/dev/vda rw console=ttyS0" \
            -drive file="$VM_ROOTFS",format=raw,id=hd0 \
            -device virtio-blk-device,drive=hd0 \
            -netdev user,id=net${i},hostfwd=tcp::"$PORT"-:22 \
            -device virtio-net-device,netdev=net${i} \
            "${EXTRA_ARGS[@]}" \
            > "$LOGFILE" 2>&1 &
    else
        echo "Launching VM $i on SSH port $PORT using runqemu..."
        runqemu qemuriscv64 nographic qemuparams="-drive file=${VM_ROOTFS},format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -netdev user,id=net${i},hostfwd=tcp::${PORT}-:22 -device virtio-net-device,netdev=net${i} ${EXTRA_ARGS[*]}" > "$LOGFILE" 2>&1 &
    fi
done

echo "All $VM_COUNT VMs started in background. Logs: vm_*.log"
