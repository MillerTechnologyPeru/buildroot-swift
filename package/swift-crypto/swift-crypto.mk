### Swift Crypto (open-source CryptoKit)
SWIFT_CRYPTO_VERSION = 3.12.5
SWIFT_CRYPTO_SITE = $(call github,apple,swift-crypto,$(SWIFT_CRYPTO_VERSION))
SWIFT_CRYPTO_LICENSE = Apache-2.0
SWIFT_CRYPTO_LICENSE_FILES = LICENSE.txt
SWIFT_CRYPTO_INSTALL_STAGING = YES
SWIFT_CRYPTO_INSTALL_TARGET = YES
SWIFT_CRYPTO_SUPPORTS_IN_SOURCE_BUILD = NO
SWIFT_CRYPTO_DEPENDENCIES = swift swift-foundation swift-asn1

SWIFT_CRYPTO_BUILDDIR = $(SWIFT_CRYPTO_SRCDIR)/build

# swift-crypto vendors and statically links BoringSSL (a C/C++/ASM project), so
# the target platform must be described to CMake. BoringSSL's CMakeLists selects
# per-arch assembly from CMAKE_SYSTEM_PROCESSOR; without an override that would
# be the build host's x86_64 and mismatch every non-x86_64 target. Setting
# CMAKE_SYSTEM_NAME switches CMake into cross mode so CMAKE_SYSTEM_PROCESSOR is
# honored: x86_64/aarch64 get their real assembly, and every other arch falls
# through to the pure-C build enabled by 0001-*.patch (OPENSSL_NO_ASM).
SWIFT_CRYPTO_CONF_OPTS += \
	-DCMAKE_SYSTEM_NAME=Linux \
	-DCMAKE_SYSTEM_PROCESSOR=$(SWIFT_TARGET_ARCH) \
	-DCMAKE_Swift_FLAGS=${SWIFTC_FLAGS} \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \
	-Ddispatch_DIR="$(LIBSWIFTDISPATCH_BUILDDIR)/cmake/modules" \
	-DFoundation_DIR="$(SWIFT_FOUNDATION_BUILDDIR)/cmake/modules" \
	-DSwiftASN1_DIR="$(SWIFT_ASN1_BUILDDIR)" \

define SWIFT_CRYPTO_CONFIGURE_CMDS
	# Workaround Dispatch defined with cmake and module: the dispatch build tree
	# (via dispatch_DIR) and the staging sysroot both ship a module.modulemap for
	# Dispatch, which the compiler rejects as a redefinition. Same fix as
	# swift-foundation / xctest; the module is restored in the install step.
	rm -rf $(STAGING_DIR)/usr/lib/swift/dispatch
	(mkdir -p $(SWIFT_CRYPTO_BUILDDIR) && \
	cd $(SWIFT_CRYPTO_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$(BR_PATH):$(SWIFT_NATIVE_PATH) \
	$(SWIFT_CRYPTO_CONF_ENV) $(BR2_CMAKE) -S $(SWIFT_CRYPTO_SRCDIR) -B $(SWIFT_CRYPTO_BUILDDIR) -G Ninja \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DBUILD_SHARED_LIBS=ON \
		-DBUILD_TESTING=NO \
		-DCMAKE_BUILD_TYPE=$(if $(BR2_ENABLE_RUNTIME_DEBUG),Debug,Release) \
		-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
		-DCMAKE_CXX_COMPILER=$(SWIFT_NATIVE_PATH)/clang++ \
		-DCMAKE_ASM_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
		-DCMAKE_C_COMPILER_WORKS=ON \
		-DCMAKE_CXX_COMPILER_WORKS=ON \
		-DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
		-DCMAKE_C_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		-DCMAKE_CXX_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR) $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/ -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME) -B$(STAGING_DIR)/usr/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
		-DCMAKE_CXX_LINK_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		-DCMAKE_ASM_FLAGS="-target $(SWIFT_TARGET_NAME) --sysroot=$(STAGING_DIR)" \
		$(SWIFT_CRYPTO_CONF_OPTS) \
	)
endef

define SWIFT_CRYPTO_BUILD_CMDS
	(cd $(SWIFT_CRYPTO_BUILDDIR) && ninja)
endef

# See swift-system.mk for why we hand-copy instead of `ninja install`. Only the
# shared modules (Crypto, ...) are copied; the vendored BoringSSL/XKCP static
# libraries are linked into libCrypto.so and need no separate install.
define SWIFT_CRYPTO_INSTALL_STAGING_CMDS
	find $(SWIFT_CRYPTO_BUILDDIR) -name '*.so' -type f -exec cp -f {} $(STAGING_DIR)/usr/lib/swift/linux/ \;
	find $(SWIFT_CRYPTO_BUILDDIR) \( -name '*.swiftmodule' -o -name '*.swiftdoc' -o -name '*.swiftsourceinfo' -o -name '*.abi.json' \) -type f -exec cp -f {} $(STAGING_DIR)/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)/ \;
	# Restore the Dispatch module removed before configure
	$(LIBSWIFTDISPATCH_INSTALL_STAGING_CMDS)
endef

define SWIFT_CRYPTO_INSTALL_TARGET_CMDS
	find $(SWIFT_CRYPTO_BUILDDIR) -name '*.so' -type f -exec cp -f {} $(TARGET_DIR)/usr/lib/ \;
endef

$(eval $(generic-package))
