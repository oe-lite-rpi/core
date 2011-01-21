DESCRIPTION = "Generic library support script \
This is GNU libtool, a generic library support script.  Libtool hides \
the complexity of generating special library types (such as shared \
libraries) behind a consistent interface."
HOMEPAGE = "http://www.gnu.org/software/libtool/libtool.html"
LICENSE = "GPL"

BBCLASSEXTEND = "native cross sdk-cross"

require conf/fetch/gnu.conf
SRC_URI = "${GNU_MIRROR}/libtool/libtool-${PV}.tar.gz"

inherit autotools

LIBTOOL_DEPENDS_recipe-native		= ""
LIBTOOL_DEPENDS_recipe-cross		= "${BUILD_ARCH}/libtool"
LIBTOOL_DEPENDS_recipe-sdk-cross	= "${BUILD_ARCH}/libtool"

SYSROOT_PACKAGES = "\
	${PN}-sysroot-libltdl \
	${PN}-sysroot-libltdl-dev \
	${PN}-sysroot-libltdl-dbg \
"
PACKAGES_append_recipe-native += "${SYSROOT_PACKAGES}"

CROSS_PROVIDES			= "${TARGET_ARCH}/libtool"
CROSS_PROVIDES_recipe-machine	= ""
PROVIDES_${PN}			+= "${CROSS_PROVIDES}"

SYSROOT_DEPENDS = "${TARGET_ARCH}/sysroot-libgcc"
SYSROOT_DEPENDS_recipe-native = ""
DEPENDS += "${SYSROOT_DEPENDS}"

DEPENDS_${PN}-sysroot-libltdl-dev	= "${PN}-sysroot-libltdl"
DEPENDS_${PN}-sysroot-libltdl-dbg	= "${PN}-sysroot-libltdl"

FILES_${PN}	= "\
${base_bindir}/* ${base_sbindir}/* \
${bindir}/* ${sbindir}/* \
${sysconfdir} ${sharedstatedir} ${localstatedir} \
${datadir}/${BPN} ${datadir}/aclocal \
"
FILES_${PN}-sysroot-libltdl = "${libdir}/libltdl.so.*"
FILES_${PN}-sysroot-libltdl-dev = "${libdir}/libltdl.* ${includedir}/ltdl.h"
FILES_${PN}-sysroot-libltdl-dbg = "${libdir}/.debug/"

EXTRA_OECONF_PROGRAM_PREFIX = ""
EXTRA_OECONF_PROGRAM_PREFIX_recipe-native += "--program-prefix=${TARGET_PREFIX}"
EXTRA_OECONF_PROGRAM_PREFIX_recipe-cross += "--program-prefix=${TARGET_PREFIX}"
EXTRA_OECONF_PROGRAM_PREFIX_recipe-sdk-cross += "--program-prefix=${TARGET_PREFIX}"
EXTRA_OECONF_PROGRAM_PREFIX_recipe-canadian-cross += "--program-prefix=${TARGET_PREFIX}"
EXTRA_OECONF += "${EXTRA_OECONF_PROGRAM_PREFIX}"

# When cross compiling libtool, we need to lie a bit, telling
# configure that host=target
HOST_ARCH_recipe-cross			= "${TARGET_ARCH}"
HOST_FPU_recipe-cross			= "${TARGET_FPU}"
HOST_EXEEXT_recipe-cross		= "${TARGET_EXEEXT}"
HOST_PREFIX_recipe-cross		= "${TARGET_PREFIX}"
HOST_CPPFLAGS_recipe-cross		= "${TARGET_CPPFLAGS}"
HOST_OPTIMIZATION_recipe-cross		= "${TARGET_OPTIMIZATION}"
HOST_CFLAGS_recipe-cross		= "${TARGET_CFLAGS}"
HOST_CXXFLAGS_recipe-cross		= "${TARGET_CXXFLAGS}"
HOST_LDFLAGS_recipe-cross		= "${TARGET_LDFLAGS}"
HOST_ARCH_recipe-sdk-cross		= "${TARGET_ARCH}"
HOST_FPU_recipe-sdk-cross		= "${TARGET_FPU}"
HOST_EXEEXT_recipe-sdk-cross		= "${TARGET_EXEEXT}"
HOST_PREFIX_recipe-sdk-cross		= "${TARGET_PREFIX}"
HOST_CPPFLAGS_recipe-sdk-cross		= "${TARGET_CPPFLAGS}"
HOST_OPTIMIZATION_recipe-sdk-cross	= "${TARGET_OPTIMIZATION}"
HOST_CFLAGS_recipe-sdk-cross		= "${TARGET_CFLAGS}"
HOST_CXXFLAGS_recipe-sdk-cross		= "${TARGET_CXXFLAGS}"
HOST_LDFLAGS_recipe-sdk-cross		= "${TARGET_LDFLAGS}"

do_install_append () {
    ln -sf ../../aclocal ${D}${datadir}/libtool/libltdl/m4
    ln -sf ../config ${D}${datadir}/libtool/libltdl/config
}