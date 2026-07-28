# Disable libunwind dependency - libunwind 1.6.2 does not build on RISC-V
DEPENDS:remove = "libunwind"
EXTRA_OEMAKE += "NO_LIBUNWIND=1 NO_LIBNUMA=1"
RDEPENDS:${PN}:remove = "libunwind"

# Fix cpumap.c malloc alloc-size warning treated as error on RISC-V
EXTRA_OEMAKE += "EXTRA_CFLAGS='${CFLAGS} -Wno-error=alloc-size-larger-than='"
