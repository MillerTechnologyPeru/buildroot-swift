### Swift Numerics (Numerics)
SWIFT_NUMERICS_VERSION = 1.0.2
SWIFT_NUMERICS_SITE = $(call github,apple,swift-numerics,$(SWIFT_NUMERICS_VERSION))
SWIFT_NUMERICS_LICENSE = Apache-2.0
SWIFT_NUMERICS_LICENSE_FILES = LICENSE.txt
SWIFT_NUMERICS_INSTALL_STAGING = YES
SWIFT_NUMERICS_INSTALL_TARGET = YES
SWIFT_NUMERICS_SUPPORTS_IN_SOURCE_BUILD = NO
SWIFT_NUMERICS_DEPENDENCIES = swift

SWIFT_NUMERICS_BUILDDIR = $(SWIFT_NUMERICS_SRCDIR)/build

SWIFT_NUMERICS_CONF_OPTS += \
	-DCMAKE_SYSTEM_NAME=Linux \
	-DCMAKE_SYSTEM_PROCESSOR=$(SWIFT_TARGET_ARCH) \
	-DCMAKE_Swift_FLAGS=${SWIFTC_FLAGS} \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

define SWIFT_NUMERICS_CONFIGURE_CMDS
	(mkdir -p $(SWIFT_NUMERICS_BUILDDIR) && \
	cd $(SWIFT_NUMERICS_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_NUMERICS_CONF_ENV) $(BR2_CMAKE) -S $(SWIFT_NUMERICS_SRCDIR) -B $(SWIFT_NUMERICS_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DBUILD_SHARED_LIBS=ON \
		-DBUILD_TESTING=NO \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
		-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
		-DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
		-DCMAKE_C_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		$(SWIFT_NUMERICS_CONF_OPTS) \
	)
endef

define SWIFT_NUMERICS_BUILD_CMDS
	(cd $(SWIFT_NUMERICS_BUILDDIR) && ninja)
endef

# See swift-system.mk for why we hand-copy instead of `ninja install`.
define SWIFT_NUMERICS_INSTALL_STAGING_CMDS
	find $(SWIFT_NUMERICS_BUILDDIR) -name '*.so' -type f -exec cp -f {} $(STAGING_DIR)/usr/lib/swift/linux/ \;
	find $(SWIFT_NUMERICS_BUILDDIR) -name '*.a' -type f -exec cp -f {} $(STAGING_DIR)/usr/lib/swift/linux/ \;
	find $(SWIFT_NUMERICS_BUILDDIR) \( -name '*.swiftmodule' -o -name '*.swiftdoc' -o -name '*.swiftsourceinfo' -o -name '*.abi.json' \) -type f -exec cp -f {} $(STAGING_DIR)/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/ \;
	# Stage the _NumericsShims clang module (headers + modulemap). Numerics is
	# built without library evolution, so consumers transitively require every
	# module it imports.
	mkdir -p $(STAGING_DIR)/usr/lib/swift/_NumericsShims
	cp -rf $(SWIFT_NUMERICS_SRCDIR)/Sources/_NumericsShims/include/* $(STAGING_DIR)/usr/lib/swift/_NumericsShims/
endef

define SWIFT_NUMERICS_INSTALL_TARGET_CMDS
	find $(SWIFT_NUMERICS_BUILDDIR) -name '*.so' -type f -exec cp -f {} $(TARGET_DIR)/usr/lib/ \;
endef

$(eval $(generic-package))
