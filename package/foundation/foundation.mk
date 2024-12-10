### Foundation
FOUNDATION_VERSION = 6.0.2
FOUNDATION_SITE = $(call github,swiftlang,swift-corelibs-foundation,swift-$(FOUNDATION_VERSION)-RELEASE)
FOUNDATION_LICENSE = Apache-2.0
FOUNDATION_LICENSE_FILES = LICENSE
FOUNDATION_INSTALL_STAGING = YES
FOUNDATION_INSTALL_TARGET = YES
FOUNDATION_SUPPORTS_IN_SOURCE_BUILD = NO
FOUNDATION_DEPENDENCIES = icu libxml2 libcurl swift libswiftdispatch

FOUNDATION_CONF_OPTS += \
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
	-DLibRT_LIBRARIES=${STAGING_DIR}/usr/lib/librt.a \
	-DSwiftFoundation_MODULE_TRIPLE=${SWIFT_TARGET_NAME} \
	-DSwiftFoundation_MACRO=${SWIFT_NATIVE_PATH}/../lib/swift/host/plugins \

ifeq (FOUNDATION_SUPPORTS_IN_SOURCE_BUILD),YES)
FOUNDATION_BUILDDIR			= $(FOUNDATION_SRCDIR)
else
FOUNDATION_BUILDDIR			= $(FOUNDATION_SRCDIR)/build
endif

define FOUNDATION_CONFIGURE_CMDS
	# Workaround Dispatch defined with cmake and module
	rm -rf ${STAGING_DIR}/usr/lib/swift/dispatch
	# Clean
	rm -rf $(FOUNDATION_BUILDDIR)
	rm -rf $(STAGING_DIR)/usr/lib/swift/CoreFoundation
	# Configure
	(mkdir -p $(FOUNDATION_BUILDDIR) && \
	cd $(FOUNDATION_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(FOUNDATION_CONF_ENV) $(BR2_CMAKE) -S $(FOUNDATION_SRCDIR) -B $(FOUNDATION_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
    	-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
    	-DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
    	-DCMAKE_C_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		-DCMAKE_CXX_COMPILER=$(SWIFT_NATIVE_PATH)/clang++ \
    	-DCMAKE_CXX_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot $(STAGING_DIR) -latomic $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(STAGING_DIR)/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/ -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME)" \
    	-DCMAKE_CXX_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		-DCMAKE_ASM_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		$(FOUNDATION_CONF_OPTS) \
	)
endef

define FOUNDATION_BUILD_CMDS
	# Compile
	(cd $(FOUNDATION_BUILDDIR) && ninja)
endef

define FOUNDATION_INSTALL_TARGET_CMDS
	cp $(FOUNDATION_BUILDDIR)/lib/*.so $(TARGET_DIR)/usr/lib/
endef

define FOUNDATION_INSTALL_STAGING_CMDS
	# Copy libraries
	cp $(FOUNDATION_BUILDDIR)/lib/*.so $(STAGING_DIR)/usr/lib/swift/linux/
	# Copy CoreFoundation module
	mkdir -p ${STAGING_DIR}/usr/lib/swift/CoreFoundation
	cp $(FOUNDATION_SRCDIR)/Sources/CoreFoundation/include/*.h ${STAGING_DIR}/usr/lib/swift/CoreFoundation/ 
	touch ${STAGING_DIR}/usr/lib/swift/CoreFoundation/module.map
	echo 'framework module CoreFoundation [extern_c] [system] { umbrella header "${STAGING_DIR}/usr/lib/swift/CoreFoundation/CoreFoundation.h" }' > ${STAGING_DIR}/usr/lib/swift/CoreFoundation/module.map
	# Copy Swift modules
	cp $(FOUNDATION_BUILDDIR)/swift/*  ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/
	# Restore Dispatch headers
	$(LIBSWIFTDISPATCH_INSTALL_STAGING_CMDS)
	
endef

$(eval $(generic-package))
