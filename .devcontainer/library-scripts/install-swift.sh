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
    # Retry, and resume rather than restart. This is a gigabyte over TLS, and
    # a single attempt fails often enough to matter on a machine that runs it
    # unattended:
    #
    #   curl: (56) OpenSSL SSL_read: error:0A000126:SSL routines::unexpected
    #   eof while reading, errno 0
    #
    # which took out a toolchain restore with the URL perfectly healthy - the
    # same request answered 200 with a Content-Length seconds later.
    # --retry-all-errors is what covers that case; a bare --retry only acts on
    # transient HTTP statuses and connection failures, not on a transfer that
    # dies mid-stream. -C - resumes the partial file instead of starting the
    # gigabyte again.
    rm -f swift.tar.gz
    curl -fsSL --retry 6 --retry-delay 15 --retry-all-errors -C - \
        "$SWIFT_BIN_URL" -o swift.tar.gz
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
    ln -s /usr/lib/llvm-21 $SWIFT_LLVM_DIR
fi

# The Swift stdlib dependencies used to be cloned here. They now come from the
# host-swift package, which fetches every repository build-script needs as an
# extra download and patches them through buildroot's patch infrastructure, so
# cloning them again would only reintroduce sources buildroot does not manage.

