### Swift Demo
SWIFT_HELLO_VERSION = 0.1.0
SWIFT_HELLO_SITE = $(SWIFT_HELLO_PKGDIR)/src
SWIFT_HELLO_SITE_METHOD = local
SWIFT_HELLO_INSTALL_STAGING = NO
SWIFT_HELLO_INSTALL_TARGET = YES
SWIFT_HELLO_DEPENDENCIES = swift swift-foundation
SWIFT_HELLO_EXECUTABLES = swift-hello

# Exercise the installed Swift library packages when they are enabled. The
# corresponding imports in Sources/swift-hello/Hello.swift are guarded with
# #if canImport(...), so swift-hello still builds when a package is disabled.
ifeq ($(BR2_PACKAGE_SWIFT_SYSTEM),y)
SWIFT_HELLO_DEPENDENCIES += swift-system
endif
ifeq ($(BR2_PACKAGE_SWIFT_COLLECTIONS),y)
SWIFT_HELLO_DEPENDENCIES += swift-collections
endif
ifeq ($(BR2_PACKAGE_SWIFT_ATOMICS),y)
SWIFT_HELLO_DEPENDENCIES += swift-atomics
endif
ifeq ($(BR2_PACKAGE_SWIFT_NUMERICS),y)
SWIFT_HELLO_DEPENDENCIES += swift-numerics
endif
ifeq ($(BR2_PACKAGE_SWIFT_CRYPTO),y)
SWIFT_HELLO_DEPENDENCIES += swift-crypto
endif
ifeq ($(BR2_PACKAGE_SWIFT_HTTP_TYPES),y)
SWIFT_HELLO_DEPENDENCIES += swift-http-types
endif

$(eval $(swift-package))
