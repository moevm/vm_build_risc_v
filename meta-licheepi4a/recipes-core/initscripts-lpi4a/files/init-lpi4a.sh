#!/bin/sh

echo 64 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
mkdir -p /dev/hugepages
mount -t hugetlbfs none /dev/hugepages

mkdir -p /sys/fs/bpf
mount -t bpf bpf /sys/fs/bpf

echo 1 > /proc/sys/net/core/bpf_jit_enable

ip link set eth0 up 2>/dev/null
ip link set eth1 up 2>/dev/null

ip tuntap add tap0 mode tap 2>/dev/null || true
ip link set tap0 up 2>/dev/null || true
