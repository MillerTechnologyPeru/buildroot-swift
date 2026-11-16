### Foundation
SWIFT_FOUNDATION_VERSION = 6.4.2
SWIFT_FOUNDATION_SITE = $(call github,swiftlang,swift-corelibs-foundation,swift-$(SWIFT_FOUNDATION_VERSION)-RELEASE)
SWIFT_FOUNDATION_LICENSE = Apache-2.0
SWIFT_FOUNDATION_LICENSE_FILES = LICENSE
SWIFT_FOUNDATION_INSTALL_STAGING = YES
SWIFT_FOUNDATION_INSTALL_TARGET = YES
SWIFT_FOUNDATION_SUPPORTS_IN_SOURCE_BUILD = NO
SWIFT_FOUNDATION_DEPENDENCIES = icu libxml2 libcurl swift libswiftdispatch $(SWIFT_FTS_DEPENDENCIES)

SWIFT_FOUNDATION_CONF_OPTS += \
    -DCMAKE_Swift_FLAGS=${SWIFTC_FLAGS} \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \
    -Ddispatch_DIR="$(LIBSWIFTDISPATCH_BUILDDIR)/cmake/modules" \
	-DCURL_LIBRARY_RELEASE=${STAGING_DIR}/usr/lib/libcurl.so \
	-DCURL_LIBRARY_DEBUG=${STAGING_DIR}/usr/lib/libcurl.so \
    -DCURL_INCLUDE_DIR="${STAGING_DIR}/usr/include" \
	-DLIBXML2_LIBRARY=${STAGING_DIR}/usr/lib/libxml2.so \
    -DLIBXML2_INCLUDE_DIR=${STAGING_DIR}/usr/include/libxml2 \
	-DLibRT_LIBRARIES=$(SWIFT_LIBRT) \
	-DSwiftFoundation_MODULE_TRIPLE=${SWIFT_TARGET_NAME} \
	-DSwiftFoundation_MACRO=${SWIFT_NATIVE_PATH}/../lib/swift/host/plugins \
	-D_SwiftFoundation_SourceDIR=$(HOST_SWIFT_SRCDIR)/swift-source/swift-foundation \
	-D_SwiftFoundationICU_SourceDIR=$(HOST_SWIFT_SRCDIR)/swift-source/swift-foundation-icu \

ifeq (SWIFT_FOUNDATION_SUPPORTS_IN_SOURCE_BUILD),YES)
SWIFT_FOUNDATION_BUILDDIR			= $(SWIFT_FOUNDATION_SRCDIR)
else
SWIFT_FOUNDATION_BUILDDIR			= $(SWIFT_FOUNDATION_SRCDIR)/build
endif

# The Swift sources come from the swift-foundation clone in the host-swift tree,
# which buildroot's patch infrastructure never touches.
#
# FileOperations+Enumeration.swift reads FTSENT members, and clang attributes
# those declarations to _FoundationCShims, whose filemanager_shims.h includes
# <fts.h>. Swift's MemberImportVisibility rule then requires that module to be
# imported explicitly: the Glibc, Android and WASI branches all do so, the Musl
# branch does not, so the file fails to compile against musl with "property
# 'fts_path' is not available due to missing import of defining module". Insert
# the missing import, skipping files that already have it.
#
# 6.4 hits the same rule on glibc, in files that import no shim header at
# all: against this sysroot clang attributes struct stat and struct timespec
# to _FoundationCShims too, and the build stops with
#
#   Date.swift:262:35: error: property 'tv_sec' is not available due to
#   missing import of defining module '_FoundationCShims'
#
# and the same for st_mode, st_dev, st_ino and st_size in
# FileManager+Basics.swift and URL_Impl.swift. Upstream builds these files
# unchanged against its own glibc, so the import is supplied here rather
# than carried as a patch.
SWIFT_FOUNDATION_ESSENTIALS_SRCDIR = $(HOST_SWIFT_SRCDIR)/swift-source/swift-foundation/Sources/FoundationEssentials
SWIFT_FOUNDATION_CSHIMS_IMPORT_SRCS = \
	Date.swift \
	FileManager/FileManager+Basics.swift \
	URL/URL_Impl.swift
ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
SWIFT_FOUNDATION_CSHIMS_IMPORT_SRCS += FileManager/FileOperations+Enumeration.swift
SWIFT_FOUNDATION_LIBC_IMPORT = @preconcurrency import Musl
else
SWIFT_FOUNDATION_LIBC_IMPORT = @preconcurrency import Glibc
endif

