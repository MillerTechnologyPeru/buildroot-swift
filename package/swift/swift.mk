### Apple's Swift Programming Language
SWIFT_VERSION = 6.3.3
SWIFT_SITE = $(call github,swiftlang,swift,swift-$(SWIFT_VERSION)-RELEASE)
SWIFT_LICENSE = Apache-2.0
SWIFT_LICENSE_FILES = LICENSE.txt
SWIFT_TARGET_ARCH = $(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))
SWIFT_INSTALL_STAGING = YES
SWIFT_INSTALL_TARGET = YES
SWIFT_SUPPORTS_IN_SOURCE_BUILD = NO
SWIFT_BUILDDIR = $(SWIFT_SRCDIR)/build
SWIFT_DEPENDENCIES = host-swift host-cmake host-ninja icu libxml2 libbsd libedit zstd $(SWIFT_FTS_DEPENDENCIES)

HOST_SWIFT_BUILDDIR = $(HOST_SWIFT_SRCDIR)/build
SWIFT_NATIVE_PATH = $(HOST_SWIFT_BUILDDIR)/usr/bin
SWIFT_LLVM_DIR = $(HOST_SWIFT_BUILDDIR)/llvm
SWIFT_SOURCE_DIR = $(HOST_SWIFT_SRCDIR)/swift-source
SWIFT_STRING_PROCESSING_SRCDIR = $(SWIFT_SOURCE_DIR)/swift-experimental-string-processing
LIBDISPATCH_SRCDIR = $(SWIFT_SOURCE_DIR)/swift-corelibs-libdispatch

ifndef SWIFT_SOURCE_REPOS
$(error swift-sources.mk was not included before swift.mk)
endif

ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
SWIFT_CONF_ENV += LIBS="-latomic"
endif

# SWIFT_LIBC_NAME is the libc component of the target triple. It mirrors
# buildroot's own $(LIBC) (see package/Makefile.in) so the triple we hand to
# swiftc/clang matches the sysroot buildroot actually produced.
ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
SWIFT_LIBC_NAME = musl
else
SWIFT_LIBC_NAME = gnu
endif

# SWIFT_GCC_ALIAS_TRIPLE is the standard multiarch triple Clang recognises when
# scanning the sysroot for a GCC install (see SWIFT_INSTALL_STAGING_CMDS). It
# differs from $(GNU_TARGET_NAME), whose "swift" vendor Clang does not accept,
# and from $(SWIFT_TARGET_NAME), which for ARM keeps the armvN sub-arch while
# Clang normalises it to plain "arm".
ifeq ($(SWIFT_TARGET_ARCH),armv7)
SWIFT_TARGET_NAME		= armv7-unknown-linux-$(SWIFT_LIBC_NAME)eabihf
SWIFT_GCC_ALIAS_TRIPLE	= arm-linux-$(SWIFT_LIBC_NAME)eabihf
else ifeq ($(SWIFT_TARGET_ARCH),armv6)
SWIFT_TARGET_NAME		= armv6-unknown-linux-$(SWIFT_LIBC_NAME)eabihf
SWIFT_GCC_ALIAS_TRIPLE	= arm-linux-$(SWIFT_LIBC_NAME)eabihf
else ifeq ($(SWIFT_TARGET_ARCH),armv5)
SWIFT_TARGET_NAME		= armv5-unknown-linux-$(SWIFT_LIBC_NAME)eabi
SWIFT_GCC_ALIAS_TRIPLE	= arm-linux-$(SWIFT_LIBC_NAME)eabi
else
SWIFT_TARGET_NAME		= $(SWIFT_TARGET_ARCH)-unknown-linux-$(SWIFT_LIBC_NAME)
SWIFT_GCC_ALIAS_TRIPLE	= $(SWIFT_TARGET_ARCH)-linux-$(SWIFT_LIBC_NAME)
endif

