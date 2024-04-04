### XCTest
XCTEST_VERSION = 5.10
XCTEST_SITE = $(call github,apple,swift-corelibs-xctest,swift-$(XCTEST_VERSION)-RELEASE)
XCTEST_LICENSE = Apache-2.0
XCTEST_LICENSE_FILES = LICENSE
XCTEST_INSTALL_STAGING = YES
XCTEST_INSTALL_TARGET = YES
XCTEST_SUPPORTS_IN_SOURCE_BUILD = NO
XCTEST_DEPENDENCIES = swift foundation

XCTEST_CONF_OPTS += \
    -DCMAKE_Swift_FLAGS=${SWIFTC_FLAGS} \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \
    -DCF_DEPLOYMENT_SWIFT=ON \
    -Ddispatch_DIR="$(LIBSWIFTDISPATCH_BUILDDIR)/cmake/modules" \
	-DFoundation_DIR="$(FOUNDATION_BUILDDIR)/cmake/modules" \

ifeq (XCTEST_SUPPORTS_IN_SOURCE_BUILD),YES)
XCTEST_BUILDDIR			= $(XCTEST_SRCDIR)
else
XCTEST_BUILDDIR			= $(XCTEST_SRCDIR)/build
endif

define XCTEST_CONFIGURE_CMDS
	# Workaround Dispatch defined with cmake and module
	rm -rf ${STAGING_DIR}/usr/lib/swift/dispatch
	# Configure
	(mkdir -p $(XCTEST_BUILDDIR) && \
	cd $(XCTEST_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(XCTEST_CONF_ENV) $(BR2_CMAKE) -S $(XCTEST_SRCDIR) -B $(XCTEST_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
    	-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
    	-DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
    	-DCMAKE_C_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		$(XCTEST_CONF_OPTS) \
	)
endef

define XCTEST_BUILD_CMDS
	# Compile
	(cd $(XCTEST_BUILDDIR) && ninja)
endef

define XCTEST_INSTALL_TARGET_CMDS
	cp $(XCTEST_BUILDDIR)/*.so $(TARGET_DIR)/usr/lib/
endef

define XCTEST_INSTALL_STAGING_CMDS
	# Copy libraries
	cp $(XCTEST_BUILDDIR)/*.so $(STAGING_DIR)/usr/lib/swift/linux/
	# Copy Swift modules
	cp $(XCTEST_BUILDDIR)/swift/*  ${STAGING_DIR}/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/
	# Restore Dispatch headers
	$(LIBSWIFTDISPATCH_INSTALL_STAGING_CMDS)
endef

$(eval $(generic-package))
