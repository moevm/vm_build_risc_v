#!/bin/sh

WORKDIR=/opt/traffic-filtering

setup_hugepages() {
    echo 64 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
    mkdir -p /dev/hugepages
    mount -t hugetlbfs none /dev/hugepages
}

setup_bpf() {
    mkdir -p /sys/fs/bpf
    mount -t bpf bpf /sys/fs/bpf
    echo 1 >/proc/sys/net/core/bpf_jit_enable
}

setup_ip() {
    ip addr add 10.0.0.1/24 dev eth0
    ip addr add 10.0.1.1/24 dev eth1
    ip link set eth0 up
    ip link set eth1 up
    sysctl -w net.ipv4.ip_forward=1
}

setup_environment() {
    ENVDIR="$WORKDIR/internal/service/config"
    cat "$ENVDIR/worker.env" "$ENVDIR/controller.env" > /etc/environment
}

setup_hugepages
setup_bpf
setup_ip
setup_environment
