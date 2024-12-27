#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build
cd $WORKING_DIR
make $BUILDROOT_OPTIONS swift-hello-build
/usr/bin/$QEMU_BIN -L $BUILDROOT_TARGET $BUILDROOT_TARGET/usr/bin/swift-hello