#!/bin/sh

get_cmdline_param() {
    for param in $(cat /proc/cmdline); do
        case "$param" in
            "$1="*) echo "${param#*=}"; return ;;
        esac
    done
}

mkdir -p /mnt/shared
if mount -t 9p -o trans=virtio,cache=none host_share /mnt/shared 2>/dev/null; then
    echo "Mounted 9p shared directory"
else
    NFS_SERVER=$(get_cmdline_param nfs_server)
    if [ -n "$NFS_SERVER" ]; then
        mount -t nfs -o nolock,tcp "$NFS_SERVER" /mnt/shared
        echo "Mounted NFS from $NFS_SERVER"
    fi
fi

mkdir -p /dev/hugepages
mount -t hugetlbfs none /dev/hugepages 2>/dev/null || true
mkdir -p /sys/fs/bpf
mount -t bpf bpf /sys/fs/bpf 2>/dev/null || true

ip link set eth0 up 2>/dev/null || true
ip link set eth1 up 2>/dev/null || true

if [ -x /mnt/shared/setup-inet.sh ]; then
    /mnt/shared/setup-inet.sh
fi

ROLE=$(get_cmdline_param role)
LOGDIR="/mnt/shared/logs"
mkdir -p "$LOGDIR"

run_with_logs() {
    log_name="$1"
    shift
    log_file="$LOGDIR/${log_name}.log"
    script -qfc "$*" "$log_file"
}

case "$ROLE" in
    controller)
        if [ -f /mnt/shared/configs/controller.env ]; then
            set -a
            . /mnt/shared/configs/controller.env
            set +a
        fi
        cd /mnt/shared
        run_with_logs controller ./controller &
        ;;
    worker)
        (
            WORKER_ID=$(get_cmdline_param worker_id)
            export WORKER_ID
            if [ -f /mnt/shared/configs/worker.env ]; then
                set -a
                . /mnt/shared/configs/worker.env
                set +a
            fi
            CTRL_HOST=$(echo "$CONTROLLER_GRPC_ADDR" | cut -d: -f1)
            CTRL_PORT=$(echo "$CONTROLLER_GRPC_ADDR" | cut -d: -f2)
            echo "Waiting for controller at $CTRL_HOST:$CTRL_PORT..."
            while ! echo "" | nc "$CTRL_HOST" "$CTRL_PORT" 2>/dev/null; do
                sleep 2
            done
            echo "Controller is ready"
            mkdir -p /mnt/shared/worker${WORKER_ID}
            cd /mnt/shared/worker${WORKER_ID}
            run_with_logs "worker${WORKER_ID}" /mnt/shared/worker
        ) &
        ;;
esac
