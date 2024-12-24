#!/bin/bash
set -e

SWIFT_PLATFORM=debian12
SWIFT_BRANCH=swift-6.0.3-release
SWIFT_VERSION=swift-6.0.3-RELEASE
SWIFT_WEBROOT=https://download.swift.org
HOST_SWIFT_SRCDIR=/workspaces/buildroot/output/build/host-swift-6.0.3
HOST_SWIFT_BUILDDIR=$HOST_SWIFT_SRCDIR/build
SWIFT_NATIVE_TOOLS=$HOST_SWIFT_BUILDDIR/usr/bin
SWIFT_LLVM_DIR=$HOST_SWIFT_BUILDDIR/llvm

# Download Swift toolchain
export DEBIAN_FRONTEND=noninteractive
ARCH_NAME="$(dpkg --print-architecture)"; \
    url=; \
    case "${ARCH_NAME##*-}" in \
        'amd64') \
            OS_ARCH_SUFFIX=''; \
            ;; \
        'arm64') \
            OS_ARCH_SUFFIX='-aarch64'; \
            ;; \
        *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac;
 
SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)$OS_ARCH_SUFFIX" 
APPLE_SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM$OS_ARCH_SUFFIX.tar.gz" 
SWIFT_BIN_URL="${SWIFT_BIN_URL:=$APPLE_SWIFT_BIN_URL}"
echo "Download $SWIFT_BIN_URL"
curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz
# - Unpack the toolchain, set libs permissions, and clean up.
mkdir -p $SWIFT_NATIVE_TOOLS/../../ 
tar -xzf swift.tar.gz --directory $SWIFT_NATIVE_TOOLS/../../ --strip-components=1 
chmod -R o+r $SWIFT_NATIVE_TOOLS/../../usr/lib/swift 
rm -rf swift.tar.gz

# Download LLVM headers
mkdir -p $SWIFT_LLVM_DIR 
cd $SWIFT_LLVM_DIR 
wget https://github.com/colemancda/swift-armv7/releases/download/0.4.0/llvm-swift.zip 
unzip llvm-swift.zip 
rm -rf llvm-swift.zip

# Clone required repos
cd $HOST_SWIFT_SRCDIR/swift-source
git clone https://github.com/swiftlang/swift-corelibs-libdispatch.git
cd swift-corelibs-libdispatch
git checkout $SWIFT_VERSION
cd ../
git clone https://github.com/swiftlang/swift-experimental-string-processing.git
cd swift-experimental-string-processing
git checkout $SWIFT_VERSION
cd ../

# Mark as installed
mkdir -p $HOST_SWIFT_SRCDIR
touch $HOST_SWIFT_SRCDIR/.stamp_built
touch $HOST_SWIFT_SRCDIR/.stamp_configured
