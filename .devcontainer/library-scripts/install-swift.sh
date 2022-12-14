#!/bin/bash
set -e

SWIFT_NATIVE_TOOLS="${SWIFT_NATIVE_TOOLS:=/workspaces/swift/usr/bin}"
SWIFT_LLVM_DIR="${SWIFT_LLVM_DIR:=/workspaces/llvm}"

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
