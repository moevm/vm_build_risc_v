SUMMARY = "RevyOS Linux Kernel for T-Head TH1520 (Lichee Pi 4A)"
DESCRIPTION = "Linux kernel 6.6 from RevyOS project, optimized for TH1520 SoC \
with full hardware support including WiFi, USB, GPU, Ethernet."
SECTION = "kernel"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

inherit kernel

DEPENDS += "dtc-native elfutils-native bc-native pahole-native"

BRANCH = "th1520-lts"
SRC_URI = "git://github.com/revyos/th1520-linux-kernel.git;protocol=https;branch=${BRANCH} \
           file://extra.cfg \
           file://dpdk.cfg \
           file://0001-stmmac-fix-ethtool-channels-for-single-queue-gmac.patch \
           "

SRCREV = "a092d55649279e1c9bcda2769b8f6b4370fa2c94"

S = "${WORKDIR}/git"

LINUX_VERSION ?= "6.6"
LINUX_VERSION_EXTENSION = "-th1520-revyos"
PV = "${LINUX_VERSION}+git"

KERNEL_IMAGETYPE = "Image.gz"

KERNEL_VERSION_SANITY_SKIP = "1"

do_configure() {
    oe_runmake -C ${S} O=${B} th1520_defconfig

    ${S}/scripts/kconfig/merge_config.sh -m -O ${B} ${B}/.config \
        ${WORKDIR}/extra.cfg \
        ${WORKDIR}/dpdk.cfg

    yes '' | oe_runmake -C ${S} O=${B} olddefconfig
}


do_deploy:append() {
    DTB_PATH="${B}/arch/riscv/boot/dts/thead/th1520-lichee-pi-4a-16g.dtb"
    bbnote "ITS NOTE ALL COMPLETED ITS NOTE ALL COMPLETED IT"
    if [ -f "${DTB_PATH}" ]; then
        install -m 0644 "${DTB_PATH}" "${DEPLOYDIR}/th1520-lichee-pi-4a-16g.dtb"
    else
        bbwarn "DTB not found at ${DTB_PATH}"
    fi
}

COMPATIBLE_MACHINE = "(licheepi4a)"
