SUMMARY = "Cluster image for controller and worker deployment"
DESCRIPTION = "Minimal image with runtime dependencies for gRPC cluster services"

inherit core-image

IMAGE_FEATURES += "debug-tweaks ssh-server-openssh"

# Runtime dependencies for worker (DPDK linked statically, but these are needed dynamically)
IMAGE_INSTALL:append = " \
    libbpf \
    libxdp \
    numactl \
    elfutils \
    openssl \
    curl \
    sqlite3 \
"

# Networking and debug tools
IMAGE_INSTALL:append = " \
    iproute2 \
    net-tools \
    ethtool \
    strace \
"

# Extra rootfs space (1GB)
IMAGE_ROOTFS_EXTRA_SPACE = "1048576"

# SDK: strip debug and source packages to save space
SDKIMAGE_FEATURES = "dev-pkgs"

# SDK: include -dev packages in sysroot for Bazel cross-compilation
# Used by: bitbake -c populate_sdk cluster-image
TOOLCHAIN_TARGET_TASK:append = " \
    dpdk-dev \
    dpdk-staticdev \
    libbpf-dev \
    libxdp-dev \
    numactl-dev \
    openssl-dev \
    curl-dev \
    libsqlite3-dev \
    elfutils-dev \
    prometheus-cpp-dev \
"

