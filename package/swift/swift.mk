### Apple's Swift Programming Language
SWIFT_VERSION = 5.7.1
SWIFT_SITE = $(call github,apple,swift,swift-$(SWIFT_VERSION)-RELEASE)
SWIFT_LICENSE = Apache-2.0
SWIFT_LICENSE_FILES = LICENSE.txt
SWIFT_TARGET_ARCH = $(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))
SWIFT_NATIVE_PATH = $(call qstrip,$(BR2_PACKAGE_SWIFT_NATIVE_TOOLS))
SWIFT_LLVM_DIR = $(call qstrip,$(BR2_PACKAGE_SWIFT_LLVM_DIR))
SWIFT_INSTALL_STAGING = YES
SWIFT_INSTALL_TARGET = YES
SWIFT_SUPPORTS_IN_SOURCE_BUILD = NO
SWIFT_BUILDDIR = $(SWIFT_SRCDIR)/build
SWIFT_DEPENDENCIES = host-swift icu libxml2 libbsd libdispatch

ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
SWIFT_CONF_ENV += LIBS="-latomic"
endif

ifeq ($(SWIFT_TARGET_ARCH),armv7)
SWIFT_TARGET_NAME		= armv7-unknown-linux-gnueabihf
else ifeq ($(SWIFT_TARGET_ARCH),armv6)
SWIFT_TARGET_NAME		= armv6-unknown-linux-gnueabihf
else ifeq ($(SWIFT_TARGET_ARCH),armv5)
SWIFT_TARGET_NAME		= armv5-unknown-linux-gnueabi
else
SWIFT_TARGET_NAME		= $(SWIFT_TARGET_ARCH)-unknown-linux-gnu
endif

ifeq ($(SWIFT_TARGET_ARCH),armv7)
SWIFT_EXTRA_FLAGS		= -mfloat-abi=$(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
SWIFTC_EXTRA_FLAGS		= -Xcc -mfloat-abi=$(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
else ifeq ($(SWIFT_TARGET_ARCH),armv5)
SWIFT_EXTRA_FLAGS		= -march=armv5te
SWIFTC_EXTRA_FLAGS		= -Xcc -march=armv5te
else ifeq ($(SWIFT_TARGET_ARCH),riscv64)
SWIFT_EXTRA_FLAGS		= -mno-relax -mabi=$(call qstrip,$(BR2_GCC_TARGET_ABI)) -mcpu=generic-rv64
SWIFTC_EXTRA_FLAGS		= -Xcc -mno-relax -Xcc -mabi=$(call qstrip,$(BR2_GCC_TARGET_ABI)) -Xcc -mcpu=generic-rv64
else ifeq ($(SWIFT_TARGET_ARCH),mipsel)
SWIFT_EXTRA_FLAGS		= -msoft-float
SWIFTC_EXTRA_FLAGS		= -Xcc -msoft-float
else ifeq ($(SWIFT_TARGET_ARCH),mips64el)
SWIFT_EXTRA_FLAGS		= -msoft-float
SWIFTC_EXTRA_FLAGS		= -Xcc -msoft-float
else ifeq ($(SWIFT_TARGET_ARCH),powerpc)
SWIFT_EXTRA_FLAGS		= -mcpu=7400
SWIFTC_EXTRA_FLAGS		= -Xcc -mcpu=7400
else
SWIFT_EXTRA_FLAGS		= 
SWIFTC_EXTRA_FLAGS		= 
endif

SWIFTC_FLAGS="-target $(SWIFT_TARGET_NAME) -use-ld=lld \
-resource-dir ${STAGING_DIR}/usr/lib/swift \
-Xclang-linker -B${STAGING_DIR}/usr/lib \
-Xclang-linker -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) \
-Xcc -I${STAGING_DIR}/usr/include \
-Xcc -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION)) \
-Xcc -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME) \
$(SWIFTC_EXTRA_FLAGS) \
-L${STAGING_DIR}/lib \
-L${STAGING_DIR}/usr/lib \
-L${STAGING_DIR}/usr/lib/swift \
-L${STAGING_DIR}/usr/lib/swift/linux \
-L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) \
-sdk ${STAGING_DIR} \
"

SWIFT_CONF_OPTS = \
	-DCMAKE_C_COMPILER=$(SWIFT_NATIVE_PATH)/clang \
    -DCMAKE_CXX_COMPILER=$(SWIFT_NATIVE_PATH)/clang++ \
    -DCMAKE_C_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot $(STAGING_DIR) -latomic $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(STAGING_DIR)/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))" \
    -DCMAKE_CXX_FLAGS="-w -fuse-ld=lld -target $(SWIFT_TARGET_NAME) --sysroot $(STAGING_DIR) -latomic $(SWIFT_EXTRA_FLAGS) -I$(STAGING_DIR)/usr/include -B$(STAGING_DIR)/usr/lib -B$(STAGING_DIR)/lib -B$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION)) -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/ -I$(HOST_DIR)/$(GNU_TARGET_NAME)/include/c++/$(call qstrip,$(BR2_GCC_VERSION))/$(GNU_TARGET_NAME)" \
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
    -DSWIFT_BUILD_SYNTAXPARSERLIB=OFF \
    -DSWIFT_BUILD_REMOTE_MIRROR=OFF \
    -DSWIFT_ENABLE_SOURCEKIT_TESTS=OFF \
    -DSWIFT_INCLUDE_DOCS=OFF \
    -DSWIFT_INCLUDE_TOOLS=OFF \
    -DSWIFT_INCLUDE_TESTS=OFF \
    -DSWIFT_HOST_VARIANT_ARCH=${SWIFT_TARGET_ARCH} \
    -DSWIFT_SDKS=LINUX \
    -DSWIFT_SDK_LINUX_ARCH_${SWIFT_TARGET_ARCH}_PATH=${STAGING_DIR}  \
    -DSWIFT_SDK_LINUX_ARCH_${SWIFT_TARGET_ARCH}_LIBC_INCLUDE_DIRECTORY=${STAGING_DIR}/usr/include  \
    -DSWIFT_PATH_TO_LIBDISPATCH_SOURCE=${LIBDISPATCH_SRCDIR} \
    -DSWIFT_ENABLE_EXPERIMENTAL_CONCURRENCY=ON \
	-DZLIB_LIBRARY=$(STAGING_DIR)/usr/lib/libz.so \

