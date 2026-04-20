#!/bin/sh

mkdir -p /mnt/shared
mount -t 9p -o trans=virtio host_share /mnt/shared 2>/dev/null || true

mkdir -p /dev/hugepages
mount -t hugetlbfs none /dev/hugepages 2>/dev/null || true

ip link set eth0 up 2>/dev/null || true
ip link set eth1 up 2>/dev/null || true