# The Debian multiarch tuple, which Clang uses to locate the arch-specific C++
# headers (bits/c++config.h), as opposed to SWIFT_GCC_ALIAS_TRIPLE which names
# the GCC install itself. They match for every target except i686, whose install
# is i686-linux-gnu but whose multiarch tuple is i386-linux-gnu
# ("clang -print-multiarch").
SWIFT_GCC_MULTIARCH_TRIPLE = $(SWIFT_GCC_ALIAS_TRIPLE)
ifeq ($(SWIFT_TARGET_ARCH),i686)
SWIFT_GCC_MULTIARCH_TRIPLE = i386-linux-$(SWIFT_LIBC_NAME)
endif

ifeq ($(SWIFT_TARGET_ARCH),armv7)
SWIFT_EXTRA_FLAGS		= -mfloat-abi=$(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
SWIFTC_EXTRA_FLAGS		= -Xcc -mfloat-abi=$(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
else ifeq ($(SWIFT_TARGET_ARCH),armv6)
SWIFT_EXTRA_FLAGS		= -mfloat-abi=$(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
SWIFTC_EXTRA_FLAGS		= -Xcc -mfloat-abi=$(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
else ifeq ($(SWIFT_TARGET_ARCH),armv5)
SWIFT_EXTRA_FLAGS		= -march=armv5te
SWIFTC_EXTRA_FLAGS		= -Xcc -march=armv5te
else ifeq ($(SWIFT_TARGET_ARCH),riscv64)
SWIFT_EXTRA_FLAGS		= -mno-relax -mabi=$(call qstrip,$(BR2_GCC_TARGET_ABI))
SWIFTC_EXTRA_FLAGS		= -Xcc -mno-relax -Xcc -mabi=$(call qstrip,$(BR2_GCC_TARGET_ABI))
else ifneq ($(filter $(SWIFT_TARGET_ARCH),mips mipsel mips64 mips64el),)
SWIFT_EXTRA_FLAGS		= -msoft-float
SWIFTC_EXTRA_FLAGS		= -Xcc -msoft-float
else ifeq ($(SWIFT_TARGET_ARCH),powerpc)
SWIFT_EXTRA_FLAGS		= -mcpu=7400
SWIFTC_EXTRA_FLAGS		= -Xcc -mcpu=7400
else ifeq ($(SWIFT_TARGET_ARCH),powerpc64le)
SWIFT_EXTRA_FLAGS		= -DSWIFT_DTOA_PASS_FLOAT16_AS_FLOAT=1
SWIFTC_EXTRA_FLAGS		= -Xcc -DSWIFT_DTOA_PASS_FLOAT16_AS_FLOAT=1
else
SWIFT_EXTRA_FLAGS		= 
SWIFTC_EXTRA_FLAGS		= 
endif

SWIFT_GCC_VERSION = $(call qstrip,$(BR2_GCC_VERSION))

# CMAKE_SYSTEM_PROCESSOR value for the CMake-based Swift library packages
# (swift-system, swift-asn1, swift-crypto, ...). Their SwiftSupport.cmake
# whitelists uname-style processor names and hard-errors on anything else:
# armv7 must be spelled armv7l, armv6 armv6l, powerpc64le ppc64le. armv5 and
# the four mips variants have no entry at all, so the closest whitelisted value
# of the same width is used; the result only feeds the whitelist and install
# paths we do not use - every one of these packages stages its output by hand
# (see e.g. SWIFT_SYSTEM_INSTALL_STAGING_CMDS) rather than running the upstream
# install rules.
ifeq ($(SWIFT_TARGET_ARCH),armv7)
SWIFT_CMAKE_PROCESSOR = armv7l
else ifeq ($(SWIFT_TARGET_ARCH),armv6)
SWIFT_CMAKE_PROCESSOR = armv6l
else ifeq ($(SWIFT_TARGET_ARCH),armv5)
SWIFT_CMAKE_PROCESSOR = armv6l
else ifeq ($(SWIFT_TARGET_ARCH),powerpc64le)
SWIFT_CMAKE_PROCESSOR = ppc64le
else ifeq ($(SWIFT_TARGET_ARCH),powerpc)
SWIFT_CMAKE_PROCESSOR = ppc64
else ifneq ($(filter $(SWIFT_TARGET_ARCH),mips mipsel),)
SWIFT_CMAKE_PROCESSOR = i686
else ifneq ($(filter $(SWIFT_TARGET_ARCH),mips64 mips64el),)
SWIFT_CMAKE_PROCESSOR = ppc64
else
SWIFT_CMAKE_PROCESSOR = $(SWIFT_TARGET_ARCH)
endif

# Buildroot's target libstdc++ headers live in the host GCC toolchain,
# not in the staging sysroot
SWIFT_GCC_CXX_INCLUDE_DIR = $(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(SWIFT_GCC_VERSION)

# The Buildroot cross GCC install directory (holds libgcc and the crt objects).
# Swift/Clang locate the libstdc++ headers and C++ stdlib module map through
# Clang's C++ stdlib toolchain search, which needs a *detected* GCC installation
# -- plain -I flags are not consulted. --gcc-install-dir points Clang straight at
# this directory; unlike --gcc-toolchain it skips triple-alias matching, which
# would otherwise fail because the toolchain directory name ($(GNU_TARGET_NAME))
# carries the "swift" vendor while the target triple carries "unknown".
SWIFT_GCC_INSTALL_DIR = $(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(SWIFT_GCC_VERSION)

# Swift compile flags (CMake list) for the CxxStdlib overlay. The overlay's
# default is "-Xcc --gcc-toolchain=/usr", which resolves to the build machine's
# GCC instead of the Buildroot cross toolchain.
#
# -no-verify-emitted-module-interface: the overlay is built with library
# evolution, so the driver re-typechecks the emitted .swiftinterface. That
# verification re-invocation only sees the flags baked into the interface's
# swift-module-flags line, which strips the -Xcc paths above, so it cannot find
# the host-only libstdc++ headers (<chrono>) and fails. Real consumers get the
# paths from the SwiftPM toolchain file, so skip this internal self-check.
SWIFT_CXX_OVERLAY_FLAGS = -Xcc;--gcc-install-dir=$(SWIFT_GCC_INSTALL_DIR);-Xcc;-I$(SWIFT_GCC_CXX_INCLUDE_DIR);-Xcc;-I$(SWIFT_GCC_CXX_INCLUDE_DIR)/$(GNU_TARGET_NAME);-no-verify-emitted-module-interface

SWIFTC_FLAGS="-target $(SWIFT_TARGET_NAME) -use-ld=lld \
-resource-dir ${STAGING_DIR}/usr/lib/swift \
-Xclang-linker -B${STAGING_DIR}/usr/lib \
-Xclang-linker -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) \
-Xcc -I${STAGING_DIR}/usr/include \
-Xcc -I$(SWIFT_GCC_CXX_INCLUDE_DIR) \
-Xcc -I$(SWIFT_GCC_CXX_INCLUDE_DIR)/$(GNU_TARGET_NAME) \
$(SWIFTC_EXTRA_FLAGS) \
-L${STAGING_DIR}/lib \
-L${STAGING_DIR}/usr/lib \
-L${STAGING_DIR}/usr/lib/swift \
-L${STAGING_DIR}/usr/lib/swift/$(SWIFT_LIB_SUBDIR) \
-L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) \
$(SWIFT_FTS_LIBS) \
-sdk ${STAGING_DIR} \
"

SWIFT_CONF_OPTS = \
	-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
    -DCMAKE_CXX_COMPILER=$(SWIFT_NATIVE_PATH)/clang++ \
    -DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot $(STAGING_DIR) -latomic $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(STAGING_DIR)/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
    -DCMAKE_CXX_FLAGS="-w -Wno-invalid-constexpr -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot $(STAGING_DIR) -latomic $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(STAGING_DIR)/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/ -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME)" \
    -DCMAKE_C_LINK_FLAGS="--sysroot $(STAGING_DIR) -latomic $(SWIFT_EXTRA_FLAGS)" \
    -DCMAKE_CXX_LINK_FLAGS="--sysroot $(STAGING_DIR) -latomic $(SWIFT_EXTRA_FLAGS)" \
	-DCMAKE_Swift_COMPILER=$(SWIFT_NATIVE_PATH)/swiftc \
	-DSWIFT_USE_LINKER=lld \
    -DLLVM_USE_LINKER=lld \
    -DLLVM_DIR=${SWIFT_LLVM_DIR}/lib/cmake/llvm \
    -DLLVM_BUILD_LIBRARY_DIR=${SWIFT_LLVM_DIR} \
    -DSWIFT_BUILD_RUNTIME_WITH_HOST_COMPILER=ON \
    -DSWIFT_NATIVE_CLANG_TOOLS_PATH=${SWIFT_NATIVE_PATH} \
    -DSWIFT_NATIVE_SWIFT_TOOLS_PATH=${SWIFT_NATIVE_PATH} \
    -DSWIFT_BUILD_DYNAMIC_SDK_OVERLAY=ON \
    -DSWIFT_BUILD_DYNAMIC_STDLIB=ON \
    -DSWIFT_BUILD_REMOTE_MIRROR=OFF \
    -DSWIFT_BUILD_SOURCEKIT=OFF \
    -DSWIFT_BUILD_STDLIB_EXTRA_TOOLCHAIN_CONTENT=OFF \
    -DSWIFT_ENABLE_SOURCEKIT_TESTS=OFF \
    -DSWIFT_INCLUDE_DOCS=OFF \
    -DSWIFT_INCLUDE_TOOLS=OFF \
    -DSWIFT_HOST_VARIANT_ARCH=${SWIFT_TARGET_ARCH} \
    -DSWIFT_SDKS=LINUX \
    -DSWIFT_SDK_LINUX_ARCH_${SWIFT_TARGET_ARCH}_PATH=${STAGING_DIR}  \
    -DSWIFT_SDK_LINUX_ARCH_${SWIFT_TARGET_ARCH}_TRIPLE=$(SWIFT_TARGET_NAME) \
    -DSWIFT_SDK_LINUX_LIB_SUBDIR_OVERRIDE=$(SWIFT_LIB_SUBDIR) \
    -DSWIFT_PATH_TO_LIBDISPATCH_SOURCE=${LIBDISPATCH_SRCDIR} \
    -DSWIFT_ENABLE_EXPERIMENTAL_CONCURRENCY=ON \
	-DSWIFT_ENABLE_EXPERIMENTAL_STRING_PROCESSING=ON \
	-DSWIFT_PATH_TO_STRING_PROCESSING_SOURCE=${SWIFT_STRING_PROCESSING_SRCDIR} \
	-DSWIFT_ENABLE_EXPERIMENTAL_CXX_INTEROP=ON \
	-DSWIFT_ENABLE_CXX_INTEROP_SWIFT_BRIDGING_HEADER=ON \
	-DSWIFT_BUILD_STDLIB_CXX_MODULE=ON \
	-DSWIFT_SDK_LINUX_CXX_OVERLAY_SWIFT_COMPILE_FLAGS="$(SWIFT_CXX_OVERLAY_FLAGS)" \
	-DSWIFT_ENABLE_VOLATILE=ON \
	-DSWIFT_ENABLE_EXPERIMENTAL_DIFFERENTIABLE_PROGRAMMING=ON \
    -DSWIFT_ENABLE_EXPERIMENTAL_DISTRIBUTED=ON \
    -DSWIFT_ENABLE_EXPERIMENTAL_NONESCAPABLE_TYPES=ON \
	-DSWIFT_ENABLE_EXPERIMENTAL_OBSERVATION=ON \
    -DSWIFT_ENABLE_SYNCHRONIZATION=ON \
	-DSWIFT_INCLUDE_TESTS=OFF \
	-DSWIFT_INCLUDE_TEST_BINARIES=OFF \
    -DSWIFT_BUILD_TEST_SUPPORT_MODULES=OFF \
	-DZLIB_LIBRARY=$(STAGING_DIR)/usr/lib/libz.so \
	-DSWIFT_SHOULD_BUILD_EMBEDDED_STDLIB=FALSE \
	-DSWIFT_STDLIB_BUILD_PRIVATE=FALSE \

# The overridable retain/release fast path uses indirect musttail calls,
# which clang cannot generate on these targets
ifneq ($(filter $(SWIFT_TARGET_ARCH),powerpc powerpc64le mips mipsel mips64 mips64el),)
SWIFT_CONF_OPTS += -DSWIFT_STDLIB_OVERRIDABLE_RETAIN_RELEASE=FALSE
endif

# The CMake build below invokes the native clang/clang++ from host-swift
# directly (see SWIFT_CONFIGURE_CMDS), bypassing buildroot's toolchain
# wrapper, so BR2_CCACHE's automatic HOSTCC/TARGET_CC wrapping never sees it.
# Wire the compiler launcher in explicitly when BR2_CCACHE is enabled.
ifeq ($(BR2_CCACHE),y)
SWIFT_CONF_OPTS += \
	-DCMAKE_C_COMPILER_LAUNCHER=$(CCACHE) \
	-DCMAKE_CXX_COMPILER_LAUNCHER=$(CCACHE)
endif

ifneq ($(filter $(SWIFT_TARGET_ARCH),armv7 armv6 armv5 riscv64 mips mipsel mips64 mips64el powerpc),)
SWIFT_CONF_OPTS	+= \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

endif

define SWIFT_CONFIGURE_CMDS
	# Configure for Ninja
	(mkdir -p $(SWIFT_BUILDDIR) && \
	cd $(SWIFT_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_CONF_ENV) $(BR2_CMAKE) -S $(SWIFT_SRCDIR) -B $(SWIFT_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="$(STAGING_DIR)/usr" \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
        $(SWIFT_CONF_OPTS) \
	)
endef

define SWIFT_BUILD_CMDS
	# Compile
	(cd $(SWIFT_BUILDDIR) && ninja)
endef

define SWIFT_INSTALL_TARGET_CMDS
	cp -f $(SWIFT_BUILDDIR)/lib/swift/$(SWIFT_LIB_SUBDIR)/*.so $(TARGET_DIR)/usr/lib
endef

define SWIFT_INSTALL_STAGING_CMDS
	# Copy runtime libraries and Swift interfaces
	(cd $(SWIFT_BUILDDIR) && ninja install)
	# Make the host libstdc++ discoverable from the SDK sysroot. Consumers of the
	# CxxStdlib module rebuild it from its textual .swiftinterface, and that
	# rebuild does NOT inherit the toolchain file's -Xcc --gcc-install-dir / -I
	# flags -- it only sees the SDK sysroot. Clang finds libstdc++ there by
	# scanning <sysroot>/usr/lib/gcc/<triple> for a GCC install and deriving the
	# C++ header paths relative to it. Requirements learned the hard way:
	#   * the <triple> dir must use a standard alias ($(SWIFT_GCC_ALIAS_TRIPLE));
	#     Clang rejects the "swift" vendor in $(GNU_TARGET_NAME).
	#   * that dir must be a *real* directory (only its contents symlinked); if it
	#     is itself a symlink Clang resolves it and mis-derives the ../include/c++
	#     paths, landing outside the sysroot.
	mkdir -p $(STAGING_DIR)/usr/lib/gcc/$(SWIFT_GCC_ALIAS_TRIPLE)/$(SWIFT_GCC_VERSION)
	for f in $(SWIFT_GCC_INSTALL_DIR)/*; do \
		ln -sf $$f $(STAGING_DIR)/usr/lib/gcc/$(SWIFT_GCC_ALIAS_TRIPLE)/$(SWIFT_GCC_VERSION)/; \
	done
	# Base C++ headers (<vector>, <chrono>, ...) at <sysroot>/usr/include/c++/<ver>
	mkdir -p $(STAGING_DIR)/usr/include/c++
	ln -sfn $(SWIFT_GCC_CXX_INCLUDE_DIR) \
		$(STAGING_DIR)/usr/include/c++/$(SWIFT_GCC_VERSION)
	# Arch-specific bits (bits/c++config.h) at the multiarch location Clang probes
	mkdir -p $(STAGING_DIR)/usr/include/$(SWIFT_GCC_MULTIARCH_TRIPLE)/c++
	ln -sfn $(SWIFT_GCC_CXX_INCLUDE_DIR)/$(GNU_TARGET_NAME) \
		$(STAGING_DIR)/usr/include/$(SWIFT_GCC_MULTIARCH_TRIPLE)/c++/$(SWIFT_GCC_VERSION)
endef

HOST_SWIFT_SUPPORT_DIR = $(HOST_DIR)/usr/share/swift
SWIFT_DESTINATION_FILE = $(HOST_SWIFT_SUPPORT_DIR)/toolchain.json

# swift's build-script builds the toolchain out of a "swift-source" directory
# holding the swift sources next to every peer repository of the release, the
# layout update-checkout produces. Rather than cloning them when the package
# configures, fetch one GitHub archive per repository as an extra download, so
# that buildroot downloads and hash-checks them along with everything else and
# "make source" really does fetch everything the build needs. The revisions
# live in swift-sources.mk; see utils/gen-swift-source-pins.py for where they
# come from and how to regenerate them.
HOST_SWIFT_EXTRA_DOWNLOADS = \
	$(foreach repo,$(SWIFT_SOURCE_REPOS),$(call swift-repo-url,$(repo)))

# Lay out swift-source from the archives. Extra downloads are only fetched,
# never extracted, so unpack them here; buildroot has already checked them
# against swift.hash by this point.
#
# swift-source/swift is a symlink back to the package's own sources rather
# than a copy, so that the swift tree build-script compiles is the one
# buildroot extracted and patched, and the patches in this directory keep
# applying through the normal patch step.
#
# Each archive is unpacked into a temporary directory that is renamed only
# once it has been unpacked in full, for the same reason the checkout this
# replaces did so: the per-repository test treats the presence of a directory
# as "already unpacked", so an interrupted extraction left behind would be
# skipped by every later run and the toolchain would be built against a
# truncated repository - the failure that took five hours to surface as an
# API mismatch in swiftpm. That test is also what lets a tree that already
# carries a repository keep it, which is how the devcontainer images supply a
# prebuilt toolchain.
define HOST_SWIFT_EXTRACT_SWIFT_SOURCE
	mkdir -p $(SWIFT_SOURCE_DIR)
	$(foreach repo,$(SWIFT_SOURCE_REPOS), \
		if [ ! -d $(SWIFT_SOURCE_DIR)/$(call swift-repo-dir,$(repo)) ]; then \
			rm -rf $(SWIFT_SOURCE_DIR)/$(call swift-repo-dir,$(repo)).tmp \
			&& mkdir -p $(SWIFT_SOURCE_DIR)/$(call swift-repo-dir,$(repo)).tmp \
			&& $(call suitable-extractor,$(call swift-repo-file,$(repo))) \
				$(HOST_SWIFT_DL_DIR)/$(call swift-repo-file,$(repo)) | \
			$(TAR) --strip-components=1 \
				-C $(SWIFT_SOURCE_DIR)/$(call swift-repo-dir,$(repo)).tmp \
				$(TAR_OPTIONS) - \
			&& mv $(SWIFT_SOURCE_DIR)/$(call swift-repo-dir,$(repo)).tmp \
				$(SWIFT_SOURCE_DIR)/$(call swift-repo-dir,$(repo)); \
		fi
	$(sep))
	ln -sfn .. $(SWIFT_SOURCE_DIR)/swift
endef
HOST_SWIFT_POST_EXTRACT_HOOKS += HOST_SWIFT_EXTRACT_SWIFT_SOURCE

# Patch the peer repositories with the same infrastructure buildroot uses for
# the package itself. swift-source-patches/<repository>/ does not match the
# *.patch pattern the patch step scans this directory with, so these are not
# also applied to the swift sources.
define HOST_SWIFT_PATCH_SWIFT_SOURCE
	$(foreach dir,$(sort $(wildcard $(HOST_SWIFT_PKGDIR)/swift-source-patches/*)), \
		$(APPLY_PATCHES) $(SWIFT_SOURCE_DIR)/$(notdir $(dir)) $(dir) \*.patch
	$(sep))
endef
HOST_SWIFT_POST_PATCH_HOOKS += HOST_SWIFT_PATCH_SWIFT_SOURCE

define HOST_SWIFT_BUILD_CMDS
	# Build
	#
	# The symlink is chained onto the build with && rather than following it as
	# a separate statement: the if-block reports the status of its last command,
	# so with a ";" a failed build-script was discarded and the recipe
	# succeeded. Buildroot then installed an incomplete toolchain and carried
	# on, and the missing swiftc only surfaced hours later, when the target
	# swift package configured against it and reported
	#
	#   CMAKE_Swift_COMPILER: .../host-swift-<ver>/build/usr/bin/swiftc
	#   is not a full path to an existing compiler tool
	#
	# which says nothing about the build that actually failed.
	#
	# build-script otherwise works out both the source root and the name of the
	# directory holding the swift sources from the path of its own file, and
	# that path is resolved, so through the swift-source/swift symlink it
	# arrives at the package directory: it would look for the sources of every
	# product under swift-source/host-swift-$(SWIFT_VERSION) and stop at
	#
	#   ERROR: unable to parse files: [...build-presets.ini, FileNotFoundError]
	#
	# Both are meant to be overridden, so name them rather than relying on the
	# layout being inferred correctly.
	@if [ ! -d "$(SWIFT_LLVM_DIR)" ]; then \
		(cd $(SWIFT_SOURCE_DIR) \
			&& SWIFT_SOURCE_ROOT=$(SWIFT_SOURCE_DIR) SWIFT_REPO_NAME=swift \
			$(SWIFT_SOURCE_DIR)/swift/utils/build-script \
			--preset=buildbot_linux,no_test \
			install_destdir=$(HOST_SWIFT_BUILDDIR) \
			installable_package=$(HOST_SWIFT_BUILDDIR)/swift.tar.gz) \
		&& ln -s $(SWIFT_SOURCE_DIR)/build/buildbot_linux/llvm-linux-$(shell uname -m) $(SWIFT_LLVM_DIR); \
	fi
endef

define HOST_SWIFT_INSTALL_CMDS
	# Create Swift support directory
	mkdir -p $(HOST_SWIFT_SUPPORT_DIR)
	# Generate SwiftPM cross compilation toolchain file
	rm -f $(SWIFT_DESTINATION_FILE)
	touch $(SWIFT_DESTINATION_FILE)
	echo '{' >> $(SWIFT_DESTINATION_FILE)
	echo '   "version":1,' >> $(SWIFT_DESTINATION_FILE)
	echo '   "sdk":"$(STAGING_DIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '   "toolchain-bin-dir":"$(SWIFT_NATIVE_PATH)",' >> $(SWIFT_DESTINATION_FILE)
	echo '   "target":"$(SWIFT_TARGET_NAME)",' >> $(SWIFT_DESTINATION_FILE)
	echo '   "dynamic-library-extension":"so",' >> $(SWIFT_DESTINATION_FILE)
	echo '   "extra-cc-flags":[' >> $(SWIFT_DESTINATION_FILE)
	echo '      "--gcc-install-dir=$(SWIFT_GCC_INSTALL_DIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-I$(SWIFT_GCC_CXX_INCLUDE_DIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-I$(SWIFT_GCC_CXX_INCLUDE_DIR)/$(GNU_TARGET_NAME)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-fPIC",' >> $(SWIFT_DESTINATION_FILE)

	@if [ "$(SWIFT_TARGET_ARCH)" = "armv5" ]; then\
		echo '      "-march=armv5te",' >> $(SWIFT_DESTINATION_FILE);\
    fi

	@case "$(SWIFT_TARGET_ARCH)" in mips|mipsel|mips64|mips64el)\
		echo '      "-msoft-float",' >> $(SWIFT_DESTINATION_FILE);;\
    esac

	echo '   ],' >> $(SWIFT_DESTINATION_FILE)
	echo '   "extra-swiftc-flags":[' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-target", "$(SWIFT_TARGET_NAME)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-use-ld=lld",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-tools-directory", "$(SWIFT_NATIVE_PATH)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-rpath", "-Xlinker", "/usr/lib/swift/$(SWIFT_LIB_SUBDIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/lib",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib/swift/$(SWIFT_LIB_SUBDIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib/swift/$(SWIFT_LIB_SUBDIR)/$(SWIFT_TARGET_ARCH)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "--build-id=sha1",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-I$(STAGING_DIR)/usr/include",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-I$(STAGING_DIR)/usr/lib/swift",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xcc", "--gcc-install-dir=$(SWIFT_GCC_INSTALL_DIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xcc", "-I$(SWIFT_GCC_CXX_INCLUDE_DIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xcc", "-I$(SWIFT_GCC_CXX_INCLUDE_DIR)/$(GNU_TARGET_NAME)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-resource-dir", "$(STAGING_DIR)/usr/lib/swift",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xclang-linker", "-B$(STAGING_DIR)/usr/lib",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xclang-linker", "-B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xclang-linker", "-latomic",' >> $(SWIFT_DESTINATION_FILE);\

	@if [ "$(SWIFT_TARGET_ARCH)" = "powerpc" ]; then\
		echo '      "-Xcc", "-mcpu=7400",' >> $(SWIFT_DESTINATION_FILE);\
    fi

	@if [ "$(SWIFT_TARGET_ARCH)" = "armv5" ]; then\
		echo '      "-Xcc", "-march=armv5te",' >> $(SWIFT_DESTINATION_FILE);\
    fi

	@if [ "$(SWIFT_TARGET_ARCH)" = "armv6" ]; then\
		echo '      "-Xcc", "-mfloat-abi=$(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))",' >> $(SWIFT_DESTINATION_FILE);\
    fi

	@if [ "$(SWIFT_TARGET_ARCH)" = "riscv64" ]; then\
		echo '      "-Xcc", "-mno-relax",' >> $(SWIFT_DESTINATION_FILE);\
		echo '      "-Xcc", "-mabi=$(call qstrip,$(BR2_GCC_TARGET_ABI))",' >> $(SWIFT_DESTINATION_FILE);\
    fi

	@case "$(SWIFT_TARGET_ARCH)" in mips|mipsel|mips64|mips64el)\
		echo '      "-Xcc", "-msoft-float",' >> $(SWIFT_DESTINATION_FILE);;\
    esac

	# Foundation calls fts(3), which lives in musl-fts rather than musl itself
	@if [ "$(BR2_TOOLCHAIN_USES_MUSL)" = "y" ]; then\
		echo '      "-lfts",' >> $(SWIFT_DESTINATION_FILE);\
    fi

	echo '      "-sdk", "$(STAGING_DIR)"' >> $(SWIFT_DESTINATION_FILE)
	echo '   ],' >> $(SWIFT_DESTINATION_FILE)
	echo '   "extra-cpp-flags":[' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-lstdc++"' >> $(SWIFT_DESTINATION_FILE)
	echo '   ]' >> $(SWIFT_DESTINATION_FILE)
	echo '}' >> $(SWIFT_DESTINATION_FILE)
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