ifeq ($(SWIFT_TARGET_ARCH),armv7)
SWIFT_CONF_OPTS	+= \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

else ifeq ($(SWIFT_TARGET_ARCH),armv6)
SWIFT_CONF_OPTS	+= \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

else ifeq ($(SWIFT_TARGET_ARCH),armv5)
SWIFT_CONF_OPTS	+= \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

else ifeq ($(SWIFT_TARGET_ARCH),riscv64)
SWIFT_CONF_OPTS	+= \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

else ifeq ($(SWIFT_TARGET_ARCH),mipsel)
SWIFT_CONF_OPTS	+= \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

else ifeq ($(SWIFT_TARGET_ARCH),mips64el)
SWIFT_CONF_OPTS	+= \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

else ifeq ($(SWIFT_TARGET_ARCH),powerpc)
SWIFT_CONF_OPTS	+= \
	-DCMAKE_Swift_FLAGS_DEBUG="" \
	-DCMAKE_Swift_FLAGS_RELEASE="" \
	-DCMAKE_Swift_FLAGS_RELWITHDEBINFO="" \

else
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
	cp -f $(SWIFT_BUILDDIR)/lib/swift/linux/*.so $(TARGET_DIR)/usr/lib
endef

define SWIFT_INSTALL_STAGING_CMDS
	# Copy runtime libraries and swift interfaces
	(cd $(SWIFT_BUILDDIR) && ninja install)
endef

HOST_SWIFT_SUPPORT_DIR=$(HOST_DIR)/usr/share/swift
SWIFT_DESTINATION_FILE = $(HOST_SWIFT_SUPPORT_DIR)/toolchain.json

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
	echo '      "-fPIC",' >> $(SWIFT_DESTINATION_FILE)

	@if [ "$(SWIFT_TARGET_ARCH)" = "armv5" ]; then\
		echo '      "-march=armv5te",' >> $(SWIFT_DESTINATION_FILE);\
    fi

	echo '   ],' >> $(SWIFT_DESTINATION_FILE)
	echo '   "extra-swiftc-flags":[' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-target", "$(SWIFT_TARGET_NAME)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-use-ld=lld",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-tools-directory", "$(SWIFT_NATIVE_PATH)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-rpath", "-Xlinker", "/usr/lib/swift/linux",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/lib",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib/swift/linux",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(STAGING_DIR)/usr/lib/swift/linux/$(SWIFT_TARGET_ARCH)",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "-L$(HOST_DIR)/lib/gcc/$(GNU_TARGET_NAME)/$(call qstrip,$(BR2_GCC_VERSION))",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-Xlinker", "--build-id=sha1",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-I$(STAGING_DIR)/usr/include",' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-I$(STAGING_DIR)/usr/lib/swift",' >> $(SWIFT_DESTINATION_FILE)
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

	@if [ "$(SWIFT_TARGET_ARCH)" = "riscv64" ]; then\
		echo '      "-Xcc", "-mcpu=generic-rv64",' >> $(SWIFT_DESTINATION_FILE);\
		echo '      "-Xcc", "-mabi=$(BR2_GCC_TARGET_ABI)",' >> $(SWIFT_DESTINATION_FILE);\
    fi

	echo '      "-sdk", "$(STAGING_DIR)"' >> $(SWIFT_DESTINATION_FILE)
	echo '   ],' >> $(SWIFT_DESTINATION_FILE)
	echo '   "extra-cpp-flags":[' >> $(SWIFT_DESTINATION_FILE)
	echo '      "-lstdc++"' >> $(SWIFT_DESTINATION_FILE)
	echo '   ]' >> $(SWIFT_DESTINATION_FILE)
	echo '}' >> $(SWIFT_DESTINATION_FILE)
	
	# Copy swift toolchain
	mkdir -p $(HOST_SWIFT_SUPPORT_DIR)/bin/
	cp -rf $(SWIFT_NATIVE_PATH)/* $(HOST_SWIFT_SUPPORT_DIR)/bin/
	mkdir -p $(HOST_SWIFT_SUPPORT_DIR)/lib/
	cp -rf $(SWIFT_NATIVE_PATH)/../lib/* $(HOST_SWIFT_SUPPORT_DIR)/lib/
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
