### Swift Atomics (Atomics)
SWIFT_ATOMICS_VERSION = 1.2.0
SWIFT_ATOMICS_SITE = $(call github,apple,swift-atomics,$(SWIFT_ATOMICS_VERSION))
SWIFT_ATOMICS_LICENSE = Apache-2.0
SWIFT_ATOMICS_LICENSE_FILES = LICENSE.txt
SWIFT_ATOMICS_INSTALL_STAGING = YES
SWIFT_ATOMICS_INSTALL_TARGET = YES
SWIFT_ATOMICS_SUPPORTS_IN_SOURCE_BUILD = NO
SWIFT_ATOMICS_DEPENDENCIES = swift

SWIFT_ATOMICS_BUILDDIR = $(SWIFT_ATOMICS_SRCDIR)/build

SWIFT_ATOMICS_CONF_OPTS += \
	-DCMAKE_Swift_FLAGS=${SWIFTC_FLAGS} \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

define SWIFT_ATOMICS_CONFIGURE_CMDS
	(mkdir -p $(SWIFT_ATOMICS_BUILDDIR) && \
	cd $(SWIFT_ATOMICS_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_ATOMICS_CONF_ENV) $(BR2_CMAKE) -S $(SWIFT_ATOMICS_SRCDIR) -B $(SWIFT_ATOMICS_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
		-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
		-DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
		-DCMAKE_C_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		$(SWIFT_ATOMICS_CONF_OPTS) \
	)
endef

define SWIFT_ATOMICS_BUILD_CMDS
	(cd $(SWIFT_ATOMICS_BUILDDIR) && ninja)
endef

# See swift-system.mk for why we hand-copy instead of `ninja install`.
define SWIFT_ATOMICS_INSTALL_STAGING_CMDS
	find $(SWIFT_ATOMICS_BUILDDIR) -name '*.so' -type f -exec cp -f {} $(STAGING_DIR)/usr/lib/swift/linux/ \;
	find $(SWIFT_ATOMICS_BUILDDIR) \( -name '*.swiftmodule' -o -name '*.swiftdoc' -o -name '*.swiftsourceinfo' -o -name '*.abi.json' \) -type f -exec cp -f {} $(STAGING_DIR)/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/ \;
endef

define SWIFT_ATOMICS_INSTALL_TARGET_CMDS
	find $(SWIFT_ATOMICS_BUILDDIR) -name '*.so' -type f -exec cp -f {} $(TARGET_DIR)/usr/lib/ \;
endef

$(eval $(generic-package))