define SWIFT_FOUNDATION_CSHIMS_IMPORT_FIXUP
	$(foreach src,$(SWIFT_FOUNDATION_CSHIMS_IMPORT_SRCS), \
		awk 'prev == "$(SWIFT_FOUNDATION_LIBC_IMPORT)" && $$0 != "internal import _FoundationCShims" \
			{ print "internal import _FoundationCShims" } { print; prev = $$0 }' \
			$(SWIFT_FOUNDATION_ESSENTIALS_SRCDIR)/$(src) > $(SWIFT_FOUNDATION_ESSENTIALS_SRCDIR)/$(src).br-tmp \
		&& mv $(SWIFT_FOUNDATION_ESSENTIALS_SRCDIR)/$(src).br-tmp $(SWIFT_FOUNDATION_ESSENTIALS_SRCDIR)/$(src)
	$(sep))
endef
SWIFT_FOUNDATION_PRE_CONFIGURE_HOOKS += SWIFT_FOUNDATION_CSHIMS_IMPORT_FIXUP

define SWIFT_FOUNDATION_CONFIGURE_CMDS
	# Workaround Dispatch defined with cmake and module
	rm -rf ${STAGING_DIR}/usr/lib/swift/dispatch
	# Clean
	rm -rf $(SWIFT_FOUNDATION_BUILDDIR)
	# The install below copies _CModulesForClients into the resource
	# directory, where the compiler finds those module maps on its own. A
	# rebuild, or an upgrade over a tree that already has them, then sees
	# each module twice - once installed, once from these sources - and
	# stops with "redefinition of module '_FoundationCShims'".
	rm -rf $(STAGING_DIR)/usr/lib/swift/CoreFoundation \
		$(STAGING_DIR)/usr/lib/swift/_FoundationCShims \
		$(STAGING_DIR)/usr/lib/swift/_foundation_unicode
	# Configure
	(mkdir -p $(SWIFT_FOUNDATION_BUILDDIR) && \
	cd $(SWIFT_FOUNDATION_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_FOUNDATION_CONF_ENV) $(BR2_CMAKE) -S $(SWIFT_FOUNDATION_SRCDIR) -B $(SWIFT_FOUNDATION_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
    	-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
    	-DCMAKE_Swift_COMPILER=$(SWIFT_NATIVE_PATH)/swiftc \
    	-DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
    	-DCMAKE_C_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) $(SWIFT_FTS_LIBS)" \
		-DCMAKE_CXX_COMPILER=$(SWIFT_NATIVE_PATH)/clang++ \
    	-DCMAKE_CXX_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot $(STAGING_DIR) -latomic $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(STAGING_DIR)/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/ -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME)" \
    	-DCMAKE_CXX_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		-DCMAKE_ASM_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		$(SWIFT_FOUNDATION_CONF_OPTS) \
	)
endef

define SWIFT_FOUNDATION_BUILD_CMDS
	# Compile
	(cd $(SWIFT_FOUNDATION_BUILDDIR) && ninja)
endef

define SWIFT_FOUNDATION_INSTALL_TARGET_CMDS
	cp $(SWIFT_FOUNDATION_BUILDDIR)/lib/*.so $(TARGET_DIR)/usr/lib/
endef

define SWIFT_FOUNDATION_INSTALL_STAGING_CMDS
	# Copy libraries
	cp $(SWIFT_FOUNDATION_BUILDDIR)/lib/*.so $(STAGING_DIR)/usr/lib/swift/$(SWIFT_LIB_SUBDIR)/
	# Copy CoreFoundation module
	mkdir -p ${STAGING_DIR}/usr/lib/swift/CoreFoundation
	cp $(SWIFT_FOUNDATION_SRCDIR)/Sources/CoreFoundation/include/*.h ${STAGING_DIR}/usr/lib/swift/CoreFoundation/ 
	touch ${STAGING_DIR}/usr/lib/swift/CoreFoundation/module.map
	echo 'framework module CoreFoundation [extern_c] [system] { umbrella header "${STAGING_DIR}/usr/lib/swift/CoreFoundation/CoreFoundation.h" }' > ${STAGING_DIR}/usr/lib/swift/CoreFoundation/module.map
	# Copy Swift modules
	cp $(SWIFT_FOUNDATION_BUILDDIR)/swift/*  ${STAGING_DIR}/usr/lib/swift/$(SWIFT_LIB_SUBDIR)/$(SWIFT_TARGET_ARCH)/
	cp -rf $(SWIFT_FOUNDATION_BUILDDIR)/_CModulesForClients/*  ${STAGING_DIR}/usr/lib/swift/
	# Restore Dispatch headers
	$(LIBSWIFTDISPATCH_INSTALL_STAGING_CMDS)
endef

$(eval $(generic-package))
