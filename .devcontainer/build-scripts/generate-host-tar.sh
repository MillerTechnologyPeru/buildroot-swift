#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build host tools
cd $WORKING_DIR
$SWIFT_BUILDROOT/.devcontainer/build-scripts/download-buildroot.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/configure.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/fetch-sources.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-host.sh

# Cleanup Swift installable package
rm -rf $HOST_SWIFT_SRCDIR/build/swift.tar.gz

# Cleanup Swift host tools sources
rm -rf $HOST_SWIFT_SRCDIR/swift-source/cmake
rm -rf $HOST_SWIFT_SRCDIR/swift-source/cmark
rm -rf $HOST_SWIFT_SRCDIR/swift-source/curl
rm -rf $HOST_SWIFT_SRCDIR/swift-source/indexstore-db
rm -rf $HOST_SWIFT_SRCDIR/swift-source/libxml2
rm -rf $HOST_SWIFT_SRCDIR/swift-source/llbuild
rm -rf $HOST_SWIFT_SRCDIR/swift-source/ninja
rm -rf $HOST_SWIFT_SRCDIR/swift-source/sourcekit-lsp
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-argument-parser
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-asn1
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-async-algorithms
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-atomics
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-certificates
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-collections
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-corelibs-foundation
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-corelibs-xctest
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-crypto
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-docc
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-docc-render-artifact
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-docc-symbolkit
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-driver
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-format
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-foundation
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-foundation-icu
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-installer-scripts
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-integration-tests
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-llvm-bindings
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-lmdb
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-log
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-markdown
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-nio
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-numerics
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-sdk-generator
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-stress-tester
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-syntax
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-system
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-testing
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-toolchain-sqlite
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-tools-support-core
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swift-xcode-playground-support
rm -rf $HOST_SWIFT_SRCDIR/swift-source/swiftpm
rm -rf $HOST_SWIFT_SRCDIR/swift-source/wasi-libc
rm -rf $HOST_SWIFT_SRCDIR/swift-source/wasmkit
rm -rf $HOST_SWIFT_SRCDIR/swift-source/yams
rm -rf $HOST_SWIFT_SRCDIR/swift-source/zlib

# Cleanup Swift build artifacts
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/cmake-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/.cache
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/benchmarks-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/cmark-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/earlyswiftdriver-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/foundation_macros-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/foundation_static-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/foundation-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/libdispatch_static-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/libdispatch-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/llbuild-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/lldb-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/ninja-build
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/none-swift_package_sandbox_linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/swift-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/swiftdriver-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/swiftpm-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/swifttesting-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/swifttestingmacros-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/unified-swiftpm-build-linux-x86_64
rm -rf $HOST_SWIFT_SRCDIR/swift-source/build/buildbot_linux/xctest-linux-x86_64

# Generate tarball
OUTPUT_DIR=$WORKING_DIR/output
OUTPUT_TARBALL=$WORKING_DIR/host-tools.tar.gz
cd $WORKING_DIR
tar -czvf $OUTPUT_TARBALL $OUTPUT_DIR
