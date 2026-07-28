### Swift HTTP Types (HTTPTypes)
SWIFT_HTTP_TYPES_VERSION = 1.3.1
SWIFT_HTTP_TYPES_SITE = $(call github,apple,swift-http-types,$(SWIFT_HTTP_TYPES_VERSION))
SWIFT_HTTP_TYPES_LICENSE = Apache-2.0
SWIFT_HTTP_TYPES_LICENSE_FILES = LICENSE.txt
SWIFT_HTTP_TYPES_INSTALL_STAGING = YES
SWIFT_HTTP_TYPES_INSTALL_TARGET = YES
# HTTPTypesFoundation imports Foundation.
SWIFT_HTTP_TYPES_DEPENDENCIES = swift swift-foundation

# swift-http-types ships no CMakeLists, so it is built with SwiftPM through the
# swift-package infrastructure (see package/pkg-swift.mk), the same path
# swift-hello uses. Upstream declares its library products without an explicit
# type, so SwiftPM builds them as static archives; 0001-*.patch adds
# `type: .dynamic` so `swift build` emits shared libraries. The generic
# swift-package install steps then copy the .so and Swift modules into the Swift
# resource directory, so HTTPTypes imports like a system library.
SWIFT_HTTP_TYPES_LIBRARIES = HTTPTypes HTTPTypesFoundation

$(eval $(swift-package))
