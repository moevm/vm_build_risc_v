SUMMARY = "RevyOS Linux Kernel for T-Head TH1520 (Lichee Pi 4A)"
DESCRIPTION = "Linux kernel 6.6 from RevyOS project, optimized for TH1520 SoC \
with full hardware support including WiFi, USB, GPU, Ethernet."
SECTION = "kernel"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

inherit kernel kernel-yocto

DEPENDS += "dtc-native elfutils-native"

BRANCH = "th1520-lts"
SRC_URI = "git://github.com/revyos/th1520-linux-kernel.git;protocol=https;branch=${BRANCH} \
           file://dpdk.cfg;type=kmeta;name=dpdk \
           file://extra.cfg;type=kmeta;name=extra \
           file://fix-hall-mh248.patch \
           "

SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

LINUX_VERSION ?= "6.6"
LINUX_VERSION_EXTENSION = "-th1520-revyos"
PV = "${LINUX_VERSION}+git"

KERNEL_VERSION_SANITY_SKIP = "1"

KBUILD_DEFCONFIG = "th1520_defconfig"

do_configure:prepend() {
    if ! grep -q "CONFIG_ARCH_XUANTIE" ${B}/.config 2>/dev/null; then
        echo "CONFIG_ARCH_XUANTIE=y" >> ${WORKDIR}/extra.cfg
    fi
}

do_configure:append() {
    echo "CONFIG_GENERIC_CPU_VULNERABILITIES=y" >> ${B}/.config
    echo "CONFIG_RISCV_ISA_VENDOR_EXT_THEAD=y" >> ${B}/.config
    echo "CONFIG_RISCV_ISA_V=y" >> ${B}/.config
    echo "CONFIG_FPU=y" >> ${B}/.config
    echo "CONFIG_RISCV_ISA_XTHEADVECTOR=y" >> ${B}/.config
    echo "CONFIG_DEVFREQ_THERMAL=y" >> ${B}/.config
    echo "CONFIG_INPUT=y" >> ${B}/.config
    echo "CONFIG_ERRATA_THEAD=y" >> ${B}/.config
    echo "CONFIG_ERRATA_THEAD_GHOSTWRITE=y" >> ${B}/.config
    echo "# CONFIG_DEBUG_INFO_BTF is not set" >> ${B}/.config
    echo "CONFIG_DRM_IMG_ROGUE_GPUTRACE=n" >> ${B}/.config
    echo "CONFIG_DRM_POWERVR_ROGUE=n" >> ${B}/.config
    yes '' | make -C ${S} O=${B} olddefconfig
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
