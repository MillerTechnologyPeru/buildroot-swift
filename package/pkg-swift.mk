################################################################################
# Swift package infrastructure
#
# This file implements an infrastructure that eases development of package .mk
# files for Swift packages. It should be used for all packages that are written in
# Swift.
#
# See the Buildroot documentation for details on the usage of this
# infrastructure
#
#
# In terms of implementation, this swift infrastructure requires the .mk file
# to only specify metadata information about the package: name, version,
# download URL, etc.
#
# We still allow the package .mk file to override what the different steps are
# doing, if needed. For example, if <PKG>_BUILD_CMDS is already defined, it is
# used as the list of commands to perform to build the package, instead of the
# default swift behavior. The package can also define some post operation
# hooks.
#
################################################################################

HOST_SWIFT_SUPPORT_DIR = $(HOST_DIR)/usr/share/swift
SWIFT_BIN = /usr/bin/swift
SWIFT_DESTINATION_FILE = $(HOST_SWIFT_SUPPORT_DIR)/toolchain.json

################################################################################
# inner-swift-package -- defines how the configuration, compilation and
# installation of a Go package should be done, implements a few hooks to tune
# the build process for Go specificities and calls the generic package
# infrastructure to generate the necessary make targets
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name, including a HOST_ prefix for host
#             packages
#  argument 3 is the uppercase package name, without the HOST_ prefix for host
#             packages
#  argument 4 is the type (target or host)
#
################################################################################

define inner-swift-package

$(2)_BUILDDIR = $$($(2)_SRCDIR)/.build/$(if $(BR2_ENABLE_RUNTIME_DEBUG),debug,release)

$(2)_BUILD_OPTS += \
	--configuration $(if $(BR2_ENABLE_RUNTIME_DEBUG),debug,release) \
	-j $$(PARALLEL_JOBS) \

# Target packages need the Swift compiler and runtime
$(2)_DEPENDENCIES += swift

# Build step. Only define it if not already defined by the package .mk
# file.
ifndef $(2)_BUILD_CMDS
ifeq ($(4),target)

# Build package for target
define $(2)_BUILD_CMDS
	( \
	cd $$($(2)_SRCDIR) && \
	PATH=$(BR_PATH):$(HOST_SWIFT_SUPPORT_DIR)/bin \
	$(SWIFT_BIN) build \
		--destination $(SWIFT_DESTINATION_FILE) \
		$$($(2)_BUILD_OPTS) \
	)
endef
else
# Build package for host
define $(2)_BUILD_CMDS
	( \
	cd $$($(2)_SRCDIR) && \
	PATH=$(BR_PATH):$(HOST_SWIFT_SUPPORT_DIR)/bin \
	$(SWIFT_BIN) build \
		$(2)_BUILD_OPTS \
	)
endef
endif
endif

#
# Staging installation step. Only define it if not already defined by
# the package .mk file.
#
ifndef $(2)_INSTALL_STAGING_CMDS
define $(2)_INSTALL_STAGING_CMDS
	# Copy executables
	$$(foreach d,$$($(2)_EXECUTABLES),\
		cp -f $$($(2)_BUILDDIR)/$$(d) $(STAGING_DIR)/usr/bin/
	)
	# Copy dynamic libraries
	$$(foreach d,$$($(2)_LIBRARIES),\
		cp -f $$($(2)_BUILDDIR)/lib$$(d).so $(STAGING_DIR)/usr/lib/swift/linux/
		cp -f $$($(2)_BUILDDIR)/$$(d).swiftdoc $(STAGING_DIR)/usr/lib/swift/linux/$(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))/
		cp -f $$($(2)_BUILDDIR)/$$(d).swiftmodule $(STAGING_DIR)/usr/lib/swift/linux/$(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))/
		cp -f $$($(2)_BUILDDIR)/$$(d).swiftsourceinfo $(STAGING_DIR)/usr/lib/swift/linux/$(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))/
		cp -f $$($(2)_BUILDDIR)/$$(d).abi.json $(STAGING_DIR)/usr/lib/swift/linux/$(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))/
	)
endef
endif

# Target installation step. Only define it if not already defined by the
# package .mk file.
ifndef $(2)_INSTALL_TARGET_CMDS
define $(2)_INSTALL_TARGET_CMDS
	# Copy executables
	$$(foreach d,$$($(2)_EXECUTABLES),\
		cp -f $$($(2)_BUILDDIR)/$$(d) $(TARGET_DIR)/usr/bin/
	)
	# Copy dynamic libraries
	$$(foreach d,$$($(2)_LIBRARIES),\
		cp -f $$($(2)_BUILDDIR)/lib$$(d).so $(TARGET_DIR)/usr/lib/
	)
endef
endif

# Host installation step
ifndef $(2)_INSTALL_CMDS
define $(2)_INSTALL_CMDS
	# Copy executables
	$$(foreach d,$$($(2)_EXECUTABLES),\
		cp -f $$($(2)_BUILDDIR)/$$(d) $(HOST_DIR)/usr/bin/
	)
	# Copy dynamic libraries
	$$(foreach d,$$($(2)_LIBRARIES),\
		cp -f $$($(2)_BUILDDIR)/lib$$(d).so $(HOST_DIR)/usr/lib/swift/linux/
		cp -f $$($(2)_BUILDDIR)/lib$$(d).swiftdoc $(HOST_DIR)/usr/lib/swift/linux/$(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))/
		cp -f $$($(2)_BUILDDIR)/lib$$(d).swiftmodule $(HOST_DIR)/usr/lib/swift/linux/$(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))/
		cp -f $$($(2)_BUILDDIR)/lib$$(d).swiftsourceinfo $(HOST_DIR)/usr/lib/swift/linux/$(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))/
		cp -f $$($(2)_BUILDDIR)/lib$$(d).abi.json $(HOST_DIR)/usr/lib/swift/linux/$(call qstrip,$(BR2_PACKAGE_SWIFT_TARGET_ARCH))/
	)
endef
endif

# Call the generic package infrastructure to generate the necessary make
# targets
$(call inner-generic-package,$(1),$(2),$(3),$(4))

endef # inner-swift-package

################################################################################
# swift-package -- the target generator macro for Swift packages
################################################################################

swift-package = $(call inner-swift-package,$(pkgname),$(call UPPERCASE,$(pkgname)),$(call UPPERCASE,$(pkgname)),target)
host-swift-package = $(call inner-swift-package,host-$(pkgname),$(call UPPERCASE,host-$(pkgname)),$(call UPPERCASE,$(pkgname)),host)
