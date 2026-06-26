FILESEXTRAPATHS:prepend := "${THISDIR}/linux-yocto:"
SRC_URI += "file://xdp.cfg"
DEPENDS += "pahole-native"
KERNEL_DEBUG = "True"
