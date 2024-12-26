#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Create host Swift folders
mkdir -p $HOST_SWIFT_SRCDIR
mkdir -p $HOST_SWIFT_SRCDIR/build
mkdir -p $HOST_SWIFT_SRCDIR/swift-source
mkdir -p $HOST_SWIFT_SRCDIR/swift-source/build
mkdir -p $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux
mkdir -p $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/llvm-linux-$(uname -m)

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
 
SWIFT_WEBROOT=https://download.swift.org
SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)$OS_ARCH_SUFFIX" 
APPLE_SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM$OS_ARCH_SUFFIX.tar.gz" 
SWIFT_BIN_URL="${SWIFT_BIN_URL:=$APPLE_SWIFT_BIN_URL}"
if [ ! -d "$SWIFT_NATIVE_TOOLS" ]; then
    echo "Download $SWIFT_BIN_URL"
    cd /tmp
    curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz
    # - Unpack the toolchain, set libs permissions, and clean up.
    mkdir -p $HOST_SWIFT_BUILDDIR
    tar -xzf swift.tar.gz --directory $HOST_SWIFT_BUILDDIR --strip-components=1 
    rm -rf swift.tar.gz
    chmod -R o+r $HOST_SWIFT_BUILDDIR/usr/lib/swift 
fi

# Download LLVM headers
if [ ! -d "$SWIFT_LLVM_DIR" ]; then
    echo "Install LLVM"
    # Symlink to system LLVM
    ln -s /usr/lib/llvm-15 $SWIFT_LLVM_DIR
fi

# Clone Swift StdLib dependencies
mkdir -p $HOST_SWIFT_SRCDIR/swift-source
cd $HOST_SWIFT_SRCDIR/swift-source
if [ ! -d "$HOST_SWIFT_SRCDIR/swift-source/swift-corelibs-libdispatch" ]; then
    git clone https://github.com/swiftlang/swift-corelibs-libdispatch.git
    cd swift-corelibs-libdispatch
    git checkout $SWIFT_VERSION
    cd ../
fi
if [ ! -d "$HOST_SWIFT_SRCDIR/swift-source/swift-experimental-string-processing" ]; then
    git clone https://github.com/swiftlang/swift-experimental-string-processing.git
    cd swift-experimental-string-processing
    git checkout $SWIFT_VERSION
    cd ../
fi

