### Swift Demo
SWIFT_HELLO_VERSION = 0.1.0
SWIFT_HELLO_SITE = $(SWIFT_HELLO_PKGDIR)/src
SWIFT_HELLO_SITE_METHOD = local
SWIFT_HELLO_INSTALL_STAGING = NO
SWIFT_HELLO_INSTALL_TARGET = YES
SWIFT_HELLO_DEPENDENCIES = swift swift-foundation
SWIFT_HELLO_EXECUTABLES = swift-hello

$(eval $(swift-package))
